import UIKit
import ARKit
import SceneKit
import AVFoundation
import Vision

class FaceDetectionViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    // MARK: - Properties
    private var faceNode: SCNNode?
    private var isDetecting = false
    private var detectionStartTime: Date?
    private var eyeBlinkCount = 0
    private var smileDetected = false
    private var headShakeDetected = false
    private var headNodDetected = false
    private var mouthOpenDetected = false
    private var frontFaceDetected = false
    
    // 超时定时器
    private var timeoutTimer: Timer?
    
    // 人脸状态监测定时器
    private var faceStatusTimer: Timer?

    // 从Flutter传入的动作数组
    var requiredActions: [String] = ["blinkStep", "smileStep", "sideFaceStep", "mouthOpenStep", "frontFaceStep"]
    
    // 定义支持的动作类型
    private let supportedActions: Set<String> = ["blinkStep", "smileStep", "sideFaceStep", "mouthOpenStep", "frontFaceStep"]
    
    // 完成回调
    var completionHandler: (([String: Any]) -> Void)?

    // 存储捕获的图片路径
    private var capturedImages = [String]()

    // MARK: - 动作检测状态管理
    private var currentActionIndex = 0 // 当前正在检测的动作索引

    // 头部姿态检测
    private var headPitchSamples = [Float]()  // 存储pitch样本(上下点头)
    private var headYawSamples = [Float]()    // 存储yaw样本(左右摇头)
    private let sampleWindowSize = 20         // 样本窗口大小(约0.5秒数据)
    private var isNodding = false             // 是否正在点头
    private var isShaking = false             // 是否正在摇头
    private var lastHeadPitch: Float = 0      // 上一次pitch值
    private var lastHeadYaw: Float = 0        // 上一次yaw值

    // 新增：记录上一次人脸是否在框内
    private var lastFaceInFrame: Bool = false

    // MARK: - Fallback (Vision) for devices not supporting ARKit face tracking
    private let useARKit: Bool = ARFaceTrackingConfiguration.isSupported
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let visionRequestHandler = VNSequenceRequestHandler()
    private let visionQueue = DispatchQueue(label: "com.flutterghana.face.visionQueue")
    private var lastVisionObservation: VNFaceObservation?
    private var wasEyesClosed: Bool = false
    private var visionDetector: LivenessDetecting?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatusBarBackground()
        setupToolbar()
        setupSceneView()
        setupUI()
        validateAndFilterActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if useARKit {
            sceneView.session.pause()
        } else {
            visionDetector?.stop()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeSceneViewCircular()
        // 设置圆框的默认颜色为蓝色（等待状态）
        setCircleFrameWaitingColor()
        startFaceDetection() // 自动开始检测
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {  // ← 判断是否主动关闭
            completionHandler?([:])  // 返回空数组表示取消
            cancelTimeoutTimer()
            cancelFaceStatusTimer()
        }
    }

//    private func makeSceneViewCircular() {
//        // 确保使用主线程更新UI
//        DispatchQueue.main.async {
//            // 1. 设置圆角
//            let radius = min(self.sceneView.frame.width, self.sceneView.frame.height) / 2
//            self.sceneView.layer.cornerRadius = radius
//            self.sceneView.layer.masksToBounds = true
//
//            // 2. 设置contentMode
//            self.sceneView.contentMode = .scaleAspectFill
//
//            // 3. 添加边框（可选，用于调试）
//            self.sceneView.layer.borderWidth = 2
//            self.sceneView.layer.borderColor = UIColor.systemBlue.cgColor
//
//            // 4. 强制重新布局
//            self.sceneView.setNeedsLayout()
//            self.sceneView.layoutIfNeeded()
//        }
//    }
    private func makeSceneViewCircular() {
            DispatchQueue.main.async {
                let sideLength = min(self.view.frame.width, self.view.frame.height) * 0.8
                let x = (self.view.frame.width - sideLength) / 2
                let y = (self.view.frame.height - sideLength) / 2
                self.sceneView.frame = CGRect(x: x, y: y, width: sideLength, height: sideLength)

                self.sceneView.layer.cornerRadius = sideLength / 2
                self.sceneView.layer.masksToBounds = true

                self.sceneView.contentMode = .scaleAspectFit

                self.sceneView.layer.borderWidth = 3
                self.sceneView.layer.borderColor = UIColor.systemGreen.cgColor
                
                // 添加阴影效果，让圆框更明显
                self.sceneView.layer.shadowColor = UIColor.black.cgColor
                self.sceneView.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.sceneView.layer.shadowOpacity = 0.3
                self.sceneView.layer.shadowRadius = 4

                self.sceneView.setNeedsLayout()
                self.sceneView.layoutIfNeeded()
                print("sceneView frame: \(self.sceneView.frame)")
                // 更新预览层尺寸（Vision 模式）
                self.previewLayer?.frame = self.sceneView.bounds
            }
        }

    // MARK: - Setup
    private func setupSceneView() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.showsStatistics = false
    }

