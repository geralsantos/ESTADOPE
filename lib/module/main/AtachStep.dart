import 'package:flutter/material.dart';
import 'package:estado/module/main/CameraController.dart';
import 'package:camera/camera.dart';
import 'package:estado/module/main/DisplayPicture.dart';
import 'dart:io';

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
  void atachPicture(BuildContext context, String title, String pref) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(
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
              )),
    );
  }

  Widget buildImagePreview(String path) {
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
                                  title: "Documento",
                                  imagePath: documentPath,
                                )));
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text('Documento'),
                    ),
                    buildImagePreview(documentPath),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('ELIMINAR'),
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
                          child: const Text('ADJUNTAR'),
                          onPressed: () {
                            documentPath = null;
                            atachPicture(
                                context, "Documento", "FIRMA_PADRON_DNI_");
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
                                title: "Beneficiario",
                                imagePath: beneficiarioPath)));
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Beneficiario'),
                    ),
                    buildImagePreview(beneficiarioPath),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('ELIMINAR'),
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
                          child: const Text('ADJUNTAR'),
                          onPressed: () {
                            beneficiarioPath = null;
                            atachPicture(
                                context, "Beneficiario", "BENEFICIARIO_");
                          },
                        ),
                      ],
                    ),
                  ],
                ))),
      ],
    );
  }
}
