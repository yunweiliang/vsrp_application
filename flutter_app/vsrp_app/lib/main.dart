import 'dart:io';
import 'dart:collection';
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
  final localDataCollection = new LipCoordinatesCollection();

  @override
  createState() => _FacePageState(dbReference: localDataCollection);
}

class _FacePageState extends State<FacePage> {
  _FacePageState({this.dbReference});
  File _imageFile;
  List<Face> _faces;
  final dbReference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VSRP: Lip Coordinates in Images'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick an image',
        child: Icon(Icons.add_a_photo),
      ),
      body: ImagesAndFaces(imageFile: _imageFile,
          faces: _faces, db: dbReference),
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

    // print(faces[0].getLandmark(FaceLandmarkType.bottomMouth).position);

    if (mounted){
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }
}

class ImagesAndFaces extends StatelessWidget {
  ImagesAndFaces({this.imageFile, this.faces, this.db});
  final File imageFile;
  final List<Face> faces;
  final LipCoordinatesCollection db;

  @override
  Widget build(BuildContext context) {

    if (imageFile == null){
      return Center(child: Text('Pick a picture.'));
    }
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
            children: faces.map<Widget>((f) => LipCoordinates(f, db)).toList(),
          )
      )
    ],
    );
  }
}

class LipCoordinates extends StatelessWidget {
  LipCoordinates(this.face, this.db);
  final Face face;
  final LipCoordinatesCollection db;

  @override
  Widget build(BuildContext context) {
    final bottomMouthCenter = face.getLandmark(FaceLandmarkType.bottomMouth).position;
    final leftMouth = face.getLandmark(FaceLandmarkType.leftMouth).position;
    final rightMouth = face.getLandmark(FaceLandmarkType.rightMouth).position;


    if (bottomMouthCenter == null){
      return ListTile(title:Text('Face not found'));
    }

    List element = new List(3);
    element[0] = bottomMouthCenter;
    element[1] = leftMouth;
    element[2] = rightMouth;
    db.recordData(element);

    return ListTile(
      title: Text('Bottom Mouth Center: (${bottomMouthCenter.x}, '
          '${bottomMouthCenter.y}) \n'
          'Left Mouth: (${leftMouth.x}, ${leftMouth.y} \n'
          'Right Mouth: (${rightMouth.x}, ${rightMouth.y}'),
    );
  }
}


class LipCoordinatesCollection {
  List<List> _face_coordinates; // store list of points per picture
  int i = 0;
  final numDataType;

  LipCoordinatesCollection({int size = 10, this.numDataType = 6}){
    _face_coordinates = List(size);
  }

  void recordData(face_coordinates){
    print(_face_coordinates);
    _face_coordinates[i] = face_coordinates;
    i++;
  }

  /*List getCurrent(){
    i++;
    try {
      return _face_coordinates[i] = new List(numDataType);
    } catch (e){
      print(e);
    }
  }

  void setCurrent(int index, int num){

  }*/
}