import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

main(){
  runApp(MaterialApp(
    home: FacePage(),
  ));
}

class FacePage extends StatefulWidget {
  // Access a Cloud Firestore instance from your Activity
  //final dbReference = Firestore.instance;

  @override
  createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  //_FacePageState({this.dbReference});
  File _imageFile;
  List<Face> _faces;
  //final dbReference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VSRP: Return Facial Coordinates in Images'),
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
    final image = FirebaseVisionImage.fromFile(imageFile);

    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );

    final faces = await faceDetector.detectInImage(image);

    print(faces[0].getLandmark(FaceLandmarkType.bottomMouth).position);

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
      Flexible(
          flex: 1,
          child: ListView(
            // list each face's bounding box coordinates
            children: faces.map<Widget>((f) => LipCoordinates(f)).toList(),
          )
      )
    ],
    );
  }
}

class LipCoordinates extends StatelessWidget {
  LipCoordinates(this.face);
  final Face face;

  @override
  Widget build(BuildContext context) {
    final bottomMouthCenter = face.getLandmark(FaceLandmarkType.bottomMouth).position;

    return ListTile(
      title: Text('Bottom Mouth Center: (${bottomMouthCenter.x},'
          '${bottomMouthCenter.y})'),
    );
  }
}
