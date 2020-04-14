import 'package:flutter/material.dart';
import 'dart:io';
class DisplayPicture extends StatelessWidget {
  final String imagePath;
   final String title;
  const DisplayPicture({Key key, this.imagePath,this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Image.file(File(imagePath)),
    );
  }
}