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
    return Positioned(
      left: (result.x - result.width / 2) * correctionX,
      top: (result.y - result.height / 2) * correctionY,
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('d'
                    //(result.classObj),
                    ),
                //Text(" ${result.confidence.toStringAsFixed(2)}")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
