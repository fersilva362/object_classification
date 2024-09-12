import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/box_widget.dart';
import 'package:flutter_application_1/feature/recongnition/models/model.dart';

Widget boundingBoxes2(
    List<Prediction>? results, double correctionY, double correctionX) {
  if (results == null) {
    return Container();
  }
  return Stack(
    children: results
        .map((e) => BoxWidget(
              result: e,
              //myKey: GlobalKey(),
              correctionY: correctionY,
              correctionX: correctionX,
            ))
        .toList(),
  );
}