//    private func setupUI() {
//        statusLabel.text = "Please fit your entire face into the frame."
//        // 移除背景色（设为透明）
//        statusLabel.backgroundColor = .clear
//        // 设置字体颜色为黑色
//        statusLabel.textColor = .blue
//        // 移除圆角相关设置（因为不再需要背景）
//        statusLabel.numberOfLines = 0  // 设置为0表示不限行数
//        statusLabel.layer.cornerRadius = 0
//        statusLabel.clipsToBounds = false
//
//        // 按钮样式保持不变
//        startButton.setTitle("Start detection", for: .normal)
//        startButton.backgroundColor = .systemBlue
//        startButton.setTitleColor(.white, for: .normal)
//        startButton.layer.cornerRadius = 8
//    }

    private func setupUI() {
        statusLabel.text = AppLocalizedString("face_detection.initial_instruction", comment: "")
        statusLabel.backgroundColor = .clear
        statusLabel.textColor = .blue
        statusLabel.numberOfLines = 0  // 允许无限行数
        statusLabel.textAlignment = .center
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.5
        statusLabel.layer.cornerRadius = 0
        statusLabel.clipsToBounds = false
        
        let sideLength = min(self.view.frame.width, self.view.frame.height) * 0.8
        let x = (self.view.frame.width - sideLength) / 2
        let y = (self.view.frame.height - sideLength) / 2
        self.sceneView.frame = CGRect(x: x, y: y, width: sideLength, height: sideLength)

        self.sceneView.layer.cornerRadius = sideLength / 2
        self.sceneView.layer.masksToBounds = true

        self.sceneView.contentMode = .scaleAspectFit

        self.sceneView.layer.borderWidth = 3
        self.sceneView.layer.borderColor = UIColor.systemGreen.cgColor
        
        // 添加阴影效果，让圆框更明显
        self.sceneView.layer.shadowColor = UIColor.black.cgColor
        self.sceneView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.sceneView.layer.shadowOpacity = 0.3
        self.sceneView.layer.shadowRadius = 4

        self.sceneView.setNeedsLayout()
        self.sceneView.layoutIfNeeded()
        print("sceneView frame: \(self.sceneView.frame)")

        startButton.setTitle(AppLocalizedString("face_detection.start_verification", comment: ""), for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.isHidden = true // 隐藏按钮
    }

    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.barTintColor = .systemBlue
        toolbar.isTranslucent = false // 关键：关闭半透明
        toolbar.tintColor = .white

        // 移除顶部边框线
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        // 返回按钮
        let backButton: UIBarButtonItem
        if #available(iOS 13.0, *) {
            backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backButtonTapped)
            )
        } else {
            // iOS 12 及以下版本使用自定义图片或文字
            backButton = UIBarButtonItem(
                title: AppLocalizedString("face_detection.close", comment: ""),
                style: .plain,
                target: self,
                action: #selector(backButtonTapped)
            )
        }

        // 标题Label（正确写法）
        let titleLabel = UILabel()
        titleLabel.text = AppLocalizedString("face_detection.identity_verification", comment: "")
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center

        // 关键修改：使用固定空间的占位符代替flexibleSpace
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 16 // 设置标题与返回按钮的间距

        toolbar.items = [backButton, fixedSpace, UIBarButtonItem(customView: titleLabel)]

        // 约束设置
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func backButtonTapped() {
        // 返回逻辑（例如关闭当前页面）
//        navigationController?.popViewController(animated: true)
        print("Back button tapped")
               dismiss(animated: true) {
                   self.completionHandler?([:])
               }
    }

    private func setupStatusBarBackground() {
        let statusBarView = UIView()
        statusBarView.backgroundColor = .systemBlue

        // 添加到视图（位于最顶层）
        view.addSubview(statusBarView)
        statusBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    // MARK: - 动作验证和过滤
    private func validateAndFilterActions() {
        // 过滤掉不支持的动作
        let filteredActions = requiredActions.filter { supportedActions.contains($0) }

        // 如果过滤后没有动作，设置默认动作
        if filteredActions.isEmpty {
            requiredActions = ["blinkStep", "frontFaceStep"]
            print("⚠️ 没有匹配的验证动作，使用默认动作: \(requiredActions)")
        } else {
            requiredActions = filteredActions
            print("✅ 过滤后的验证动作: \(requiredActions)")
        }

        // 重置当前动作索引
        currentActionIndex = 0
    }

    // MARK: - AR Session Management
    private func resetTracking() {
        if useARKit {
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            // For non-ARKit devices, only do front face detection
            let detector = VisionLivenessDetector(
                sceneView: sceneView,
                requiredActions: ["frontFaceStep"], // Only front face detection
                captureCircularImage: { [weak self] in
                    // VisionLivenessDetector now handles its own image capture
                    return nil
                }
            )
            detector.onStatus = { [weak self] text in
                DispatchQueue.main.async { self?.statusLabel.text = text }
            }
            detector.onCircle = { [weak self] inFrame in
                self?.updateCircleFrameColor(isInFrame: inFrame)
                self?.lastFaceInFrame = inFrame
            }
            detector.onActionCompleted = { [weak self] _ in
                // Front face detected, ready for manual capture
            }
            detector.onReadyForManualCapture = { [weak self] in
                DispatchQueue.main.async {
                    self?.startButton.isHidden = false
                    self?.startButton.setTitle(AppLocalizedString("face_detection.capture_photo", comment: ""), for: .normal)
                }
            }
            detector.onAllCompleted = { [weak self] images in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.statusLabel.text = AppLocalizedString("face_detection.photo_captured_successfully", comment: "")
                    self.isDetecting = false
                    self.startButton.setTitle(AppLocalizedString("face_detection.start_verification", comment: ""), for: .normal)
                    self.startButton.isHidden = true
                    self.cancelTimeoutTimer()
                    self.capturedImages = images
                    self.closeWithResult()
                }
            }
            visionDetector = detector
            detector.start()
            DispatchQueue.main.async {
                self.statusLabel.text = AppLocalizedString("face_detection.align_face_for_front_detection", comment: "")
            }
        }
    }

