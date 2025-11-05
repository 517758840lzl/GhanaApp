import Flutter
import UIKit
import StoreKit
import Vision
import VisionKit

public class AppstoreInfoPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {
    private var methodChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appstore_info", binaryMessenger: registrar.messenger())
        let instance = AppstoreInfoPlugin()
        instance.methodChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "presentAppStore":
            if let arguments = call.arguments as? [String: Any],
               let appID = arguments["appID"] as? String {
                presentAppStore(appID: appID, result: result)
            } else {
                result(FlutterError(code: "INVALID_PARAMETERS", message: "Invalid parameters", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func presentAppStore(appID: String, result: @escaping FlutterResult) {
        let storeProductViewController = SKStoreProductViewController()
        storeProductViewController.delegate = self
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appID]

        storeProductViewController.loadProduct(withParameters: parameters) { (loaded, error) -> Void in
            if loaded {
                if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                    rootViewController.present(storeProductViewController, animated: true) {
                        // 延迟截图，确保界面完全加载
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                            self.captureAndRecognizeText(from: storeProductViewController)
                        }
                    }
                    result(true)
                } else {
                    print("Error: Unable to find root view controller.")
                    result(false)
                }
            } else {
                if let error = error {
                    print("Error loading product: \(error.localizedDescription)")
                } else {
                    print("Unknown error loading product.")
                }
                result(false)
            }
        }
    }

    // Implementing the delegate method
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // 截图并识别文字
    private func captureAndRecognizeText(from viewController: SKStoreProductViewController) {
        // 截图
        guard let window = UIApplication.shared.keyWindow else {
            print("无法获取keyWindow")
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
           window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
           guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
               UIGraphicsEndImageContext()
               return
           }
           UIGraphicsEndImageContext()
        
        // 使用Vision框架识别文字
        recognizeText(from: image)
    }
    
    // 使用Vision框架识别图片中的文字
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("无法获取CGImage")
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                print("文字识别错误: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("无法获取识别结果")
                return
            }
            
            var recognizedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    continue
                }
                recognizedText += topCandidate.string + "\n"
            }
            
            print("识别到的文字: \(recognizedText)")
            
            // 将识别结果发送回Flutter
            DispatchQueue.main.async {
                self?.sendRecognizedTextToFlutter(recognizedText)
            }
        }
        
        // 设置识别参数
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("执行文字识别请求失败: \(error.localizedDescription)")
        }
    }
    
    // 将识别结果发送回Flutter
    private func sendRecognizedTextToFlutter(_ text: String) {
        guard let channel = methodChannel else {
            print("MethodChannel未初始化")
            return
        }
        
        channel.invokeMethod("onTextRecognized", arguments: ["recognizedText": text])
    }
}
