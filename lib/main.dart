import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  File? photoFile;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void takePhoto() async {
    try {
      XFile photo = await controller.takePicture();
      setState(() {
        photoFile = File(photo.path);
      });
    } catch (e) {
      print(e);
    }
  }

  void deletePhoto() {
    setState(() {
      photoFile = null;
    });
  }

  void sharePhoto() {
    Share.shareXFiles([XFile(photoFile!.path)], text: 'Check out my photo!');
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
        home: Scaffold(
      body: photoFile == null
          ? CameraPreview(controller)
          : Image.file(photoFile!),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: photoFile == null
            ? <Widget>[
                FloatingActionButton(
                  onPressed: takePhoto,
                  child: const Icon(Icons.camera),
                ),
              ]
            : <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: deletePhoto,
                      child: const Icon(Icons.delete),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      onPressed: sharePhoto,
                      child: const Icon(Icons.share),
                    ),
                  ],
                )
              ],
      ),
    ));
  }
}
