import Flutter
import UIKit
import ARKit
import SceneKit

public class FaceLivenessPlugin: NSObject, FlutterPlugin {
  private var faceDetectionVC: FaceDetectionViewController?
  private var result: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.example.face_liveness/channel",
      binaryMessenger: registrar.messenger())
    let instance = FaceLivenessPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result

        if call.method == "startFaceDetection" {
            guard let args = call.arguments as? [String: Any],
                  let actions = args["actions"] as? [String] else {
                result(FlutterError(code: "INVALID_ARGS",
                                  message: "Invalid arguments",
                                  details: nil))
                return
            }

            // 关键修改：获取顶层控制器（不强制转换为FlutterViewController）
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                let storyboard = UIStoryboard(name: "FaceLiveness", bundle: nil)
                if let faceVC = storyboard.instantiateViewController(
                    withIdentifier: "FaceDetectionViewController") as? FaceDetectionViewController {

                    faceVC.requiredActions = actions
                    faceVC.completionHandler = { [weak self] result in
                        self?.result?(result)
                        rootVC.dismiss(animated: true)
                    }

                    faceVC.modalPresentationStyle = .fullScreen
                    rootVC.present(faceVC, animated: true)
                }
            }
        }
    }

  private func startFaceDetection(actions: [String]) {
    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
      result?(FlutterError(code: "NO_ROOT_VC",
                          message: "No root view controller",
                          details: nil))
      return
    }

    let storyboard = UIStoryboard(name: "FaceLiveness", bundle: nil)
    guard let faceVC = storyboard.instantiateViewController(
      withIdentifier: "FaceDetectionViewController") as? FaceDetectionViewController else {
      result?(FlutterError(code: "NO_VC",
                          message: "Could not instantiate FaceDetectionViewController",
                          details: nil))
      return
    }

    faceVC.requiredActions = actions
    faceVC.completionHandler = { [weak self] result in
      self?.result?(result)
      rootViewController.dismiss(animated: true)
    }

    faceVC.modalPresentationStyle = .fullScreen
    rootViewController.present(faceVC, animated: true)
  }
}
