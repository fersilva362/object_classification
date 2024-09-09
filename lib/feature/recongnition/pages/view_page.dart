import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/core/model.dart';
import 'package:flutter_application_1/core/render_box.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
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
  Map<String, int> sizeImage = {'height': 0, 'width': 0};
  GlobalKey myKey = GlobalKey();
  double heightBox = 0;
  double widthBox = 0;
  File? image;
  late Interpreter interpreter;
  String? _recognition;
  List<String> _loadLabels = [];
  List<double> _output = [];
  double? maxProb = 0;
  String? base64String = '';
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
      loadModelImage(image!);
      predicitonsList = await detectObjects(image!);
      setState(() {
        if (myKey.currentContext != null) {
          RenderBox box = myKey.currentContext!.findRenderObject() as RenderBox;
          heightBox = box.size.height;
          widthBox = box.size.width;
          print('box $widthBox * ${heightBox} ');
        }
      });
    }
  }

  Future<List<Prediction>> detectObjects(File image) async {
    Uint8List imageBytes = await File(image.path).readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    final body = {
      "image": "$base64Image",
    };
    print(jsonEncode(body));

/*img.Image originalImage = img.decodeImage(imageBytes)!;
     // Resize the image
    img.Image resizedImage =
        img.copyResize(originalImage, width: 416, height: 416);

    // Encode to JPEG and convert to Base64
    List<int> resizedBytes = img.encodeJpg(resizedImage);
    String base64Image = base64Encode(resizedBytes); */

    final api_key = "s3Peoept4Syxx0LkzUba";
    final modelEndpoint = 'hard-hat-sample-sxbw4/1';
    final IMAGE_URL = "https://i.postimg.cc/0QQHWr0s/f.jpg";
    try {
      {
        final url =
            "https://detect.roboflow.com/hard-hat-sample-sxbw4/1?api_key=s3Peoept4Syxx0LkzUba";

        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: base64Image,
        );

        if (response.statusCode == 200) {
          print(response.body);
          sizeImage['width'] = jsonDecode(response.body)['image']['width'];
          sizeImage['height'] = jsonDecode(response.body)['image']['height'];
          print(sizeImage);

          List<Prediction> _predicitonsList =
              (jsonDecode(response.body)['predictions'] as List)
                  .map((e) => Prediction.fromJson(e))
                  .toList();
          return _predicitonsList;
        } else {
          print('Error: ${response.statusCode} ');
          return [];
        }
      }
    } catch (e) {
      print('error: ${e.toString()}');
      throw Exception();
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
    base64String = base64.encode(imageBytes);
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
    double factorX = double.infinity;
    double factorY = 250;
    double correctionX =
        (sizeImage['width'] != 0) ? widthBox / sizeImage['width']!.toInt() : 1;
    double correctionY = (sizeImage['height'] != 0)
        ? widthBox / sizeImage['height']!.toInt()
        : 1;

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
          child: Padding(
            padding: const EdgeInsets.all(15.0),
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
                              key: myKey,
                              width: double.infinity,
                              height: 250,
                              child: Stack(children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      width: MediaQuery.of(context).size.width,
                                      image!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                predicitonsList.isNotEmpty
                                    ? Positioned(
                                        left:
                                            predicitonsList[0].x * correctionX -
                                                15,
                                        top:
                                            predicitonsList[0].y * correctionY -
                                                35,
                                        child: Container(
                                          width: predicitonsList[0].width *
                                              correctionX,
                                          height: predicitonsList[0].height *
                                              correctionY,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.yellow,
                                                  width: 3),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(2))),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              color: Colors.yellow,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  /*Text(
                                                     (predicitonsList[0]
                                                        .classObj),
                                                  ), 
                                                  Text(
                                                      " ${predicitonsList[0].confidence.toStringAsFixed(2)}")*/
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ]),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'label: ${predicitonsList[0].classObj} with ${(predicitonsList[0].confidence * 100).toStringAsFixed(1)} % confidence',
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
                                  color: AppPallete.whiteColor,
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Text(
                                  'Select your image',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: AppPallete.whiteColor),
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