//    // MARK: - 图片捕获方法（只在检测到人脸时调用）
//    private func captureFaceImage() {
//        // 确保已捕获图片少于3张且有人脸存在
//        guard capturedImages.count < 3,
//              let currentFrame = sceneView.session.currentFrame,
//              !currentFrame.anchors.isEmpty else {
//            return
//        }
//
//        // 检查是否存在人脸锚点
//        let hasFace = currentFrame.anchors.contains { $0 is ARFaceAnchor }
//        guard hasFace else { return }
//
//        let image = sceneView.snapshot()
//
//        // 保存图片到临时目录
//        let fileName = "face_\(capturedImages.count + 1).jpg"
//        let filePath = NSTemporaryDirectory() + fileName
//
//        if let data = image.jpegData(compressionQuality: 0.8) {
//            do {
//                try data.write(to: URL(fileURLWithPath: filePath))
//                capturedImages.append(filePath)
//                print("成功捕获人脸图片: \(filePath)")
//            } catch {
//                print("保存图片失败: \(error)")
//            }
//        }
//    }

    // MARK: - 图片捕获方法（只在完成其中一步人脸检测的情况下调用）
    private func captureFaceImage() {
        // 确保已捕获图片少于3张且有人脸存在
        guard capturedImages.count < 3,
              let currentFrame = sceneView.session.currentFrame,
              let faceAnchor = currentFrame.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else {
            return
        }

        // 检查面部特征点是否完整可见（例如两只眼睛和嘴巴）
        let hasCompleteFacialFeatures = detectFaceOcclusion(faceAnchor: faceAnchor)
        guard !hasCompleteFacialFeatures else {
            print("面部特征不完整，跳过捕获")
            return
        }

        // 检查人脸是否在圆框内
        guard isFaceInCircleFrame(faceAnchor: faceAnchor) else {
            print("人脸不在圆框内，跳过捕获")
            return
        }

        // 获取圆框内的图片
        guard let croppedImage = captureCircularImage() else {
            print("无法截取圆框内图片")
            return
        }

        // 新增：检查是否至少完成了一个动作步骤
        guard hasCompletedAtLeastOneAction() else {
            print("尚未完成任何动作步骤，跳过捕获")
            return
        }


        // 保存图片到临时目录
        let fileName = "face_\(capturedImages.count + 1).jpg"
        let filePath = NSTemporaryDirectory() + fileName

        if let data = croppedImage.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: URL(fileURLWithPath: filePath))
                capturedImages.append(filePath)
                print("成功捕获圆框内人脸图片: \(filePath)")
            } catch {
                print("保存图片失败: \(error)")
            }
        }
    }

    // MARK: - 检查是否至少完成了一个动作步骤
    private func hasCompletedAtLeastOneAction() -> Bool {
        // 检查是否至少完成了一个动作
        if requiredActions.contains("blinkStep") && eyeBlinkCount >= 1 {
            return true
        }
        
        if requiredActions.contains("smileStep") && smileDetected {
            return true
        }
        
        if requiredActions.contains("sideFaceStep") && headShakeDetected {
            return true
        }
        
        if requiredActions.contains("mouthOpenStep") && mouthOpenDetected {
            return true
        }
        
        if requiredActions.contains("frontFaceStep") && frontFaceDetected {
            return true
        }
        
        return false
    }

    // MARK: - 检查人脸是否在圆框内
    private func isFaceInCircleFrame(faceAnchor: ARFaceAnchor) -> Bool {
        // 1. 获取人脸世界坐标
        let facePosition3D = simd_make_float3(faceAnchor.transform.columns.3)
        
        // 2. 计算人脸中心到摄像头（原点）的真实距离
        let distanceToCamera = simd_length(facePosition3D)
        let minDistance: Float = 0.25   // 可根据实际场景调整
        let maxDistance: Float = 0.65
        let isDistanceOK = distanceToCamera >= minDistance && distanceToCamera <= maxDistance
        
        // 3. 判断人脸大小（通过顶点范围）
        let vertices = faceAnchor.geometry.vertices
        let vertexCount = vertices.count
        var faceSize: Float = 0.0
        var isSizeOK: Bool = false
        
        if vertexCount > 0 {
            var minX: Float = Float.greatestFiniteMagnitude
            var maxX: Float = -Float.greatestFiniteMagnitude
            var minY: Float = Float.greatestFiniteMagnitude
            var maxY: Float = -Float.greatestFiniteMagnitude
            
            for i in 0..<vertexCount {
                let vertex = vertices[i]
                minX = min(minX, vertex.x)
                maxX = max(maxX, vertex.x)
                minY = min(minY, vertex.y)
                maxY = max(maxY, vertex.y)
            }
            
            let faceWidth = maxX - minX
            let faceHeight = maxY - minY
            faceSize = max(faceWidth, faceHeight)
            
            // 可根据实际测试设备调整
            let minFaceSize: Float = 0.08
            let maxFaceSize: Float = 0.55
            isSizeOK = faceSize >= minFaceSize && faceSize <= maxFaceSize
        }

        // 4. 判断人脸中心是否落在圆框内（投影后）
        let projectedPoint = sceneView.projectPoint(SCNVector3(facePosition3D))
        let circleCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        let circleRadius = min(sceneView.bounds.width, sceneView.bounds.height) * 0.25

        let dx = CGFloat(projectedPoint.x) - circleCenter.x
        let dy = CGFloat(projectedPoint.y) - circleCenter.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        let isXYCenterOK = pixelDistance <= circleRadius

        // 5. 综合判断
        let isInFrame = isDistanceOK && isSizeOK && isXYCenterOK

        // 6. 调试日志
        print("""
        人脸检测结果：
        - 实际距离：\(String(format: "%.2f", distanceToCamera)) m （范围 \(minDistance) ~ \(maxDistance)）✅: \(isDistanceOK)
        - 人脸尺寸：\(String(format: "%.2f", faceSize)) ✅: \(isSizeOK)
        - 中心偏移：\(String(format: "%.2f", pixelDistance)) px（半径: \(circleRadius)）✅: \(isXYCenterOK)
        - 最终判断：✅ \(isInFrame)
        """)

        // 7. 更新 UI（例如圈颜色）
        updateCircleFrameColor(isInFrame: isInFrame)

        return isInFrame
    }




    // MARK: - 获取人脸位置提示信息
    private func getFacePositionHint(faceAnchor: ARFaceAnchor) -> String {
        // 获取人脸位置
        let facePosition = simd_make_float3(faceAnchor.transform.columns.3)
        let distanceToCamera = simd_length(facePosition)

        // 判断距离是否合适
        let minDistance: Float = 0.25
        let maxDistance: Float = 0.65
        let isDistanceOK = distanceToCamera >= minDistance && distanceToCamera <= maxDistance

        // 判断脸部大小
        let vertices = faceAnchor.geometry.vertices
        var faceSize: Float = 0.0

        if vertices.count > 0 {
            var minX: Float = Float.greatestFiniteMagnitude
            var maxX: Float = -Float.greatestFiniteMagnitude
            var minY: Float = Float.greatestFiniteMagnitude
            var maxY: Float = -Float.greatestFiniteMagnitude

            for vertex in vertices {
                minX = min(minX, vertex.x)
                maxX = max(maxX, vertex.x)
                minY = min(minY, vertex.y)
                maxY = max(maxY, vertex.y)
            }

            let faceWidth = maxX - minX
            let faceHeight = maxY - minY
            faceSize = max(faceWidth, faceHeight)
        }

        let minFaceSize: Float = 0.08
        let maxFaceSize: Float = 0.55
        let isSizeOK = faceSize >= minFaceSize && faceSize <= maxFaceSize

        // 判断是否在圆框中心（可选）
        let projectedPoint = sceneView.projectPoint(SCNVector3(facePosition))
        let circleCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        let radius = min(sceneView.bounds.width, sceneView.bounds.height) * 0.25
        let dx = CGFloat(projectedPoint.x) - circleCenter.x
        let dy = CGFloat(projectedPoint.y) - circleCenter.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        let isInCircle = pixelDistance <= radius

        // 提示判断顺序
        if !isDistanceOK {
            if distanceToCamera < minDistance {
                return AppLocalizedString("face_detection.move_face_closer", comment: "")
            } else {
                return AppLocalizedString("face_detection.move_face_farther", comment: "")
            }
        }

        if !isSizeOK {
            if faceSize < minFaceSize {
                return AppLocalizedString("face_detection.face_too_small", comment: "")
            } else {
                return AppLocalizedString("face_detection.face_too_large", comment: "")
            }
        }

        if !isInCircle {
            return AppLocalizedString("face_detection.align_face_in_frame", comment: "")
        }

        return AppLocalizedString("face_detection.hold_still_detecting", comment: "")
    }

    // MARK: - 更新圆框颜色（绿色/红色）
    private func updateCircleFrameColor(isInFrame: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = isInFrame ? UIColor.green : UIColor.red
            self.sceneView?.layer.borderColor = color.cgColor
            self.sceneView.layer.shadowColor = color.cgColor
        }
    }

    
    // MARK: - 设置圆框等待状态颜色
    private func setCircleFrameWaitingColor() {
        DispatchQueue.main.async {
            self.sceneView.layer.borderColor = UIColor.systemBlue.cgColor
            self.sceneView.layer.shadowColor = UIColor.systemBlue.cgColor
        }
    }

    // MARK: - 截取圆框内的图片
    private func captureCircularImage() -> UIImage? {
        if useARKit {
            // ARKit模式：使用sceneView截图
            let fullImage = sceneView.snapshot()
            return createCircularImage(from: fullImage, size: sceneView.bounds.size)
        } else {
            // Vision模式：直接对sceneView.layer做快照，确保与用户实际看到的一致（包含预览层）
            let size = sceneView.bounds.size
            let scale: CGFloat = UIScreen.main.scale
            let rendererFormat = UIGraphicsImageRendererFormat.default()
            rendererFormat.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
            let fullImage = renderer.image { ctx in
                // 使用 CALayer 渲染以包含所有子层（例如 AVCaptureVideoPreviewLayer）
                ctx.cgContext.saveGState()
                // 将 UIKit 坐标系（y 向下）转换为 Core Animation 坐标系（y 向上）
                ctx.cgContext.translateBy(x: 0, y: size.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
                sceneView.layer.render(in: ctx.cgContext)
                ctx.cgContext.restoreGState()
            }
            return createCircularImage(from: fullImage, size: size)
        }
    }
    
    // MARK: - 创建圆形图片
    private func createCircularImage(from fullImage: UIImage, size: CGSize) -> UIImage? {
        let scale: CGFloat = UIScreen.main.scale
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 绘制圆形路径
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: scaledSize))
        
        // 设置裁剪区域
        context.saveGState()
        circlePath.addClip()
        
        // 绘制原图，保持宽高比
        let imageRect = CGRect(origin: .zero, size: scaledSize)
        fullImage.draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        
        // 恢复上下文
        context.restoreGState()
        
        // 获取裁剪后的图片
        return UIGraphicsGetImageFromCurrentImageContext()
    }


    // MARK: - Vision (Fallback) — Camera setup
    private func setupVisionCaptureSession() {
        guard captureSession == nil else { return }
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            DispatchQueue.main.async { self.statusLabel.text = AppLocalizedString("face_detection.camera_unavailable", comment: "") }
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: visionQueue)
        guard session.canAddOutput(output) else {
            DispatchQueue.main.async { self.statusLabel.text = AppLocalizedString("face_detection.camera_output_unavailable", comment: "") }
            return
        }
        session.addOutput(output)

        if let connection = output.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = true
        }

        session.commitConfiguration()

        // Preview layer inside circular sceneView
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

    // MARK: - Vision helpers
    private func exifOrientationForCurrentDeviceOrientation(isFrontCamera: Bool) -> CGImagePropertyOrientation {
        // 以竖屏为主的应用场景
        return isFrontCamera ? .leftMirrored : .right
    }

    private func isFaceInCircleFrameVision(observation: VNFaceObservation) -> Bool {
        let bounds = sceneView.bounds
        guard bounds.width > 0 && bounds.height > 0 else { return false }
        let rect = observation.boundingBox
        let centerNorm = CGPoint(x: rect.origin.x + rect.size.width / 2,
                                 y: rect.origin.y + rect.size.height / 2)
        let centerPx = CGPoint(x: centerNorm.x * bounds.width,
                               y: (1 - centerNorm.y) * bounds.height) // Vision 原点在左下

        let circleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let circleRadius = min(bounds.width, bounds.height) * 0.25
        let dx = centerPx.x - circleCenter.x
        let dy = centerPx.y - circleCenter.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        let isXYCenterOK = pixelDistance <= circleRadius

        // 以框内像素高度作为远近代理
        let faceHeightPx = rect.height * bounds.height
        let minFacePx: CGFloat = 80
        let maxFacePx: CGFloat = bounds.height * 0.9
        let isSizeOK = faceHeightPx >= minFacePx && faceHeightPx <= maxFacePx

        let isInFrame = isXYCenterOK && isSizeOK
        updateCircleFrameColor(isInFrame: isInFrame)
        return isInFrame
    }

    private func getFacePositionHintVision(observation: VNFaceObservation?) -> String {
        guard let obs = observation else {
            return AppLocalizedString("face_detection.align_face_in_frame", comment: "")
        }
        let bounds = sceneView.bounds
        let rect = obs.boundingBox
        let centerNorm = CGPoint(x: rect.midX, y: rect.midY)
        let centerPx = CGPoint(x: centerNorm.x * bounds.width,
                               y: (1 - centerNorm.y) * bounds.height)

        let circleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let circleRadius = min(bounds.width, bounds.height) * 0.25
        let dx = centerPx.x - circleCenter.x
        let dy = centerPx.y - circleCenter.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        let inCircle = pixelDistance <= circleRadius

        let faceHeightPx = rect.height * bounds.height
        let minFacePx: CGFloat = 80
        let maxFacePx: CGFloat = bounds.height * 0.9

        if faceHeightPx < minFacePx {
            return AppLocalizedString("face_detection.face_too_small", comment: "")
        }
        if faceHeightPx > maxFacePx {
            return AppLocalizedString("face_detection.face_too_large", comment: "")
        }
        if !inCircle {
            return AppLocalizedString("face_detection.align_face_in_frame", comment: "")
        }
        return AppLocalizedString("face_detection.hold_still_detecting", comment: "")
    }

    private func checkLivenessVision(observation: VNFaceObservation, landmarks: VNFaceLandmarks2D?) {
        guard isDetecting else { return }
        if !lastFaceInFrame { return }
        guard currentActionIndex < requiredActions.count else { return }

        let currentAction = requiredActions[currentActionIndex]
        switch currentAction {
        case "blinkStep":
            if let lm = landmarks,
               let left = lm.leftEye,
               let right = lm.rightEye {
                let leftRatio = eyeAspectRatio(normalizedPoints: left.normalizedPoints)
                let rightRatio = eyeAspectRatio(normalizedPoints: right.normalizedPoints)
                let closed = leftRatio < 0.18 && rightRatio < 0.18
                if closed && !wasEyesClosed {
                    wasEyesClosed = true
                    eyeBlinkCount += 1
                    DispatchQueue.main.async {
                        self.statusLabel.text = String(format: AppLocalizedString("face_detection.blink_detected", comment: ""), self.eyeBlinkCount)
                        self.updateStatusLabelBasedOnRequiredActions()
                    }
                } else if !closed {
                    wasEyesClosed = false
                }
            }
        case "smileStep":
            if let lm = landmarks,
               let lips = lm.outerLips {
                let smile = smileScore(normalizedPoints: lips.normalizedPoints) > 0.15
                if smile {
                    smileDetected = true
                    DispatchQueue.main.async {
                        self.statusLabel.text = AppLocalizedString("face_detection.smile_detected", comment: "")
                        self.updateStatusLabelBasedOnRequiredActions()
                    }
                }
            }
        case "mouthOpenStep":
            if let lm = landmarks {
                let openRatio = mouthOpenRatio(landmarks: lm)
                if openRatio > 0.35 {
                    mouthOpenDetected = true
                    DispatchQueue.main.async {
                        self.statusLabel.text = AppLocalizedString("face_detection.mouth_open_detected", comment: "")
                        self.updateStatusLabelBasedOnRequiredActions()
                    }
                }
            }
        case "sideFaceStep":
            if let lm = landmarks,
               let leftEye = lm.leftEye,
               let rightEye = lm.rightEye {
                let lw = eyeWidth(normalizedPoints: leftEye.normalizedPoints)
                let rw = eyeWidth(normalizedPoints: rightEye.normalizedPoints)
                let diff = abs(lw - rw)
                if diff > 0.08 { // 眼睛宽度差异较大，视为转头
                    headShakeDetected = true
                    DispatchQueue.main.async {
                        self.statusLabel.text = AppLocalizedString("face_detection.head_movement_detected", comment: "")
                        self.updateStatusLabelBasedOnRequiredActions()
                    }
                }
            }
        case "frontFaceStep":
            if let lm = landmarks,
               let leftEye = lm.leftEye,
               let rightEye = lm.rightEye {
                let lw = eyeWidth(normalizedPoints: leftEye.normalizedPoints)
                let rw = eyeWidth(normalizedPoints: rightEye.normalizedPoints)
                let symmetry = 1 - abs(lw - rw) / max(lw, rw)
                if symmetry > 0.7 {
                    frontFaceDetected = true
                    DispatchQueue.main.async {
                        self.statusLabel.text = AppLocalizedString("face_detection.front_face_detected", comment: "")
                        self.updateStatusLabelBasedOnRequiredActions()
                    }
                } else {
                    frontFaceDetected = false
                }
            }
        default:
            break
        }


        checkCurrentActionCompletion()
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
        // 近似：两端点 y 相对于中点 y 的提升量
        let left = normalizedPoints.min(by: { $0.x < $1.x }) ?? normalizedPoints[0]
        let right = normalizedPoints.max(by: { $0.x < $1.x }) ?? normalizedPoints[0]
        let midIndex = normalizedPoints.count / 2
        let mid = normalizedPoints[midIndex]
        // Vision 原点左下，微笑时左右嘴角 y 升高
        let lift = ((left.y - mid.y) + (right.y - mid.y)) / 2
        return lift
    }

    func detectFaceOcclusion(faceAnchor: ARFaceAnchor) -> Bool {
        let blendShapes = faceAnchor.blendShapes

        // 定义遮挡判断阈值
        let eyeOcclusionThreshold: Float = 0.9
        let mouthOcclusionThreshold: Float = 0.7
        let jawOcclusionThreshold: Float = 0.1
        let cheekOcclusionThreshold: Float = 0.8

        // 提取关键参数（使用可选绑定）
        guard let leftEyeBlink = blendShapes[.eyeBlinkLeft]?.floatValue,
              let rightEyeBlink = blendShapes[.eyeBlinkRight]?.floatValue,
              let mouthClose = blendShapes[.mouthClose]?.floatValue,
              let jawOpen = blendShapes[.jawOpen]?.floatValue else {
            print("⚠️ 无法获取必要的 blendShapes 参数")
            return false
        }

        // 检查眼睛遮挡（双眼同时高值）
        if leftEyeBlink > eyeOcclusionThreshold && rightEyeBlink > eyeOcclusionThreshold {
            return true
        }

        // 检查嘴巴遮挡（嘴巴闭合且下巴不动）
        if mouthClose > mouthOcclusionThreshold && jawOpen < jawOcclusionThreshold {
            return true
        }

        // 检查脸颊遮挡（可选）
        if let cheekSquintLeft = blendShapes[.cheekSquintLeft]?.floatValue,
           let cheekSquintRight = blendShapes[.cheekSquintRight]?.floatValue,
           (cheekSquintLeft > cheekOcclusionThreshold || cheekSquintRight > cheekOcclusionThreshold) {
            return true
        }

        // 如果没有检测到遮挡，打印当前参数值（便于调试）
        print("""
        ✅ 未检测到遮挡，当前参数值：
        - 左眼眨眼: \(leftEyeBlink)
        - 右眼眨眼: \(rightEyeBlink)
        - 嘴巴闭合: \(mouthClose)
        - 下巴张开: \(jawOpen)
        - 左脸颊挤压: \(blendShapes[.cheekSquintLeft]?.floatValue ?? 0)
        - 右脸颊挤压: \(blendShapes[.cheekSquintRight]?.floatValue ?? 0)
        """)

        return false
    }

    // MARK: - Actions
    @IBAction func startDetectionTapped(_ sender: UIButton) {
        if useARKit {
            // Original ARKit logic
            isDetecting = !isDetecting
            if isDetecting {
                detectionStartTime = Date()
                eyeBlinkCount = 0
                smileDetected = false
                headShakeDetected = false
                headNodDetected = false
                mouthOpenDetected = false
                frontFaceDetected = false
                // 重置头部姿态检测
                headPitchSamples.removeAll()
                headYawSamples.removeAll()
                isNodding = false
                isShaking = false
                lastHeadPitch = 0
                lastHeadYaw = 0
                capturedImages.removeAll()

                startButton.setTitle(AppLocalizedString("face_detection.stop_verification", comment: ""), for: .normal)
                updateStatusLabelBasedOnRequiredActions()
                startFaceStatusTimer()
            } else {
                startButton.setTitle(AppLocalizedString("face_detection.start_verification", comment: ""), for: .normal)
                statusLabel.text = AppLocalizedString("face_detection.verification_stopped", comment: "")
                cancelFaceStatusTimer()
            }
        } else {
            // Non-ARKit: Manual capture
            if startButton.title(for: .normal) == AppLocalizedString("face_detection.capture_photo", comment: "") {
                visionDetector?.captureManually()
            }
        }
    }

    func closeWithResult() {
        completionHandler?(["images": capturedImages, "useARKit": useARKit ? 3 : 2])
        dismiss(animated: true)
    }

    private func updateStatusLabelBasedOnRequiredActions(faceInFrame: Bool? = nil) {
        let inFrame = faceInFrame ?? lastFaceInFrame
        if !inFrame {
            // 如果有当前人脸锚点，提供更具体的提示
            if useARKit {
                if let currentFrame = sceneView.session.currentFrame,
                   let faceAnchor = currentFrame.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor {
                    let hint = getFacePositionHint(faceAnchor: faceAnchor)
                    DispatchQueue.main.async { self.statusLabel.text = hint }
                } else {
                    DispatchQueue.main.async { self.statusLabel.text = AppLocalizedString("face_detection.align_face_in_frame", comment: "") }
                }
            } else {
                let hint = getFacePositionHintVision(observation: lastVisionObservation)
                DispatchQueue.main.async { self.statusLabel.text = hint }
            }
            return // 直接返回，后续不再设置动作提示
        }
        // 如果所有动作都已完成
        if currentActionIndex >= requiredActions.count {
            DispatchQueue.main.async {
                self.statusLabel.text = AppLocalizedString("face_detection.verification_completed", comment: "")
            }
            // 回调Flutter
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.closeWithResult()
            }
            return
        }

        // 获取当前需要检测的动作
        let currentAction = requiredActions[currentActionIndex]

        // 根据当前动作显示提示
        var instruction = ""
        switch currentAction {
            case "blinkStep":
                instruction = AppLocalizedString("face_detection.blink_instruction", comment: "")
            case "smileStep":
                instruction = AppLocalizedString("face_detection.smile_instruction", comment: "")
            case "sideFaceStep":
                instruction = AppLocalizedString("face_detection.turn_head_instruction", comment: "")
            case "mouthOpenStep":
                instruction = AppLocalizedString("face_detection.open_mouth_instruction", comment: "")
            case "frontFaceStep":
                instruction = AppLocalizedString("face_detection.look_directly_instruction", comment: "")
            default:
                instruction = AppLocalizedString("face_detection.follow_instructions", comment: "")
        }
        DispatchQueue.main.async {
            self.statusLabel.text = instruction
        }
    }

    // MARK: - 修改后的活体检测方法
    private func checkLiveness(using faceAnchor: ARFaceAnchor) {
        guard isDetecting else { return }
        
        // 注意：faceInFrame已经在renderer中设置，这里不需要重复检测
        if !lastFaceInFrame {
            return // 如果人脸不在框内，直接返回，不进行任何检测
        }

        // 随机捕获图片
//        if currentActionIndex > 0 {
//            captureFaceImage()
//        }
        
        // 如果所有动作都已完成，直接返回
        if currentActionIndex >= requiredActions.count {
            return
        }

        let blendShapes = faceAnchor.blendShapes
        let currentAction = requiredActions[currentActionIndex]

        switch currentAction {
        case "blinkStep":
            checkEyeBlink(blendShapes: blendShapes)
        case "smileStep":
            checkSmile(blendShapes: blendShapes)
        case "sideFaceStep":
            checkHeadShake(faceAnchor: faceAnchor)
        case "mouthOpenStep":
            checkMouthOpen(blendShapes: blendShapes)
        case "frontFaceStep":
            checkFrontFace(faceAnchor: faceAnchor)
        default:
            break
        }
      
        // 检查当前动作是否完成
        checkCurrentActionCompletion()
    }

    // 检查当前动作是否完成
    private func checkCurrentActionCompletion() {
        // 新增：如果人脸不在框内，直接return，不检测动作完成
        if !lastFaceInFrame {
            return
        }
        guard currentActionIndex < requiredActions.count else { return }

        let currentAction = requiredActions[currentActionIndex]
        var isCompleted = false

        switch currentAction {
        case "blinkStep":
            isCompleted = eyeBlinkCount >= 1
        case "smileStep":
            isCompleted = smileDetected
        case "sideFaceStep":
            isCompleted = headShakeDetected
        case "mouthOpenStep":
            isCompleted = mouthOpenDetected
        case "frontFaceStep":
            isCompleted = frontFaceDetected
        default:
            break
        }

        if isCompleted {
            // 当前动作完成，准备下一个动作
            moveToNextAction()
        }
    }

    // 移动到下一个检测动作
    private func moveToNextAction() {
        currentActionIndex += 1

        // 重置下一个动作的检测状态
        if currentActionIndex < requiredActions.count {
            let nextAction = requiredActions[currentActionIndex]

            switch nextAction {
            case "blinkStep":
                eyeBlinkCount = 0
            case "smileStep":
                smileDetected = false
            case "sideFaceStep":
                headShakeDetected = false
                headYawSamples.removeAll()
                isShaking = false
            case "mouthOpenStep":
                mouthOpenDetected = false
            case "frontFaceStep":
                frontFaceDetected = false
            default:
                break
            }
        }

        // 更新提示
        updateStatusLabelBasedOnRequiredActions()

        // 检查是否所有动作都已完成
        if currentActionIndex >= requiredActions.count {
            checkAllActionsCompleted()
        }
    }

    private func checkEyeBlink(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let blinkThreshold: Float = 0.5

        if let leftEyeBlink = blendShapes[.eyeBlinkLeft] as? Float,
           leftEyeBlink > blinkThreshold,
           let rightEyeBlink = blendShapes[.eyeBlinkRight] as? Float,
           rightEyeBlink > blinkThreshold {

            eyeBlinkCount += 1
            if lastFaceInFrame {
                DispatchQueue.main.async {
                    self.statusLabel.text = String(format: AppLocalizedString("face_detection.blink_detected", comment: ""), self.eyeBlinkCount)
                    self.updateStatusLabelBasedOnRequiredActions()
                }
            }
        }
    }

    private func checkSmile(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let smileThreshold: Float = 0.3

        if let smile = blendShapes[.mouthSmileLeft] as? Float,
           smile > smileThreshold {
            smileDetected = true
            if lastFaceInFrame {
                DispatchQueue.main.async {
                    self.statusLabel.text = AppLocalizedString("face_detection.smile_detected", comment: "")
                    self.updateStatusLabelBasedOnRequiredActions()
                }
            }
        }
    }

    private func checkHeadShake(faceAnchor: ARFaceAnchor) {
        // 获取当前头部yaw角度(左右摇头)
        let currentYaw = faceAnchor.transform.eulerAngles.y

        // 保存样本数据
        headYawSamples.append(currentYaw)
        if headYawSamples.count > sampleWindowSize {
            headYawSamples.removeFirst()
        }

        // 需要足够的样本才能开始检测
        guard headYawSamples.count >= 10 else { return }

        // 计算角度变化幅度
        let maxYaw = headYawSamples.max() ?? 0
        let minYaw = headYawSamples.min() ?? 0
        let yawRange = abs(maxYaw - minYaw)

        // 检测阈值，弧度
        let shakeThreshold: Float = 0.3

        // 调试输出
        print("摇头幅度: \(yawRange), 当前yaw: \(currentYaw)")

                if yawRange > shakeThreshold {
            if !isShaking {
                isShaking = true
                headShakeDetected = true
                if lastFaceInFrame {
                    DispatchQueue.main.async {
                        self.statusLabel.text = AppLocalizedString("face_detection.head_movement_detected", comment: "")
                        self.updateStatusLabelBasedOnRequiredActions()
                    }
                }
            }
        } else {
            isShaking = false
        }

        lastHeadYaw = currentYaw
    }

    private func checkHeadNod(faceAnchor: ARFaceAnchor) {
        // 获取当前头部pitch角度(上下点头)
        let currentPitch = faceAnchor.transform.eulerAngles.x

        // 保存样本数据
        headPitchSamples.append(currentPitch)
        if headPitchSamples.count > sampleWindowSize {
            headPitchSamples.removeFirst()
        }

        // 需要足够的样本才能开始检测
        guard headPitchSamples.count >= 10 else { return }

        // 计算角度变化幅度
        let maxPitch = headPitchSamples.max() ?? 0
        let minPitch = headPitchSamples.min() ?? 0
        let pitchRange = abs(maxPitch - minPitch)

        // 检测阈值，弧度
        let nodThreshold: Float = 0.2

        // 调试输出
        print("点头幅度: \(pitchRange), 当前pitch: \(currentPitch)")

        if pitchRange > nodThreshold {
            if !isNodding {
                isNodding = true
                headNodDetected = true
                DispatchQueue.main.async {
                    self.statusLabel.text = AppLocalizedString("face_detection.head_nod_detected", comment: "")
                    self.updateStatusLabelBasedOnRequiredActions()
                }
            }
        } else {
            isNodding = false
        }

        lastHeadPitch = currentPitch
    }

    private func checkMouthOpen(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let mouthOpenThreshold: Float = 0.3

        if let jawOpen = blendShapes[.jawOpen] as? Float,
           jawOpen > mouthOpenThreshold {
            mouthOpenDetected = true
            if lastFaceInFrame {
                DispatchQueue.main.async {
                    self.statusLabel.text = AppLocalizedString("face_detection.mouth_open_detected", comment: "")
                    self.updateStatusLabelBasedOnRequiredActions()
                }
            }
        }
    }

    private func checkFrontFace(faceAnchor: ARFaceAnchor) {
        // 用 SCNNode 获取欧拉角
        let faceNode = SCNNode()
        faceNode.simdTransform = faceAnchor.transform
        let eulerAngles = faceNode.eulerAngles  // 单位为“弧度”

        // 弧度 → 角度（方便调试）
        let yawDegrees = eulerAngles.y * 180 / .pi
        let pitchDegrees = eulerAngles.x * 180 / .pi
        let rollDegrees = eulerAngles.z * 180 / .pi

        // 正脸判定阈值（角度）
        let yawThreshold: Float = 25
        let pitchThreshold: Float = 28
        let rollThreshold: Float = 25

        let isYawInRange = abs(yawDegrees) < yawThreshold
        let isPitchInRange = abs(pitchDegrees) < pitchThreshold
        let isRollInRange = abs(rollDegrees) < rollThreshold

        let isInFrame = isFaceInCircleFrame(faceAnchor: faceAnchor)

        print("正脸检测：Yaw \(yawDegrees)°, Pitch \(pitchDegrees)°, Roll \(rollDegrees)°")
        print("范围状态：Yaw: \(isYawInRange), Pitch: \(isPitchInRange), Roll: \(isRollInRange), InFrame: \(isInFrame)")

        if isYawInRange && isPitchInRange && isRollInRange && isInFrame {
            if !frontFaceDetected {
                frontFaceDetected = true
                DispatchQueue.main.async {
                    self.statusLabel.text = AppLocalizedString("face_detection.front_face_detected", comment: "")
                    self.updateStatusLabelBasedOnRequiredActions()
                }
            }
        } else {
            frontFaceDetected = false
        }
    }

    private func checkAllActionsCompleted() {
        var allCompleted = true

        if requiredActions.contains("blinkStep") && eyeBlinkCount < 1 {
            allCompleted = false
        }

        if requiredActions.contains("smileStep") && !smileDetected {
            allCompleted = false
        }

        if requiredActions.contains("sideFaceStep") && !headShakeDetected {
            allCompleted = false
        }

        if requiredActions.contains("mouthOpenStep") && !mouthOpenDetected {
            allCompleted = false
        }

        if requiredActions.contains("frontFaceStep") && !frontFaceDetected {
            allCompleted = false
        }

        if allCompleted {
            // 所有步骤完成的瞬间抓取一次
            if capturedImages.isEmpty {
                captureFaceImage()
            }
            DispatchQueue.main.async {
                self.statusLabel.text = AppLocalizedString("face_detection.liveness_verification_completed", comment: "")
                self.isDetecting = false
                self.startButton.setTitle(AppLocalizedString("face_detection.start_verification", comment: ""), for: .normal)
                self.cancelTimeoutTimer()
            }
        }
    }

    private func startFaceDetection() {
        if useARKit {
            // Original ARKit logic
            isDetecting = true
            detectionStartTime = Date()
            eyeBlinkCount = 0
            smileDetected = false
            headShakeDetected = false
            headNodDetected = false
            mouthOpenDetected = false
            frontFaceDetected = false
            headPitchSamples.removeAll()
            headYawSamples.removeAll()
            isNodding = false
            isShaking = false
            lastHeadPitch = 0
            lastHeadYaw = 0
            capturedImages.removeAll()
            startButton.setTitle(AppLocalizedString("face_detection.stop_verification", comment: ""), for: .normal)
            updateStatusLabelBasedOnRequiredActions()
            startTimeoutTimer()
            startFaceStatusTimer()
            
            // 重置圆框颜色为等待状态
            setCircleFrameWaitingColor()
        } else {
            // Non-ARKit: Vision detector handles everything
            // Button remains hidden until front face is detected
        }
    }

    // 启动超时定时器
    private func startTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            self?.handleTimeout()
        }
    }

    // 取消超时定时器
    private func cancelTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    // 启动人脸状态监测定时器
    private func startFaceStatusTimer() {
        faceStatusTimer?.invalidate()
        faceStatusTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkFaceStatus()
        }
    }
    
    // 取消人脸状态监测定时器
    private func cancelFaceStatusTimer() {
        faceStatusTimer?.invalidate()
        faceStatusTimer = nil
    }
    
    // 检查人脸状态
    private func checkFaceStatus() {
        guard isDetecting else { return }
        if useARKit {
            // 检查当前是否有活跃的人脸锚点
            let hasActiveFace = sceneView.session.currentFrame?.anchors.contains { $0 is ARFaceAnchor } ?? false
            if !hasActiveFace && lastFaceInFrame {
                print("人脸离开检测区域")
                lastFaceInFrame = false
                updateStatusLabelBasedOnRequiredActions(faceInFrame: false)
                updateCircleFrameColor(isInFrame: false)
            }
        } else {
            // Vision 模式下，lastFaceInFrame 在每帧回调中维护；此处无需额外处理
            return
        }
    }

    // 超时处理
    private func handleTimeout() {
        DispatchQueue.main.async {
            self.isDetecting = false
            self.statusLabel.text = AppLocalizedString("face_detection.verification_timeout", comment: "")
            self.completionHandler?([:]) // 返回空数组表示失败
            self.dismiss(animated: true)
        }
    }
}

