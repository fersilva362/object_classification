import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/model.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  final Prediction result;
  final Color? boxesColor;
  final bool showPercentage;
  final GlobalKey myKey;

  const BoxWidget(
      {Key? key,
      required this.result,
      this.boxesColor,
      this.showPercentage = true,
      required this.myKey})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    RenderBox box = myKey.currentContext!.findRenderObject() as RenderBox;
    // Color for bounding box
    //print(MediaQuery.of(context).size);
    Color? usedColor;
    //Size screenSize = CameraViewSingleton.inputImageSize;
    double height = box.size.height;
    double width = box.size.width;
    //Size screenSize = MediaQuery.of(context).size;

    //print(screenSize);
    double factorX = width;
    double factorY = height;
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
      left: result.y * factorX,
      top: result.x * factorY,
      width: result.width * factorX,
      height: result.height * factorY,

      //left: re?.rect.left.toDouble(),
      //top: re?.rect.top.toDouble(),
      //right: re.rect.right.toDouble(),
      //bottom: re.rect.bottom.toDouble(),
      child: Container(
        width: result.width * factorX,
        height: result.height * factorY,
        decoration: BoxDecoration(
            border: Border.all(color: usedColor!, width: 3),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: usedColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(result.classObj ?? 'p'),
                  Text(" ${result.confidence.toStringAsFixed(2)}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
