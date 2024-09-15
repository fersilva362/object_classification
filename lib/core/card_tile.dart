import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/recongnition/models/model.dart';

class MyCardTile extends StatelessWidget {
  final int repeated;
  final Prediction result;
  const MyCardTile({
    super.key,
    required this.repeated,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 30,
      child: ListTile(
        minLeadingWidth: 15,
        dense: true,
        leading: Container(
          height: 10,
          width: 10,
          color: Colors.primaries[result.classId],
        ),
        title: Text(
          result.classObj,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        trailing: Text(
          repeated.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}
