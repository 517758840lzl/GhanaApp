import Foundation
import UIKit
import AVFoundation
import Vision
import ARKit

protocol LivenessDetecting: AnyObject {
    var onStatus: ((String) -> Void)? { get set }
    var onCircle: ((Bool) -> Void)? { get set }
    var onActionCompleted: ((String) -> Void)? { get set }
    var onAllCompleted: (([String]) -> Void)? { get set }
    var onReadyForManualCapture: (() -> Void)? { get set }

    func start()
    func stop()
    func captureManually()
}

final class VisionLivenessDetector: NSObject, LivenessDetecting {

    // MARK: - Public callbacks
    var onStatus: ((String) -> Void)?
    var onCircle: ((Bool) -> Void)?
    var onActionCompleted: ((String) -> Void)?
    var onAllCompleted: (([String]) -> Void)?
    var onReadyForManualCapture: (() -> Void)?

    // MARK: - Dependencies
    private weak var sceneView: ARSCNView?
    private let requiredActions: [String]
    private let captureCircularImage: () -> UIImage?

    // MARK: - Session & Vision
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let visionRequestHandler = VNSequenceRequestHandler()
    private let visionQueue = DispatchQueue(label: "com.flutterghana.face.visionQueue.detector")

    // MARK: - State
    private var isDetecting = false
    private var currentActionIndex = 0
    private var lastFaceInFrame = false
    private var lastVisionObservation: VNFaceObservation?
    private var wasEyesClosed = false
    private var capturedImages = [String]()
    private var frontFaceDetected = false
    private var isReadyForManualCapture = false
    private var lastCapturedImage: UIImage?

    // Stable-frame counters
    private var stableCounters: [String: Int] = [:]
    private let stableNeeded = 3

    // Thresholds (tuned for older devices)
    private let eyeClosedRatioThreshold: CGFloat = 0.20
    private let mouthOpenRatioThreshold: CGFloat = 0.33
    private let smileScoreThreshold: CGFloat = 0.12
    private let frontFaceSymmetryThreshold: CGFloat = 0.6

    init(sceneView: ARSCNView,
         requiredActions: [String],
         captureCircularImage: @escaping () -> UIImage?) {
        self.sceneView = sceneView
        self.requiredActions = requiredActions
        self.captureCircularImage = captureCircularImage
        super.init()
    }

    // MARK: - Lifecycle
    func start() {
        guard !isDetecting else { return }
        isDetecting = true
        currentActionIndex = 0
        lastFaceInFrame = false
        wasEyesClosed = false
        stableCounters = [:]
        capturedImages.removeAll()
        frontFaceDetected = false
        isReadyForManualCapture = false
        setupVisionCaptureSession()
        onStatus?("Please align your face within the circular frame.")
    }

    func stop() {
        isDetecting = false
        stopVisionCaptureSession()
    }

    // MARK: - Manual capture
    func captureManually() {
        guard isReadyForManualCapture else { return }
        captureIfNeeded()
        onAllCompleted?(capturedImages)
    }

    // MARK: - Camera setup
    private func setupVisionCaptureSession() {
        guard captureSession == nil, let sceneView = sceneView else { return }

        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            onStatus?("Camera unavailable.")
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: visionQueue)
        guard session.canAddOutput(output) else {
            onStatus?("Camera output unavailable.")
            return
        }
        session.addOutput(output)

