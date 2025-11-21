import 'dart:io';
import 'dart:math';
import '../../common/logger/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import '../../utils/image/image_util.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({Key? key}) : super(key: key);

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

// 活体动作类型 --眨眼、微笑smile、侧脸、张嘴、正脸
enum LivenessAction {
  blinkStep,
  smileStep,
  sideFaceStep,
  mouthOpenStep,
  frontFaceStep,
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   CameraController? _controller;
//   bool _isPopping = false;
//   FaceDetector? _faceDetector;
//   bool _isDetecting = false;
//   bool _isCameraInitialized = false;
//   Size? _imageSize;
//   List<Face> _faces = [];
//   double _detectionConfidence = 0.0;
//   bool _isLive = false; //活体认证状态
//   CameraDescription? _cameraDescription;
//   List<String> _capturedImagePaths = [];
//
//   // 动作序列相关
//   List<LivenessAction> _actionSequence = [];
//   int _currentActionIndex = 0;
//   late LivenessAction _currentAction;
//   bool _currentActionCompleted = false;
//   bool _allActionsCompleted = false;
//
//   // 眨眼状态
//   bool _wasLeftEyeClosed = false;
//   bool _wasRightEyeClosed = false;
//   DateTime _leftEyeClosedTime = DateTime.now();
//   DateTime _rightEyeClosedTime = DateTime.now();
//   // 微笑状态
//   bool _wasSmiling = false;
//   int _smileFrameCount = 0;
//   DateTime _smileStartTime = DateTime.now();
//   // 头部动作状态
//   // 存储历史面部特征点数据
//   List<List<Offset>> _faceLandmarksHistory = [];
//   // 存储历史头部角度数据
//   List<double> _headPitchHistory = [];
//   // 点头状态机：0-等待开始，1-向上抬头，2-向下点头
//   int _nodState = 0;
//   // 上次状态时间
//   DateTime _lastStateTime = DateTime.now();
//   List<Point<int>> _headPositions = [];
//   bool _faceTooSmall = false; // 人脸是否太远
//   double _faceSizeRatio = 0.0; // 人脸占画面比例
//   bool _faceInFrame = false; // 人脸是否在指定框框内
//   bool _imageCaptured = false; // 是否已经采集过图片
//   int _frontFaceFrameCount = 0; // 正脸检测连续帧数
//   DateTime _frontFaceStartTime = DateTime.now(); // 正脸检测开始时间
//   int _validFrameCount = 0; // 连续满足条件的帧数计数器
//
//   final _orientations = {
//     DeviceOrientation.portraitUp: 0,
//     DeviceOrientation.landscapeLeft: 90,
//     DeviceOrientation.portraitDown: 180,
//     DeviceOrientation.landscapeRight: 270,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeActionSequence();
//     _initializeCamera();
//     _initializeFaceDetector();
//     // 60秒超时自动返回空数组
//     Future.delayed(Duration(seconds: 120), () {
//       if (mounted && _capturedImagePaths.isEmpty) Navigator.pop(context, []);
//     });
//   }
//
//   // 初始化动作序列
//   void _initializeActionSequence() {
//     final args = Get.arguments ?? {};
//     final List<String> faceLiveSteps =
//         (args['faceLiveSteps'] ?? []) is List<String>
//             ? args['faceLiveSteps']
//             : List<String>.from(args['faceLiveSteps'] ?? []);
//
//     if (faceLiveSteps.isNotEmpty) {
//       // 将字符串动作转换为枚举
//       for (String action in faceLiveSteps) {
//         switch (action.toLowerCase()) {
//           case 'blinkstep':
//             _actionSequence.add(LivenessAction.blinkStep);
//             break;
//           case 'smilestep':
//             _actionSequence.add(LivenessAction.smileStep);
//             break;
//           case 'sidefacestep':
//             _actionSequence.add(LivenessAction.sideFaceStep);
//             break;
//           case 'mouthopenstep':
//             _actionSequence.add(LivenessAction.mouthOpenStep);
//             break;
//           case 'frontfacestep':
//             _actionSequence.add(LivenessAction.frontFaceStep);
//             break;
//           default:
//             // 默认添加眨眼动作
//             _actionSequence.add(LivenessAction.blinkStep);
//         }
//       }
//     } else {
//       // 如果没有传入动作序列，使用默认动作
//       _actionSequence = [LivenessAction.blinkStep];
//     }
//
//     _currentAction = _actionSequence[0];
//   }
//
//   // 切换到下一个动作
//   void _moveToNextAction() {
//     if (_currentActionIndex < _actionSequence.length - 1) {
//       _currentActionIndex++;
//       _currentAction = _actionSequence[_currentActionIndex];
//       _resetActionStates();
//       _currentActionCompleted = false;
//       setState(() {});
//     } else {
//       // 所有动作完成
//       _allActionsCompleted = true;
//       _currentActionCompleted = true;
//       setState(() {});
//     }
//   }
//
//   // 重置动作状态
//   void _resetActionStates() {
//     _wasLeftEyeClosed = false;
//     _wasRightEyeClosed = false;
//     _wasSmiling = false;
//     _smileFrameCount = 0;
//     _headPositions.clear();
//   }
//
//   // 初始化相机
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//     );
//     _cameraDescription = frontCamera;
//     _controller = CameraController(
//       frontCamera,
//       ResolutionPreset.high,
//       enableAudio: false,
//       imageFormatGroup:
//           Platform.isAndroid
//               ? ImageFormatGroup.nv21
//               : ImageFormatGroup.bgra8888,
//     );
//     await _controller!.initialize();
//     _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
//     // 获取图像尺寸
//     _imageSize = Size(
//       _controller!.value.previewSize!.height,
//       _controller!.value.previewSize!.width,
//     );
//     setState(() {
//       _isCameraInitialized = true;
//     });
//     // 开始处理相机流
//     _startImageStream();
//   }
//
//   // 初始化人脸检测器
//   void _initializeFaceDetector() {
//     final options = FaceDetectorOptions(
//       enableClassification: true, // 启用面部分类（微笑、睁眼等）
//       enableLandmarks: true, // 启用面部特征点
//       enableContours: true, // 启用面部轮廓
//       minFaceSize: 0.5, // 最小检测人脸大小（占画面比例）
//       performanceMode: FaceDetectorMode.accurate, // 精确模式
//     );
//
//     _faceDetector = FaceDetector(options: options);
//   }
//
//   // 开始处理相机流
//   void _startImageStream() {
//     _controller!.startImageStream((CameraImage image) async {
//       if (_isDetecting) return;
//       _isDetecting = true;
//
//       try {
//         await _processCameraImage(image);
//       } catch (e) {
//       } finally {
//         _isDetecting = false;
//       }
//     });
//   }
//
//   // 处理相机图像
//   Future<void> _processCameraImage(CameraImage image) async {
//     final inputImage = _inputImageFromCameraImage(image);
//     if (inputImage == null) {
//       return;
//     }
//     final List<Face> faces = await _faceDetector!.processImage(inputImage);
//
//     // 人脸大小检测
//     double faceRatio = 0.0;
//     if (faces.isNotEmpty && _imageSize != null) {
//       final face = faces.first;
//       final faceRect = face.boundingBox;
//       final faceArea = faceRect.width * faceRect.height;
//       final imageArea = _imageSize!.width * _imageSize!.height;
//       faceRatio = faceArea / imageArea;
//     }
//     // 阈值可根据实际调整，0.12~0.18较合适
//     bool tooSmall = faces.isEmpty || faceRatio < 0.16;
//
//     if (mounted) {
//       // 检查人脸是否在框内
//       bool faceInFrame = faces.isNotEmpty ? _isFaceInFrame(faces.first) : false;
//
//       setState(() {
//         _faces = faces;
//         _detectionConfidence =
//             faces.isNotEmpty
//                 ? (faces.first.leftEyeOpenProbability ?? 0.0)
//                 : 0.0;
//         _faceTooSmall = tooSmall;
//         _faceSizeRatio = faceRatio;
//         _faceInFrame = faceInFrame;
//         _isLive =
//             !_faceTooSmall && faceInFrame && _analyzeFacesForLiveness(faces);
//       });
//
//       // 检测到当前动作完成
//       if (_isLive && !_currentActionCompleted) {
//         _currentActionCompleted = true;
//         _moveToNextAction();
//       }
// if (_allActionsCompleted && _capturedImagePaths.isNotEmpty && !_isPopping) {
// _isPopping = true; // 防止重复进入
// Navigator.pop(context, _capturedImagePaths);
// }
//
//
//     }
//   }
//
//   // YUV_420_888转NV21
//   Uint8List yuv420ToNv21(CameraImage image) {
//     final int width = image.width;
//     final int height = image.height;
//     final int ySize = width * height;
//     final int uvSize = width * height ~/ 2;
//     final Uint8List nv21 = Uint8List(ySize + uvSize);
//
//     // Y plane
//     int index = 0;
//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         nv21[index++] =
//             image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
//       }
//     }
//
//     // VU plane (NV21: VU interleaved)
//     final int uvRowStride = image.planes[2].bytesPerRow;
//     final int uvPixelStride = image.planes[2].bytesPerPixel!;
//     for (int y = 0; y < height ~/ 2; y++) {
//       for (int x = 0; x < width / 2; x++) {
//         final int vuIndex = y * uvRowStride + x * uvPixelStride;
//         nv21[index++] = image.planes[2].bytes[vuIndex]; // V
//         nv21[index++] = image.planes[1].bytes[vuIndex]; // U
//       }
//     }
//     return nv21;
//   }
//
//   // 将相机图像转换为ML Kit输入格式
//   InputImage? _inputImageFromCameraImage(CameraImage image) {
//     if (_controller == null) return null;
//
//     final camera = _cameraDescription;
//     final sensorOrientation = camera!.sensorOrientation;
//     InputImageRotation rotation = InputImageRotation.rotation0deg;
//     if (Platform.isAndroid) {
//       var rotationCompensation =
//           _orientations[_controller!.value.deviceOrientation] ?? 0;
//       if (camera.lensDirection == CameraLensDirection.front) {
//         rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//       } else {
//         rotationCompensation =
//             (sensorOrientation - rotationCompensation + 360) % 360;
//       }
//       rotation =
//           InputImageRotationValue.fromRawValue(rotationCompensation) ??
//           InputImageRotation.rotation0deg;
//     } else if (Platform.isIOS) {
//       rotation =
//           InputImageRotationValue.fromRawValue(sensorOrientation) ??
//           InputImageRotation.rotation0deg;
//     }
//
//     Uint8List bytes;
//     InputImageFormat format;
//     int bytesPerRow;
//
//     if (Platform.isAndroid &&
//         image.format.raw == 35 &&
//         image.planes.length == 3) {
//       // YUV_420_888
//       bytes = yuv420ToNv21(image);
//       format = InputImageFormat.nv21;
//       bytesPerRow = image.width;
//     } else if (Platform.isAndroid &&
//         image.format.raw == 17 &&
//         image.planes.length == 1) {
//       // NV21
//       bytes = image.planes.first.bytes;
//       format = InputImageFormat.nv21;
//       bytesPerRow = image.planes.first.bytesPerRow;
//     } else if (Platform.isIOS && image.format.raw == 1111970369) {
//       // BGRA8888
//       final WriteBuffer allBytes = WriteBuffer();
//       for (final Plane plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       bytes = allBytes.done().buffer.asUint8List();
//       format = InputImageFormat.bgra8888;
//       bytesPerRow = image.planes.first.bytesPerRow;
//     } else {
//       LogUtil.d(
//         '不支持的图片格式: \\${image.format.raw}, planes: \\${image.planes.length}',
//       );
//       return null;
//     }
//
//     final Size imageSize = Size(
//       image.width.toDouble(),
//       image.height.toDouble(),
//     );
//     final inputImageData = InputImageMetadata(
//       size: imageSize,
//       rotation: rotation,
//       format: format,
//       bytesPerRow: bytesPerRow,
//     );
//
//     return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
//   }
//
//   // 检查人脸是否在指定框框内
//   bool _isFaceInFrame(Face face) {
//     if (_imageSize == null) return false;
//
//     final double frameSize = min(_imageSize!.width, _imageSize!.height) * 0.8;
//     final double frameLeft = (_imageSize!.width - frameSize) / 2;
//     final double frameTop = (_imageSize!.height - frameSize) / 2;
//     final double frameRight = frameLeft + frameSize;
//     final double frameBottom = frameTop + frameSize;
//
//     final Rect faceRect = face.boundingBox;
//
//     // 人脸中心点
//     final double faceCenterX = faceRect.center.dx;
//     final double faceCenterY = faceRect.center.dy;
//
//     // 判定中心点在框里（必须）
//     final bool centerInside =
//         faceCenterX >= frameLeft &&
//             faceCenterX <= frameRight &&
//             faceCenterY >= frameTop &&
//             faceCenterY <= frameBottom;
//
//     // 边界宽松判定：允许人脸稍微超出 10%
//     final double margin = frameSize * 0.2;
//     final bool roughlyInside =
//         faceRect.left >= frameLeft - margin &&
//             faceRect.top >= frameTop - margin &&
//             faceRect.right <= frameRight + margin &&
//             faceRect.bottom <= frameBottom + margin;
//
//     // 检查人脸大小
//     final double faceArea = faceRect.width * faceRect.height;
//     final double frameArea = frameSize * frameSize;
//     final double faceRatio = faceArea / frameArea;
//     final bool sizeAppropriate = faceRatio >= 0.1 && faceRatio <= 0.8;
//
//     return centerInside && roughlyInside && sizeAppropriate;
//   }
//
//
//
//   // 分析人脸判断是否为活体
//   bool _analyzeFacesForLiveness(List<Face> faces) {
//     if (faces.isEmpty) return false;
//     final face = faces.first;
//
//     // 首先检查人脸是否在指定框框内
//     if (!_isFaceInFrame(face)) {
//       return false;
//     }
//
//     // 头部位置检测
//     final noseBase = face.landmarks[FaceLandmarkType.noseBase]?.position;
//     if (noseBase != null) {
//       _headPositions.add(noseBase);
//       if (_headPositions.length > 10) {
//         _headPositions.removeAt(0);
//       }
//     }
//
//     // 独立检测：当人脸在框内且为正脸时，进行图片采集
//     // 必须连续3次满足条件才进行采集
//     if (faces.isNotEmpty && !_imageCaptured) {
//       _validFrameCount++;
//       if (_validFrameCount == 3) {
//         _captureImages(1);
//       }
//     } else {
//       // 如果条件不满足，重置计数器
//       _validFrameCount = 0;
//     }
//
//     switch (_currentAction) {
//       case LivenessAction.blinkStep:
//         return _detectBlink(face);
//       case LivenessAction.smileStep:
//         return _detectSmile(face);
//       case LivenessAction.sideFaceStep:
//         return _detectSideFace();
//       case LivenessAction.mouthOpenStep:
//         return _detectMouthOpen(face);
//       case LivenessAction.frontFaceStep:
//         return _detectFrontFace(face);
//     }
//   }
//
//   bool _detectBlink(Face face) {
//     final double? leftEyeOpen = face.leftEyeOpenProbability;
//     final double? rightEyeOpen = face.rightEyeOpenProbability;
//
//     bool blinked = false;
//
//     // 处理左眼眨眼检测
//     if (leftEyeOpen != null) {
//       // 判断左眼是否闭合
//       if (!_wasLeftEyeClosed && leftEyeOpen < 0.3) {
//         _wasLeftEyeClosed = true;
//         _leftEyeClosedTime = DateTime.now(); // 记录左眼闭合时间
//       }
//       // 判断左眼是否睁开
//       if (_wasLeftEyeClosed && leftEyeOpen > 0.7) {
//         // 判断眨眼的时间间隔是否合适
//         final elapsedTime =
//             DateTime.now().difference(_leftEyeClosedTime).inMilliseconds;
//         if (elapsedTime > 50 && elapsedTime < 500) {
//           // 间隔时间在50ms-500ms之间为有效眨眼
//           _wasLeftEyeClosed = false;
//           blinked = true;
//         }
//       }
//     }
//
//     // 处理右眼眨眼检测
//     if (rightEyeOpen != null) {
//       // 判断右眼是否闭合
//       if (!_wasRightEyeClosed && rightEyeOpen < 0.3) {
//         _wasRightEyeClosed = true;
//         _rightEyeClosedTime = DateTime.now(); // 记录右眼闭合时间
//       }
//       // 判断右眼是否睁开
//       if (_wasRightEyeClosed && rightEyeOpen > 0.7) {
//         // 判断眨眼的时间间隔是否合适
//         final elapsedTime =
//             DateTime.now().difference(_rightEyeClosedTime).inMilliseconds;
//         if (elapsedTime > 50 && elapsedTime < 500) {
//           // 间隔时间在50ms-500ms之间为有效眨眼
//           _wasRightEyeClosed = false;
//           blinked = true;
//         }
//       }
//     }
//
//     return blinked;
//   }
//
//   // 检测微笑动作
//   bool _detectSmile(Face face) {
//     final double? smiling = face.smilingProbability;
//
//     if (smiling != null) {
//       final DateTime now = DateTime.now();
//
//       // 如果开始微笑
//       if (!_wasSmiling && smiling > 0.6) {
//         _wasSmiling = true;
//         _smileFrameCount = 1;
//         _smileStartTime = now; // 记录微笑开始的时间
//       }
//       // 如果持续微笑
//       else if (_wasSmiling && smiling > 0.6) {
//         _smileFrameCount++;
//
//         // 如果微笑已经持续超过300ms，并且有多个连续帧微笑
//         final elapsedTime = now.difference(_smileStartTime).inMilliseconds;
//         if (_smileFrameCount >= 3 && elapsedTime > 300) {
//           return true; // 检测到有效微笑
//         }
//       }
//       // 如果微笑结束
//       else if (smiling < 0.3) {
//         // 设定微笑结束的判定条件，避免因为瞬时变化误判
//         final elapsedTime = now.difference(_smileStartTime).inMilliseconds;
//         if (elapsedTime > 200 && _smileFrameCount > 1) {
//           _wasSmiling = false;
//           _smileFrameCount = 0;
//         }
//       }
//     }
//     return false;
//   }
//
//   // 检测侧脸动作
//   bool _detectSideFace() {
//     if (_headPositions.length < 5) return false;
//
//     // 计算头部水平移动
//     double totalHorizontalMovement = 0;
//     int shakeCount = 0; // 记录侧脸的小幅度变化次数
//
//     for (int i = 1; i < _headPositions.length; i++) {
//       final movement = (_headPositions[i].x - _headPositions[i - 1].x).abs();
//       totalHorizontalMovement += movement;
//
//       // 判断小幅度变化，也算作侧脸的一部分
//       if (movement > 5) {
//         shakeCount++;
//       }
//     }
//
//     // 如果总的水平移动足够大，或者有频繁的小幅度水平变化，认为是侧脸
//     if (totalHorizontalMovement > 500 && shakeCount > 3) {
//       // 加入额外的判断条件：垂直移动不应过大，避免误判点头为侧脸
//       double totalVerticalMovement = 0;
//       for (int i = 1; i < _headPositions.length; i++) {
//         totalVerticalMovement +=
//             (_headPositions[i].y - _headPositions[i - 1].y).abs();
//       }
//       if (totalVerticalMovement < 100) {
//         // 垂直移动不超过100，确保没有点头的误判
//         return true;
//       }
//     }
//
//     return false;
//   }
//
//   // 检测张嘴动作
//   bool _detectMouthOpen(Face face) {
//     // 计算嘴部开合比
//     double? mouthOpenRatio;
//     final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
//     final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
//     final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;
//
//     if (bottomMouth != null && leftMouth != null && rightMouth != null) {
//       // 嘴宽
//       final mouthWidth = (leftMouth.x - rightMouth.x).abs();
//       // 嘴高
//       final mouthHeight =
//           (bottomMouth.y - ((leftMouth.y + rightMouth.y) / 2)).abs();
//       if (mouthWidth > 0) {
//         mouthOpenRatio = mouthHeight / mouthWidth;
//       }
//     }
//
//     // 如果嘴部开合比大于阈值，认为是张嘴
//     if (mouthOpenRatio != null && mouthOpenRatio > 0.3) {
//       return true;
//     }
//
//     return false;
//   }
//
//   // frontFace检测：人脸正对摄像头（pitch/yaw/roll都接近0，允许一定阈值）
//   bool _detectFrontFace(Face face) {
//     // 允许的最大偏转角度（度）
//     const double maxAngle = 12.0;
//     final double? pitch = face.headEulerAngleX; // up/down
//     final double? yaw = face.headEulerAngleY; // left/right
//     final double? roll = face.headEulerAngleZ; // tilt
//     if (pitch != null && yaw != null && roll != null) {
//       if (pitch.abs() < maxAngle &&
//           yaw.abs() < maxAngle &&
//           roll.abs() < maxAngle) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   // 转换坐标（从图像坐标系到预览UI坐标系）
//   Offset _convertPoint(Offset point) {
//     if (_imageSize == null) return Offset.zero;
//
//     final double x =
//         point.dx * (MediaQuery.of(context).size.width / _imageSize!.width);
//     final double y =
//         point.dy * (MediaQuery.of(context).size.height / _imageSize!.height);
//
//     return Offset(x, y);
//   }
//
//   // 活体时采集多张图片
//   Future<void> _captureImages(int count) async {
//     _capturedImagePaths.clear();
//     for (int i = 0; i < count; i++) {
//       if (_controller != null && _controller!.value.isInitialized) {
//         final XFile file = await _controller!.takePicture();
//
//         // 读取图片为内存数据
//         final bytes = await file.readAsBytes();
//         Uint8List compressedImage = await ImageUtil.compressImageToSize(
//           bytes,
//           maxSizeInBytes: 32 * 1024,
//         );
//         img.Image? original = img.decodeImage(compressedImage);
//
//         if (original != null) {
//           // 计算裁剪区域（以图片中心为正方形，边长为min(width, height)的80%）
//           int cropSize =
//               (original.width < original.height
//                   ? original.width
//                   : original.height) *
//               0.95 ~/
//               1;
//           int left = (original.width - cropSize) ~/ 2;
//           int top = (original.height - cropSize) ~/ 2;
//
//           // 正确裁剪
//           img.Image cropped = img.copyCrop(
//             original,
//             x: left,
//             y: top,
//             width: cropSize,
//             height: cropSize,
//           );
//
//           // 保存裁剪后的图片到临时目录
//           final directory = await getTemporaryDirectory();
//           String croppedPath =
//               '${directory.path}/face_crop_${DateTime.now().millisecondsSinceEpoch}.png';
//           final croppedFile = File(croppedPath);
//           await croppedFile.writeAsBytes(img.encodeJpg(cropped));
//
//           _capturedImagePaths.add(croppedPath);
//         } else {
//           // 解码失败，返回原图
//           _capturedImagePaths.add(file.path);
//         }
//         _imageCaptured = true;
//         await Future.delayed(Duration(milliseconds: 100)); // 间隔采集
//       }
//     }
//   }
//
//   String _getActionPrompt() {
//     switch (_currentAction) {
//       case LivenessAction.blinkStep:
//         return 'pleaseBlinkEyes'.tr;
//       case LivenessAction.smileStep:
//         return 'pleaseSmile'.tr;
//       case LivenessAction.sideFaceStep:
//         return 'pleaseTurnHeadLeftRight'.tr;
//       case LivenessAction.mouthOpenStep:
//         return 'pleaseOpenMouth'.tr;
//       case LivenessAction.frontFaceStep:
//         return 'pleaseFaceCameraDirectly'.tr;
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     _faceDetector?.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'faceRecognition'.tr,
//           style: TextStyle(color: Colors.white),
//         ),
//         titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: Icon(Icons.close, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context, []); // 关闭时返回空数组
//           },
//         ),
//       ),
//       backgroundColor: Colors.black,
//       body:
//           _isCameraInitialized
//               ? Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // 圆形相机预览（防止变形）
//                   Positioned(
//                     top: 150, // 距离顶部60像素，可根据需要调整
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: SizedBox(
//                         width: 280,
//                         height: 280,
//                         child: ClipOval(
//                           child:
//                               _isCameraInitialized && _controller != null
//                                   ? FittedBox(
//                                     fit: BoxFit.cover,
//                                     child: SizedBox(
//                                       width:
//                                           _controller!
//                                               .value
//                                               .previewSize!
//                                               .height,
//                                       height:
//                                           _controller!.value.previewSize!.width,
//                                       child: CameraPreview(_controller!),
//                                     ),
//                                   )
//                                   : Container(color: Colors.black),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // 检测状态指示器
//                   Positioned(
//                     top: 30,
//                     left: 0,
//                     right: 0,
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           margin: EdgeInsets.symmetric(horizontal: 24),
//                           decoration: BoxDecoration(
//                             color:
//                                 _allActionsCompleted
//                                     ? Colors.green.withOpacity(0.8)
//                                     : _isLive
//                                     ? Colors.orange.withOpacity(0.8)
//                                     : Colors.red.withOpacity(0.8),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             children: [
//                               Text(
//                                 _faceTooSmall
//                                     ? 'moveCloserToCamera'.tr
//                                     : !_faceInFrame
//                                     ? 'pleaseKeepFaceInFrame'.tr
//                                     : _allActionsCompleted
//                                     ? 'allActionsCompleted'.tr
//                                     : _isLive
//                                     ? 'actionCompleted'.tr
//                                     : _getActionPrompt(),
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               if (!_allActionsCompleted && !_faceTooSmall) ...[
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'stepProgress'.tr
//                                       .replaceAll(
//                                         '{current}',
//                                         '${_currentActionIndex + 1}',
//                                       )
//                                       .replaceAll(
//                                         '{total}',
//                                         '${_actionSequence.length}',
//                                       ),
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 14,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//               : Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 20),
//                     Text(
//                       'initializingCamera'.tr,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
//
// // 人脸绘制器 - 用于在相机预览上绘制人脸框和特征点
// class FacePainter extends CustomPainter {
//   final List<Face> faces;
//   final Size imageSize;
//
//   FacePainter({required this.faces, required this.imageSize});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = Colors.green
//           ..strokeWidth = 2
//           ..style = PaintingStyle.stroke;
//
//     final featurePaint =
//         Paint()
//           ..color = Colors.yellow
//           ..strokeWidth = 3
//           ..style = PaintingStyle.stroke;
//
//     for (final face in faces) {
//       // 绘制人脸框
//       final rect = _scaleRect(
//         face.boundingBox,
//         imageSize.width,
//         imageSize.height,
//         size.width,
//         size.height,
//       );
//       canvas.drawRect(rect, paint);
//
//       // 绘制面部特征点
//       _drawFaceLandmarks(canvas, face, featurePaint, size);
//
//       // 绘制微笑概率
//       if (face.smilingProbability != null) {
//         _drawText(
//           canvas,
//           'Smiling: ${face.smilingProbability!.toStringAsFixed(2)}',
//           Offset(rect.left, rect.bottom + 20),
//           Colors.white,
//           16,
//         );
//       }
//
//       // 绘制眼睛睁开概率
//       if (face.leftEyeOpenProbability != null &&
//           face.rightEyeOpenProbability != null) {
//         _drawText(
//           canvas,
//           'Left eye: ${face.leftEyeOpenProbability!.toStringAsFixed(2)} Right eye: ${face.rightEyeOpenProbability!.toStringAsFixed(2)}',
//           Offset(rect.left, rect.bottom + 45),
//           Colors.white,
//           16,
//         );
//       }
//     }
//   }
//
//   // 绘制面部特征点
//   void _drawFaceLandmarks(
//     Canvas canvas,
//     Face face,
//     Paint paint,
//     Size widgetSize,
//   ) {
//     // 眼睛
//     _drawLandmark(canvas, face, FaceLandmarkType.leftEye, paint, widgetSize);
//     _drawLandmark(canvas, face, FaceLandmarkType.rightEye, paint, widgetSize);
//     // 鼻子
//     _drawLandmark(canvas, face, FaceLandmarkType.noseBase, paint, widgetSize);
//     // 嘴巴
//     _drawLandmark(canvas, face, FaceLandmarkType.leftMouth, paint, widgetSize);
//     _drawLandmark(canvas, face, FaceLandmarkType.rightMouth, paint, widgetSize);
//     _drawLandmark(
//       canvas,
//       face,
//       FaceLandmarkType.bottomMouth,
//       paint,
//       widgetSize,
//     );
//     // 面部轮廓（如果可用）
//     final faceContour = face.contours[FaceContourType.face];
//     if (faceContour != null) {
//       for (int i = 0; i < faceContour.points.length - 1; i++) {
//         final p1 = _scalePoint(
//           faceContour.points[i],
//           imageSize.width,
//           imageSize.height,
//           widgetSize.width,
//           widgetSize.height,
//         );
//         final p2 = _scalePoint(
//           faceContour.points[i + 1],
//           imageSize.width,
//           imageSize.height,
//           widgetSize.width,
//           widgetSize.height,
//         );
//         canvas.drawLine(p1, p2, paint);
//       }
//     }
//   }
//
//   // 绘制单个特征点
//   void _drawLandmark(
//     Canvas canvas,
//     Face face,
//     FaceLandmarkType type,
//     Paint paint,
//     Size widgetSize,
//   ) {
//     final landmark = face.landmarks[type];
//     if (landmark != null) {
//       final point = _scalePoint(
//         landmark.position,
//         imageSize.width,
//         imageSize.height,
//         widgetSize.width,
//         widgetSize.height,
//       );
//       canvas.drawCircle(point, 4, paint);
//     }
//   }
//
//   // 缩放矩形坐标
//   Rect _scaleRect(
//     Rect rect,
//     double imageWidth,
//     double imageHeight,
//     double widgetWidth,
//     double widgetHeight,
//   ) {
//     final double scaleX = widgetWidth / imageWidth;
//     final double scaleY = widgetHeight / imageHeight;
//     return Rect.fromLTRB(
//       rect.left * scaleX,
//       rect.top * scaleY,
//       rect.right * scaleX,
//       rect.bottom * scaleY,
//     );
//   }
//
//   // 缩放点坐标
//   Offset _scalePoint(
//     Point<int> point,
//     double imageWidth,
//     double imageHeight,
//     double widgetWidth,
//     double widgetHeight,
//   ) {
//     final double scaleX = widgetWidth / imageWidth;
//     final double scaleY = widgetHeight / imageHeight;
//     return Offset(point.x * scaleX, point.y * scaleY);
//   }
//
//   // 绘制文本
//   void _drawText(
//     Canvas canvas,
//     String text,
//     Offset offset,
//     Color color,
//     double fontSize,
//   ) {
//     final textSpan = TextSpan(
//       text: text,
//       style: TextStyle(
//         color: color,
//         fontSize: fontSize,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout();
//     textPainter.paint(canvas, offset);
//   }
//
//   @override
//   bool shouldRepaint(covariant FacePainter oldDelegate) => true;
// }
//
// // 圆形遮罩Painter
// class _CircleMaskPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = Colors.black.withOpacity(0.6)
//           ..style = PaintingStyle.fill;
//     final width = size.width;
//     final height = size.height;
//     final center = Offset(width / 2, height / 2);
//     final radius = 140.0;
//     // 画全屏遮罩
//     canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
//     // 擦除中间圆形区域
//     paint.blendMode = BlendMode.clear;
//     canvas.drawCircle(center, radius, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
