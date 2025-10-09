import 'package:dart_mappable/dart_mappable.dart';

part 'face_recognition.mapper.dart';

@MappableClass()
class FaceRecognitionData with FaceRecognitionDataMappable {
  final int isSuccess;

  FaceRecognitionData({required this.isSuccess});
}
