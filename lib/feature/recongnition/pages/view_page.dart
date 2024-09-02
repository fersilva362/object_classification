import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/app_palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  File? image;
  late Interpreter interpreter;
  String? _recognition;
  List<String> _loadLabels = [];
  List<double> _output = [];
  double? maxProb = 0;
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
      setState(() {
        image = imagePicked;
        loadModelImage(image!);
      });
    }
  }

  Future<File?> getImage() async {
    try {
      final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        return File(xFile.path);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
  }

  Future<List<String>> loadLabels() async {
    final labelsTxt = await rootBundle.loadString('assets/labels.txt');
    return labelsTxt.split('\n');
  }

  void loadModelImage(File image) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final imgTensor = _preprocessImage(imageBytes);

    var output = List.filled(1 * 2, 0).reshape([1, 2]);
    _loadLabels = await loadLabels();
    interpreter.run(imgTensor, output);
    _output = output[0];
    maxProb = getMax(_output);
    final int index = _output.indexOf(getMax(_output));
    _recognition = _loadLabels[index].split(' ').last;
    setState(() {});

    // return output[0];
  }

  double getMax(List<double> output) {
    if (output.isEmpty) {
      return 0.5;
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

  @override
  Widget build(BuildContext context) {
    debugPrint(_loadLabels.toString());
    debugPrint(_output.toString());
    /* debugPrint(_loadLabels[_output.indexOf(getMax(_output))]
        .split(' ')
        .last
        .toString()); */
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.backgroundColor,
        title: Text(
          'Select Your Object',
          style: TextStyle(
              color: AppPallete.whiteColor,
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              image != null
                  ? Column(
                      children: [
                        GestureDetector(
                          onTap: imageSelect,
                          child: SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'It points to $_recognition',
                          style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        )
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
            ],
          ),
        ),
      ),
    );
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
}
