// ignore_for_file: public_member_api_docs, sort_constructors_first
class Prediction {
  final double x;
  final double y;
  final double width;
  final double height;
  final String classObj;
  final double confidence;
  final int classId;
  Prediction(
      {required this.x,
      required this.y,
      required this.width,
      required this.height,
      required this.classObj,
      required this.confidence,
      required this.classId});

  Map<String, dynamic> tojson() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'class': classObj,
      'confidence': confidence,
      'class_id': classId
    };
  }

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
        x: json['x'] as double,
        y: json['y'] as double,
        width: json['width'],
        height: json['height'],
        classObj: json['class'] as String,
        confidence: json['confidence'] as double,
        classId: json['class_id']);
  }
}