extension FaceDetectionViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }

        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)

        // 移除网格显示（注释掉或删除以下两行）
        // faceNode.geometry?.firstMaterial?.fillMode = .lines
        // faceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white

        // 设置为透明材质
        faceNode.geometry?.firstMaterial?.isDoubleSided = true
        faceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear

        self.faceNode = faceNode
        return faceNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }

        faceGeometry.update(from: faceAnchor.geometry)
        let faceInFrame = isFaceInCircleFrame(faceAnchor: faceAnchor)
        
        // 调试：输出人脸状态变化
        if faceInFrame != lastFaceInFrame {
            print("人脸状态变化: \(lastFaceInFrame) -> \(faceInFrame)")
        }
        
        lastFaceInFrame = faceInFrame
        
        // 先更新状态提示，确保人脸离开时能立即切换提示
        updateStatusLabelBasedOnRequiredActions(faceInFrame: faceInFrame)
        
        // 只有在检测状态下才进行活体检测
        if isDetecting {
            checkLiveness(using: faceAnchor)
        }
    }
}

// MARK: - Vision sample buffer handling (Legacy - only used if VisionLivenessDetector is not used)
extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Only use legacy Vision if not using VisionLivenessDetector
        guard !useARKit, isDetecting, visionDetector == nil else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest { [weak self] req, err in
            guard let self = self else { return }
            if let err = err {
                let errorMsg = String(format: AppLocalizedString("face_detection.vision_error", comment: ""), err.localizedDescription)
                print(errorMsg)
                return
            }
            guard let results = req.results as? [VNFaceObservation], let face = results.first else {
                if self.lastFaceInFrame {
                    self.lastFaceInFrame = false
                    DispatchQueue.main.async {
                        self.updateStatusLabelBasedOnRequiredActions(faceInFrame: false)
                        self.updateCircleFrameColor(isInFrame: false)
                    }
                }
                return
            }

            self.lastVisionObservation = face
            let inFrame = self.isFaceInCircleFrameVision(observation: face)
            if self.lastFaceInFrame != inFrame {
                self.lastFaceInFrame = inFrame
            }

            if inFrame {
                self.checkLivenessVision(observation: face, landmarks: face.landmarks)
            } else {
                DispatchQueue.main.async {
                    self.updateStatusLabelBasedOnRequiredActions(faceInFrame: false)
                }
            }
        }

        let orientation = exifOrientationForCurrentDeviceOrientation(isFrontCamera: true)
        do {
            try visionRequestHandler.perform([request], on: pixelBuffer, orientation: orientation)
        } catch {
            print("Vision perform error: \(error)")
        }
    }
}

extension float4x4 {
    var eulerAngles: SIMD3<Float> {
        // 提取旋转矩阵部分
        let m11 = self.columns.0.x
        let m12 = self.columns.0.y
        let m13 = self.columns.0.z
        let m21 = self.columns.1.x
        let m22 = self.columns.1.y
        let m23 = self.columns.1.z
        let m31 = self.columns.2.x
        let m32 = self.columns.2.y
        let m33 = self.columns.2.z

        // 计算pitch (上下点头)
        let pitch = atan2(-m23, sqrt(m21 * m21 + m22 * m22))

        // 计算yaw (左右摇头)
        let yaw = atan2(m13, m33)

        // 计算roll (头部倾斜)
        let roll = atan2(m12, m11)

        return SIMD3<Float>(pitch, yaw, roll)
    }
}
