import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/recongnition/models/model.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  final Prediction result;
  final Color? boxesColor;
  final double correctionY;
  final double correctionX;
  //final GlobalKey myKey;

  const BoxWidget(
      {super.key,
      required this.result,
      this.boxesColor,
      //required this.myKey,
      required this.correctionY,
      required this.correctionX});
  @override
  Widget build(BuildContext context) {
    // Color for bounding box
    //print(MediaQuery.of(context).size);
    Color? usedColor;

    if (boxesColor == null) {
      //change colors for each label
      usedColor = Colors
              .yellow /*Colors.primaries[ 
           ((result.className ?? result.classIndex.toString()).length +
                  (result.className ?? result.classIndex.toString())
                      .codeUnitAt(0) +
                  result.classIndex) %
              Colors.primaries.length ]*/
          ;
    } else {
      usedColor = boxesColor;
    }

    return Positioned(
      left: result.x * correctionX - 30,
      top: result.y * correctionY - 70,
      child: Container(
        width: result.width * correctionX,
        height: result.height * correctionY,
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.primaries[result.classId], width: 3),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.primaries[result.classId],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  (result.classObj),
                ),
                Text(" ${result.confidence.toStringAsFixed(2)}")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
