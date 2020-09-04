import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/prueba.dart';
import 'package:flutter/material.dart';
import 'package:estado/module/main/CameraController.dart';
import 'package:camera/camera.dart';
import 'package:estado/module/main/DisplayPicture.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pathDart;

class AtachStep extends StatefulWidget {
  final Function documentCallback;
  final Function beneficiarioCallback;
  AtachStep(this.documentCallback, this.beneficiarioCallback);
  AtachStepState createState() {
    return AtachStepState();
  }
}

class AtachStepState extends State<AtachStep> {
  String documentPath;
  String beneficiarioPath;

  PickedFile _imageFile;
  dynamic _pickImageError;
  String _retrieveDataError;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  FormBackup backup = new FormBackup();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await backup.open();
    var d = await backup.read("documentPath", null);
    var b = await backup.read("beneficiarioPath", null);
    setState(() {
      documentPath = d;
      beneficiarioPath = b;
    });
    widget.documentCallback(d);
    widget.beneficiarioCallback(b);
  }

  void atachPicture(
      BuildContext context, String title, String pref, String docpath) async {
    /*final cameras = await availableCameras();
    final firstCamera = cameras.first;*/
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyAppPrueba(
              title: title,
              pref: pref,
              docpath: docpath,
              callback: (ImageSource source, {BuildContext context}) async {
                await _displayPickImageDialog(context,
                    (double maxWidth, double maxHeight, int quality) async {
                  try {
                    var pickedFile = await _picker.getImage(
                      source: source,
                      maxWidth: 1500,
                      maxHeight: 2500,
                      imageQuality: 50,
                    );
                    String name = pref + DateTime.now().toString() + '.jpg';
                    String rename = name.replaceAll(":","_");
                    String dirBefore = pathDart.dirname(pickedFile.path);
                    final newPath = pathDart.join(dirBefore, rename);
                    File file = await File(pickedFile.path).copy(newPath);
                    try {
                      final file = File(pickedFile.path);
                      if (file.existsSync()) {
                        await file.delete();
                      }
                    } catch (e) {
                    }
                    
                    //File file = await File(pickedFile.path).copy(newPath);

                    /*if (file.existsSync()) {
                      await file.delete();
                    }*/
                    setState(() {
                      //_imageFile = pickedFile;
                      if (pref == "FIRMA_PADRON_DNI_") {
                        documentPath = newPath;
                        if (widget.documentCallback != null) {
                          widget.documentCallback(newPath);
                        }
                      } else {
                        beneficiarioPath = newPath;
                        if (widget.beneficiarioCallback != null) {
                          widget.beneficiarioCallback(newPath);
                        }
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                            imagePath: newPath,
                            title: title,
                          ),
                        ),
                      );
                    });
                  } catch (e) {
                    setState(() {
                      _pickImageError = e;
                    });
                  }
                });
              })
          /*builder: (context) => TakePictureScreen(
                camera: firstCamera,
                title: title,
                pref: pref,
                callback: (String path, String pref) {
                  setState(() {
                    if (pref == "FIRMA_PADRON_DNI_") {
                      documentPath = path;
                      if (widget.documentCallback != null) {
                        widget.documentCallback(path);
                      }
                    } else {
                      beneficiarioPath = path;
                      if (widget.beneficiarioCallback != null) {
                        widget.beneficiarioCallback(path);
                      }
                    }
                  });
                },
              )*/
          ),
    );
  }

  Widget buildImagePreview(String path) {
    print("path");
    print(path);
    return path == null
        ? Icon(
            Icons.image,
            size: 200,
            color: Colors.grey,
          )
        : Image.file(
            File(path),
            height: 200,
            fit: BoxFit.contain,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  if (documentPath != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayPicture(
                                  title: "Evidencia 1",
                                  imagePath: documentPath,
                                )));
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text('Evidencia 1'),
                    ),
                    buildImagePreview(documentPath),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('Eliminar'),
                          textColor: Colors.grey,
                          onPressed: () {
                            setState(() {
                              documentPath = null;
                            });
                            if (widget.documentCallback != null) {
                              widget.documentCallback(null);
                            }
                          },
                        ),
                        FlatButton(
                          child: const Text('Foto'),
                          onPressed: () {
                            //documentPath = null;
                            atachPicture(context, "Evidencia 1",
                                "FIRMA_PADRON_DNI_", documentPath);
                          },
                        ),
                      ],
                    ),
                  ],
                ))),
        Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  if (beneficiarioPath != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayPicture(
                                title: "Evidencia 2",
                                imagePath: beneficiarioPath)));
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Evidencia 2'),
                    ),
                    buildImagePreview(beneficiarioPath),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('Eliminar'),
                          textColor: Colors.grey,
                          onPressed: () {
                            setState(() {
                              beneficiarioPath = null;
                            });
                            if (widget.beneficiarioCallback != null) {
                              widget.beneficiarioCallback(null);
                            }
                          },
                        ),
                        FlatButton(
                          child: const Text('Foto'),
                          onPressed: () {
                            //beneficiarioPath = null;
                            atachPicture(context, "Evidencia 2",
                                "BENEFICIARIO_", beneficiarioPath);
                          },
                        ),
                      ],
                    ),
                  ],
                ))),
      ],
    );
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

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String title;
  const DisplayPictureScreen({Key key, this.imagePath, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.white,
            child: Text('ADJUNTAR'),
          ),
        ],
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.center,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {},
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
