import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/recongnition/models/model.dart';

Widget renderBoxesOnImage(File image, List<Prediction?> recognitions,
    {Color? boxesColor, bool showPercentage = true}) {
  return LayoutBuilder(builder: (context, constraints) {
    debugPrint(
        'Max height: ${constraints.maxHeight}, max width: ${constraints.maxWidth}');

    // Calculate the scaling factors for the boxes based on the layout constraints
    double factorX = constraints.maxWidth;
    double factorY = constraints.maxHeight;

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: factorX,
          height: factorY,
          child: Image.file(
            image,
            fit: BoxFit.fill,
          ),
        ),
        ...recognitions.map((re) {
          if (re == null) {
            return Container();
          }
          Color usedColor;
          if (boxesColor == null) {
            //change colors for each label
            usedColor = Colors
                    .yellow /* Colors.primaries[
                  ((re.className ?? re.classIndex.toString()).length +
                          (re.className ?? re.classIndex.toString())
                              .codeUnitAt(0) +
                          re.classIndex) %
                      Colors.primaries.length] */
                ;
          } else {
            usedColor = boxesColor;
          }

          return Positioned(
            left: 0, // re.rect.left * factorX,
            top: 20, // re.rect.top * factorY - 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  alignment: Alignment.centerRight,
                  color: usedColor,
                  child: const Text('text'
                      /* "${re.className ?? re.classIndex.toString()}_${showPercentage ? "${(re.score * 100).toStringAsFixed(2)}%" : ""}",
                     */
                      ),
                ),
                Container(
                  width: 100, // re.rect.width.toDouble() * factorX,
                  height: 50, // re.rect.height.toDouble() * factorY,
                  decoration: BoxDecoration(
                      border: Border.all(color: usedColor, width: 3),
                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                  child: Container(),
                ),
              ],
            ),
          );
        }).toList()
      ],
    );
  });
}
