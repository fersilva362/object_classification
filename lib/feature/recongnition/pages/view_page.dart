import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  List<dynamic>? _recognitions;
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

  void loadModelImage(File image) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final imgTensor = _preprocessImage(imageBytes);
    //List<Float32List> input = [imageBytes.buffer.asFloat32List()];
    var output = List.filled(1 * 2, 0).reshape([1, 2]);

    interpreter.run(imgTensor, output);
    print(output);
    // Return the output
    return output[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                child: Image.asset('assets/1B.png'),
              ),
              Text('data'),
              image != null
                  ? GestureDetector(
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
                                style: TextStyle(fontSize: 15),
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
