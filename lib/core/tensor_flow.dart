import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

Future<String> tFloadModelImage(
  File image,
  Interpreter interpreter,
  Uint8List imageBytes,
) async {
  String recognition;
  final imgTensor = _preprocessImage(imageBytes);
  List output = List.filled(1 * 2, 0).reshape([1, 2]);
  interpreter.run(imgTensor, output);

  final _loadLabels = await loadLabels();

  final int index = (output[0]).indexOf(getMax(output[0]));
  if (index == -1) {
    recognition = 'No se puede discernir';
  } else {
    List<String> removed = _loadLabels[index].split(' ')..removeAt(0);
    recognition = removed.join(' ');
  }
  return recognition;
}

double getMax(List<double> output) {
  if (output.isEmpty) {
    return -1;
  }
  return output.reduce((value, element) {
    if (value > element) {
      element = value;
      return element;
    } else {
      return element;
    }
  });
}

Uint8List _preprocessImage(Uint8List imageBytes) {
  img.Image originalImage = img.decodeImage(imageBytes)!;

  // Resize to the required dimensions (e.g., 224x224)
  img.Image resizedImage =
      img.copyResize(originalImage, width: 224, height: 224);

  // Convert to float32 and normalize
  Float32List input = Float32List(224 * 224 * 3);
  var buffer = Float32List.view(input.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < 224; i++) {
    for (var j = 0; j < 224; j++) {
      var pixel = resizedImage.getPixel(j, i);

      buffer[pixelIndex++] = (pixel.r - 127.5) / 127.5;
      buffer[pixelIndex++] = (pixel.g - 127.5) / 127.5;
      buffer[pixelIndex++] = (pixel.b - 127.5) / 127.5;
    }
  }

  return input.buffer.asUint8List();
}

Future<List<String>> loadLabels() async {
  final labelsTxt = await rootBundle.loadString('assets/labels.txt');
  return labelsTxt.split('\n');
}
