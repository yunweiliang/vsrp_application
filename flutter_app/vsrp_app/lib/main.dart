import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

main(){
  runApp(MaterialApp(
    home: FacePage(),
  ));
}

class FacePage extends StatefulWidget {
  @override
  createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces;


  @override
  Widget build(BuildContext context) {
    print('_imageFile type in FacePage Widget build: $_imageFile');
    return Scaffold(
      appBar: AppBar(
        title: Text('VSRP Face Detector'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick an image',
        child: Icon(Icons.add_a_photo),
      ),
      body: ImagesAndFaces(imageFile: _imageFile, faces: _faces), //TODO: deal with null _imageFile
    );
  }

  void _getImageAndDetectFaces() async{
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    print('_getImageAndDetectFaces() ran--------------------------------');
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );

    final faces = await faceDetector.detectInImage(image);
    if (mounted){
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }
}

class ImagesAndFaces extends StatelessWidget {
  ImagesAndFaces({this.imageFile, this.faces});
  final File imageFile;
  final List<Face> faces;

  @override
  Widget build(BuildContext context) {
    print('imageFile type: $faces');
    //build widget with column format
    return Column(children: <Widget>[
      //display image
      Flexible(
          flex: 2,
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          )),
      //display bounding box in list
      Flexible(
          flex: 1,
          child: ListView(
            // list each face's bounding box coordinates
            children: faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
          )
      )
    ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);
  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('(${pos.top}, ${pos.left}, ${pos.bottom}, ${pos.right}'),
    );
  }
}






/*
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    home: CameraPage(
      camera: firstCamera,
    ),
  ));
}

class CameraPage extends StatefulWidget{
  final CameraDescription camera;

  CameraPage({
    @required this.camera
  });

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage>{
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState(){
    super.initState();

    _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture'),),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try{
            await _initializeControllerFuture;
            final path = join(
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png'
            );

            await _controller.takePicture(path);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPicturePage(imagePath: path),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPicturePage extends StatelessWidget {
  final String imagePath;

  const DisplayPicturePage({Key key, this.imagePath}): super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}


*/
