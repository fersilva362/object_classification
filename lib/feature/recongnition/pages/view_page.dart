import 'dart:convert';

import 'package:flutter_application_1/core/card_tile.dart';
import 'package:flutter_application_1/core/roboflow_object_detection.dart';
import 'package:flutter_application_1/core/tensor_flow.dart';
import 'package:flutter_application_1/feature/recongnition/models/model.dart';
import 'package:flutter_application_1/core/stack_box.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/app_palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  Map<String, int> sizeImage = {'height': 0, 'width': 0};
  GlobalKey myKey = GlobalKey();
  double heightBox = 0;
  double widthBox = 0;
  File? image;
  late Interpreter interpreter;
  String _recognition = 'empty';
  String base64String = '';
  bool isTFactive = false;
  bool isRoboFloActive = false;
  Map bag = {};
  List filter = [];

  double maxProb = 0;

  List<Prediction> predicitonsList = [];
  @override
  void initState() {
    loadModel();

    super.initState();
  }

  @override
  void dispose() {
    interpreter.close();

    super.dispose();
  }

  void imageSelect() async {
    final imagePicked = await getImage();

    if (imagePicked != null) {
      image = imagePicked;
      setState(() {
        isTFactive = false;
        predicitonsList = [];
        isRoboFloActive = false;
      });
    }
  }

  Future<File?> getImage() async {
    try {
      final xFile = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxHeight: 244, imageQuality: 90);
      if (xFile != null) {
        return File(xFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
  }

  void loadModelImage(File image, bool isTFactive, bool isRoboFloActive) async {
    final Uint8List imageBytes = await image.readAsBytes();
    base64String = base64.encode(imageBytes);
    if (isTFactive) {
      _recognition = await tFloadModelImage(image, interpreter, imageBytes);
    }
    if (isRoboFloActive) {
      predicitonsList = [];
      predicitonsList = await detectObjects(image, sizeImage);
      bag = {};

      for (var i = 0; i < predicitonsList.length; i++) {
        bag.containsKey(predicitonsList[i].classObj)
            ? bag.update(predicitonsList[i].classObj, (value) => value + 1)
            : bag.putIfAbsent(predicitonsList[i].classObj, () => 1);
      }
      /* predicitonsList.forEach((e) => bag.containsKey(e.classObj)
          ? bag.update(e.classObj, (value) => value + 1)
          : bag.putIfAbsent(e.classObj, () => 1)) */
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (myKey.currentContext != null) {
      RenderBox box = myKey.currentContext!.findRenderObject() as RenderBox;
      heightBox = box.size.height;
      widthBox = box.size.width;
    }
    double correctionX =
        (sizeImage['width'] != 0) ? widthBox / sizeImage['width']!.toInt() : 1;
    double correctionY = (sizeImage['height'] != 0)
        ? heightBox / sizeImage['height']!.toInt()
        : 1;
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppPallete.backgroundColor,
        title: const Text(
          'Select Your Object',
          style: TextStyle(
              color: AppPallete.whiteColor,
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            image != null
                ? Column(
                    children: [
                      GestureDetector(
                        onTap: imageSelect,
                        child: SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: ClipRRect(
                                key: myKey,
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  height: 250,
                                  image!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            predicitonsList.isNotEmpty
                                ? boundingBoxes2(
                                    predicitonsList, correctionY, correctionX)
                                : Container()
                          ]),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      /* const Text(
                        'label: {predicitonsList[0].classObj} with {(predicitonsList[0].confidence * 100).toStringAsFixed(1)} % confidence',
                        style: TextStyle(
                            color: AppPallete.whiteColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ) */
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      imageSelect();
                    },
                    child: DottedBorder(
                      radius: const Radius.circular(10),
                      strokeCap: StrokeCap.round,
                      color: Colors.greenAccent,

                      borderType: BorderType.RRect,
                      dashPattern: const [20, 4],
                      // ignore: sized_box_for_whitespace
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 40,
                              color: AppPallete.whiteColor,
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text(
                              'Select your image',
                              style: TextStyle(
                                  fontSize: 15, color: AppPallete.whiteColor),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 5,
            ),
            TextButton(
              onPressed: () => {
                isTFactive = true,
                loadModelImage(image!, isTFactive = isTFactive,
                    isRoboFloActive = isRoboFloActive),
              },
              child: const Text(
                'Image Recognition',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.w600),
              ),
            ),
            isTFactive
                ? SizedBox(
                    height: 70,
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inference by TensorFlowFlite:',
                          style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _recognition,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            TextButton(
                onPressed: () async => {
                      isRoboFloActive = true,
                      loadModelImage(image!, isTFactive = isTFactive,
                          isRoboFloActive = isRoboFloActive),
                    },
                child: const Text(
                  'Object Detection',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.w600),
                )),
            isRoboFloActive
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inference by Roboflow:',
                        style: TextStyle(
                            color: AppPallete.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      SingleChildScrollView(
                        child: SizedBox(
                          height: 150,
                          width: double.maxFinite,
                          child: ListView.builder(
                            itemCount: bag.length,
                            itemBuilder: (context, index) {
                              String keyModel = bag.keys.toList()[index];
                              Prediction result = predicitonsList.firstWhere(
                                (element) => element.classObj == keyModel,
                              );
                              int repeated = bag[keyModel];
                              return MyCardTile(
                                  repeated: repeated, result: result);
                            },
                          ),
                        ),
                      )
                    ],
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
