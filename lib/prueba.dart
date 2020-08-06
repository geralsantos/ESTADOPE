import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyAppPrueba());
}

class MyAppPrueba extends StatelessWidget {
  final String title;
  final String pref;
  final Function callback;
  final String docpath;
  const MyAppPrueba(
      {Key key, this.title, this.pref, this.callback, this.docpath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: MyHomePage(pref: pref, callback: callback, docpath: docpath),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String pref;
  final Function callback;
  final String docpath;
  const MyHomePage(
      {Key key, this.title, this.pref, this.callback, this.docpath})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _imageFile;
  dynamic _pickImageError;
  String _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
/*

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    
   
      await _displayPickImageDialog(context,
          (double maxWidth, double maxHeight, int quality) async {
        try {
          final pickedFile = await _picker.getImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _imageFile = pickedFile;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
  }*/

  @override
  void dispose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(File(_imageFile));
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    print("widget.docpath");
    print(widget.docpath != null);
    if (widget.docpath != null) {
      setState(() {
        _imageFile = widget.docpath;
      });
    } else {
      setState(() {
        _imageFile = "";
      });
    }
    return widget.docpath;
    /* final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
        setState(() {
          _imageFile = response.file;
        });
    } else {
      _retrieveDataError = response.exception.code;
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return const Text(
                      'No tienes imagen seleccionada.',
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {},
                        child: _previewImage(),
                      ),
                    );
                  }
                },
              )
            : (Container(
              padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {},
                        child: _previewImage(),
                      ),
                    )),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                widget.callback(ImageSource.camera, context: context);
              },
              heroTag: 'image1',
              tooltip: 'Tomar una foto',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    double width = maxWidthController.text.isNotEmpty
        ? double.parse(maxWidthController.text)
        : null;
    double height = maxHeightController.text.isNotEmpty
        ? double.parse(maxHeightController.text)
        : null;
    int quality = qualityController.text.isNotEmpty
        ? int.parse(qualityController.text)
        : null;
    onPick(width, height, quality);
    return;
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

// A widget that displays the picture taken by the user.
