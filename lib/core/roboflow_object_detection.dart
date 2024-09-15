// ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/feature/recongnition/models/model.dart';

Future<List<Prediction>> detectObjects(File image, Map sizeImage) async {
  Uint8List imageBytes = File(image.path).readAsBytesSync();
  String base64Image = base64Encode(imageBytes);

  const api_key = "s3Peoept4Syxx0LkzUba";
  const modelEndpoint = 'hard-hat-sample-sxbw4/1';
  try {
    {
      const url = "https://detect.roboflow.com/$modelEndpoint?api_key=$api_key";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: base64Image,
      );

      if (response.statusCode == 200) {
        sizeImage['width'] = jsonDecode(response.body)['image']['width'];
        sizeImage['height'] = jsonDecode(response.body)['image']['height'];

        List<Prediction> _predicitonsList =
            (jsonDecode(response.body)['predictions'] as List)
                .map((e) => Prediction.fromJson(e))
                .toList();

        return _predicitonsList;
      } else {
        return [];
      }
    }
  } catch (e) {
    throw Exception();
  }
}