        if let connection = output.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = true
        }

        session.commitConfiguration()

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill  // 保持宽高比填充
        layer.frame = sceneView.bounds
        sceneView.layer.insertSublayer(layer, at: 0)
        previewLayer = layer

        captureSession = session
        session.startRunning()
    }

    private func stopVisionCaptureSession() {
        guard let session = captureSession else { return }
        session.stopRunning()
        for input in session.inputs { session.removeInput(input) }
        for output in session.outputs { session.removeOutput(output) }
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        captureSession = nil
    }

    // MARK: - Helpers
    private func isFaceInCircleFrameVision(observation: VNFaceObservation) -> Bool {
        guard let bounds = sceneView?.bounds, bounds.width > 0 && bounds.height > 0 else { return false }
        let rect = observation.boundingBox
        let centerNorm = CGPoint(x: rect.midX, y: rect.midY)
        let centerPx = CGPoint(x: centerNorm.x * bounds.width,
                               y: (1 - centerNorm.y) * bounds.height)

        let circleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let circleRadius = min(bounds.width, bounds.height) * 0.25
        let dx = centerPx.x - circleCenter.x
        let dy = centerPx.y - circleCenter.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        let inCenter = pixelDistance <= circleRadius

        let faceHeightPx = rect.height * bounds.height
        let minFacePx: CGFloat = 80
        let maxFacePx: CGFloat = bounds.height * 0.9
        let isSizeOK = faceHeightPx >= minFacePx && faceHeightPx <= maxFacePx

        let isInFrame = inCenter && isSizeOK
        onCircle?(isInFrame)
        return isInFrame
    }

    private func getFacePositionHintVision(observation: VNFaceObservation?) -> String {
        guard let sceneBounds = sceneView?.bounds else { return "Please align your face within the circular frame." }
        guard let obs = observation else { return "Please align your face within the circular frame." }
        let rect = obs.boundingBox
        let centerNorm = CGPoint(x: rect.midX, y: rect.midY)
        let centerPx = CGPoint(x: centerNorm.x * sceneBounds.width,
                               y: (1 - centerNorm.y) * sceneBounds.height)

        let circleCenter = CGPoint(x: sceneBounds.midX, y: sceneBounds.midY)
        let circleRadius = min(sceneBounds.width, sceneBounds.height) * 0.25
        let dx = centerPx.x - circleCenter.x
        let dy = centerPx.y - circleCenter.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        let inCircle = pixelDistance <= circleRadius

        let faceHeightPx = rect.height * sceneBounds.height
        let minFacePx: CGFloat = 80
        let maxFacePx: CGFloat = sceneBounds.height * 0.9

        if faceHeightPx < minFacePx { return "Your face appears too small, please move closer." }
        if faceHeightPx > maxFacePx { return "Your face appears too large, please move farther." }
        if !inCircle { return "Please align your face within the circular frame." }
        return "Hold still, detecting..."
    }

    private func eyeAspectRatio(normalizedPoints: [CGPoint]) -> CGFloat {
        guard !normalizedPoints.isEmpty else { return 0 }
        let xs = normalizedPoints.map { $0.x }
        let ys = normalizedPoints.map { $0.y }
        guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else { return 0 }
        let width = max(maxX - minX, 0.0001)
        let height = maxY - minY
        return height / width
    }

    private func eyeWidth(normalizedPoints: [CGPoint]) -> CGFloat {
        guard !normalizedPoints.isEmpty else { return 0 }
        let xs = normalizedPoints.map { $0.x }
        guard let minX = xs.min(), let maxX = xs.max() else { return 0 }
        return maxX - minX
    }

    private func mouthOpenRatio(landmarks: VNFaceLandmarks2D) -> CGFloat {
        guard let inner = landmarks.innerLips, let outer = landmarks.outerLips else { return 0 }
        let innerYs = inner.normalizedPoints.map { $0.y }
        let innerMinY = innerYs.min() ?? 0
        let innerMaxY = innerYs.max() ?? 0
        let height = innerMaxY - innerMinY

        let outerXs = outer.normalizedPoints.map { $0.x }
        let outerMinX = outerXs.min() ?? 0
        let outerMaxX = outerXs.max() ?? 1
        let width = max(outerMaxX - outerMinX, 0.0001)
        return height / width
    }

    private func smileScore(normalizedPoints: [CGPoint]) -> CGFloat {
        guard !normalizedPoints.isEmpty else { return 0 }
        let left = normalizedPoints.min(by: { $0.x < $1.x }) ?? normalizedPoints[0]
        let right = normalizedPoints.max(by: { $0.x < $1.x }) ?? normalizedPoints[0]
        let midIndex = normalizedPoints.count / 2
        let mid = normalizedPoints[midIndex]
        let lift = ((left.y - mid.y) + (right.y - mid.y)) / 2
        return lift
    }

    private func markStable(_ action: String) {
        stableCounters[action, default: 0] += 1
        if stableCounters[action, default: 0] >= stableNeeded {
            onActionCompleted?(action)
            moveToNextOrFinish()
            stableCounters[action] = 0
        }
    }

    private func moveToNextOrFinish() {
        currentActionIndex += 1
        if currentActionIndex >= requiredActions.count {
            // For non-ARKit devices, only do front face detection
            if requiredActions.contains("frontFaceStep") && frontFaceDetected {
                isReadyForManualCapture = true
                onReadyForManualCapture?()
                onStatus?("Front face detected! Please tap to capture photo.")
            } else {
                onAllCompleted?(capturedImages)
            }
        } else {
            // show next hint
            let action = requiredActions[currentActionIndex]
            onStatus?(instruction(for: action))
        }
    }

    private func instruction(for action: String) -> String {
        switch action {
        case "blinkStep": return "Please blink your eyes naturally."
        case "smileStep": return "Please smile naturally."
        case "sideFaceStep": return "Please turn your head left and right."
        case "mouthOpenStep": return "Please open your mouth."
        case "frontFaceStep": return "Please look directly at the camera and hold still."
        default: return "Please follow the verification instructions."
        }
    }

    private func captureIfNeeded() {
        guard let image = captureVisionImage(),
              let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileName = "face_\(capturedImages.count + 1).jpg"
        let filePath = NSTemporaryDirectory() + fileName
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            capturedImages.append(filePath)
        } catch {
            // ignore
        }
    }
    
    // MARK: - Vision模式下的图片捕获
    private func captureVisionImage() -> UIImage? {
        guard let sceneView = sceneView else { return nil }
        
        // 如果有存储的最新图片，使用它
        if let lastImage = lastCapturedImage {
            return createCircularImage(from: lastImage, size: sceneView.bounds.size)
        }
        
        // 否则尝试从sceneView截图
        var capturedImage: UIImage?
        DispatchQueue.main.sync {
            capturedImage = sceneView.snapshot()
        }
        
        guard let fullImage = capturedImage else { return nil }
        
        // 创建圆形裁剪
        return createCircularImage(from: fullImage, size: sceneView.bounds.size)
    }
    
    // MARK: - 创建圆形图片
    private func createCircularImage(from fullImage: UIImage, size: CGSize) -> UIImage? {
        guard let sceneView = sceneView else { return nil }
        
        // 计算圆圈的尺寸和位置
        let viewSize = sceneView.bounds.size
        let circleRadius = min(viewSize.width, viewSize.height) * 0.4  // 调整为0.4，与ARKit模式保持一致
        let circleCenter = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        
        // 计算圆圈在原图中的位置
        let imageSize = fullImage.size
        let scaleX = imageSize.width / viewSize.width
        let scaleY = imageSize.height / viewSize.height
        
        // 预览层使用 .resizeAspectFill，需按较大的缩放比进行映射，并补偿居中裁剪偏移
        let aspectFillScale = max(scaleX, scaleY)
        let scaledViewSize = CGSize(width: viewSize.width * aspectFillScale,
                                    height: viewSize.height * aspectFillScale)
        let offsetX = (imageSize.width - scaledViewSize.width) / 2
        let offsetY = (imageSize.height - scaledViewSize.height) / 2
        
        let imageCircleCenter = CGPoint(
            x: circleCenter.x * aspectFillScale + offsetX,
            y: circleCenter.y * aspectFillScale + offsetY
        )
        let imageCircleRadius = circleRadius * aspectFillScale
        
        // 计算在图片范围内的最大可用半径，保持裁剪为正方形，避免边界导致的非等比拉伸
        let maxLeft = imageCircleCenter.x
        let maxRight = imageSize.width - imageCircleCenter.x
        let maxTop = imageCircleCenter.y
        let maxBottom = imageSize.height - imageCircleCenter.y
        let maxRadiusFit = max(0, min(imageCircleRadius, maxLeft, maxRight, maxTop, maxBottom))

        // 使用适配后的半径构建正方形裁剪区域
        let cropRect = CGRect(
            x: imageCircleCenter.x - maxRadiusFit,
            y: imageCircleCenter.y - maxRadiusFit,
            width: maxRadiusFit * 2,
            height: maxRadiusFit * 2
        )
        
        // 裁剪图片
        guard let cgImage = fullImage.cgImage?.cropping(to: cropRect) else { return nil }
        
        // 创建圆形遮罩
        let croppedImage = UIImage(cgImage: cgImage)
        let finalSize = CGSize(width: imageCircleRadius * 2, height: imageCircleRadius * 2)
        
        UIGraphicsBeginImageContextWithOptions(finalSize, false, 2.0)  // 使用2.0的scale提高质量
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 绘制圆形路径
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: finalSize))
        
        // 设置裁剪区域
        context.saveGState()
        circlePath.addClip()
        
        // 绘制裁剪后的图片，保持宽高比
        let imageRect = CGRect(origin: .zero, size: finalSize)
        croppedImage.draw(in: imageRect, blendMode: CGBlendMode.normal, alpha: 1.0)
        
        // 恢复上下文
        context.restoreGState()
        
        // 获取最终的圆形图片
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension VisionLivenessDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isDetecting, let _ = sceneView else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // 存储最新的图片数据，保持正确的宽高比
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            // 创建UIImage时保持正确的宽高比
            let image = UIImage(cgImage: cgImage)
            // 确保图片方向正确
            if image.imageOrientation != .up {
                UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                image.draw(in: CGRect(origin: .zero, size: image.size))
                lastCapturedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            } else {
                lastCapturedImage = image
            }
        }

        let request = VNDetectFaceLandmarksRequest { [weak self] req, err in
            guard let self = self else { return }
            if let err = err { self.onStatus?("Vision error: \(err.localizedDescription)"); return }
            guard let results = req.results as? [VNFaceObservation], let face = results.first else {
                if self.lastFaceInFrame {
                    self.lastFaceInFrame = false
                    self.onCircle?(false)
                    self.onStatus?("Please align your face within the circular frame.")
                }
                return
            }

            self.lastVisionObservation = face
            let inFrame = self.isFaceInCircleFrameVision(observation: face)
            if self.lastFaceInFrame != inFrame { self.lastFaceInFrame = inFrame }

            if inFrame {
                self.checkLivenessVision(observation: face, landmarks: face.landmarks)
            } else {
                self.onStatus?(self.getFacePositionHintVision(observation: self.lastVisionObservation))
            }
        }

        let orientation: CGImagePropertyOrientation = .leftMirrored
        do {
            try visionRequestHandler.perform([request], on: pixelBuffer, orientation: orientation)
        } catch {
            onStatus?("Vision perform error: \(error.localizedDescription)")
        }
    }

    private func checkLivenessVision(observation: VNFaceObservation, landmarks: VNFaceLandmarks2D?) {
        guard isDetecting, lastFaceInFrame, currentActionIndex < requiredActions.count else { return }
        let action = requiredActions[currentActionIndex]

        // For non-ARKit devices, only check front face
        if action != "frontFaceStep" {
            return
        }

        switch action {
        case "blinkStep":
            if let lm = landmarks, let left = lm.leftEye, let right = lm.rightEye {
                let l = eyeAspectRatio(normalizedPoints: left.normalizedPoints)
                let r = eyeAspectRatio(normalizedPoints: right.normalizedPoints)
                let closed = l < eyeClosedRatioThreshold && r < eyeClosedRatioThreshold
                if closed && !wasEyesClosed {
                    wasEyesClosed = true
                    onStatus?("Blink detected")
                    markStable(action)
                } else if !closed {
                    wasEyesClosed = false
                }
            }
        case "smileStep":
            if let lm = landmarks, let lips = lm.outerLips {
                let score = smileScore(normalizedPoints: lips.normalizedPoints)
                if score > smileScoreThreshold { onStatus?("Smile detected successfully"); markStable(action) }
            }
        case "mouthOpenStep":
            if let lm = landmarks {
                let ratio = mouthOpenRatio(landmarks: lm)
                if ratio > mouthOpenRatioThreshold { onStatus?("Mouth open detected successfully"); markStable(action) }
            }
        case "sideFaceStep":
            if let lm = landmarks, let leftEye = lm.leftEye, let rightEye = lm.rightEye {
                let lw = eyeWidth(normalizedPoints: leftEye.normalizedPoints)
                let rw = eyeWidth(normalizedPoints: rightEye.normalizedPoints)
                let diff = abs(lw - rw)
                if diff > 0.08 { onStatus?("Head movement detected successfully"); markStable(action) }
            }
        case "frontFaceStep":
            // Use symmetry as proxy for front face on Vision
            if let lm = landmarks, let leftEye = lm.leftEye, let rightEye = lm.rightEye {
                let lw = eyeWidth(normalizedPoints: leftEye.normalizedPoints)
                let rw = eyeWidth(normalizedPoints: rightEye.normalizedPoints)
                let symmetry = 1 - abs(lw - rw) / max(lw, rw)
                if symmetry > frontFaceSymmetryThreshold {
                    frontFaceDetected = true
                    onStatus?("Front face detected successfully")
                    markStable(action)
                }
            }
        default:
            break
        }
    }
}


