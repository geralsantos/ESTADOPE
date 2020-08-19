import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/service/Helper.dart';
import 'package:flutter/material.dart';
import 'package:estado/module/main/LoadingDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

FormBackup backup = new FormBackup();

class LocalDonations extends StatefulWidget {
  @override
  LocalDonationsState createState() {
    return new LocalDonationsState();
  }
}

class LocalDonationsState extends State<LocalDonations> {
  Helper helper = new Helper();
  bool hasData = false;
  Future<dynamic> messageDialog(
      IconData icon, Color color, String msj, bool isConfirm) async {
    List<Widget> children = [];

    if (isConfirm) {
      children.add(FlatButton(
        child: Text("Cancelar"),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ));
    }
    children.add(FlatButton(
      child: Text("Aceptar"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    ));
    return await showDialog(
        barrierDismissible: !isConfirm,
        context: context,
        builder: (BuildContext bc) {
          return Dialog(
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Icon(icon, size: 60, color: color),
                    Text(msj, style: TextStyle(fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: children,
                    )
                  ],
                )),
          );
        });
  }
Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        try {
            var docs = await helper.getDocuments();
              if (docs == null) {
                return false;
              }
            } on SocketException catch (_) {
              return false;
            } catch(ex){
              return false;
            }
        // Mobile data detected & internet connection confirmed.
        return true;
      } else {
        // Mobile data detected but no internet connection found.
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
         try {
            var docs = await helper.getDocuments();
              if (docs == null) {
                return false;
              }
            } on SocketException catch (_) {
              return false;
            } catch(ex){
              return false;
            }
        // Wifi detected & internet connection confirmed.
        return true;
      } else {
        // Wifi detected but no internet connection found.
        return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }
  void dialogLoadingData(
    IconData icon, Color color, String msj, BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext bc) {
        return Dialog(
          child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              height: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text(msj, style: TextStyle(fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                  )
                ],
              )),
        );
      });
}
   void upload(BuildContext contexto) async {
    await backup.open();
    var internetSlow = false;
    Future.delayed(Duration(seconds: 5)).then((_) {
      internetSlow = true;
    });
    dialogLoadingData(
          Icons.check_circle,
          Colors.green,
          "Verificando conexión a internet...",
          contexto);
    bool connectivityResult = await isInternet();
    dynamic activeInternet = await backup.read("activeInternet", "true");

    if (activeInternet == "true"
        ? (connectivityResult == false)
        : true) {
          Navigator.of(contexto).pop();
      messageDialog(Icons.cloud_off, Colors.red, "¡Sin conexión!", false);
    } else {
        Navigator.of(contexto).pop();
      if (hasData) {
        if (internetSlow) {
          await messageDialog(Icons.help, Colors.grey, "La conexión a internet está muy lenta.", true);
        }

        var prefs = await SharedPreferences.getInstance();
        String usu = prefs.getString('usuario').toString(),contrasena= prefs.getString('contrasena').toString(); 
        if (usu!="" && contrasena!="") {
          await helper
              .checkUser(usu,contrasena)
              .then((usuarioExiste) async {
            if (usuarioExiste["estado"]=="error") {
              //si no existe el usuario
              bool go2 = await messageDialog(Icons.error, Colors.grey,
                 usuarioExiste["mensaje"], false);
              if (go2) {
                final prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushReplacementNamed(context, '/login');
              }
            }
          }).catchError((onError) {
            print("helper.checkUser2 ERror");
            print(onError);
          });
        }

        bool go = await messageDialog(Icons.help, Colors.grey, "¿Sincronizar?", true);
        if (go) {
          LoadingDialog.show(context);
          dynamic result = await helper.upload();
          LoadingDialog.hide(context);
          if (result!=null) {
            if (result["estado"]!="error") {
              messageDialog(
                Icons.check_circle, Colors.green, "Sincronizado", false);
            }else{
              messageDialog(
                Icons.error, Colors.red, result["mensaje"], false);
            }
          } else {
            messageDialog(
                Icons.error, Colors.red, "Ocurrió un error al sincronizar", false);
          }
        }
      } else {
        messageDialog(
            Icons.check_circle, Colors.green, "Nada que sincronizar", false);
      }
    }
  }

  Widget buildImagePreview(String path) {
    return path == null
        ? Icon(
            Icons.image,
            size: 150,
            color: Colors.grey,
          )
        : Image.file(
            File(path),
            fit: BoxFit.fitWidth,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: helper.getDonations(),
        builder: (BuildContext c, snapashot) {
          Widget child;
          if (snapashot.hasData) {
            List<Widget> items = new List();
            for (var d in snapashot.data) {
              items.add(Card(
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.red.withAlpha(30),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 5,
                      ),
                      Container(
                          height: 240,
                          width: MediaQuery.of(context).size.width - 40,
                          child: buildImagePreview(d['documento_path'])),
                      Row(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                              width: MediaQuery.of(context).size.width - 35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    d['nombre'] +
                                        ' ' +
                                        d['primer_apellido'] +
                                        ' ' +
                                        d['segundo_apellido'],
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                  ),
                                  InputChip(
                                    label: Text(
                                        "Documento:" + d['numero_documento']),
                                  ),
                                ],
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ));
            }
            if (items.length > 0) {
              child = GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(10),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                  crossAxisCount: 1,
                  children: items);

              hasData = true;
            } else {
              child = Text('Sin registros');

              hasData = false;
            }
          } else if (snapashot.hasError) {
            child = Text("Nada por aqui");
          } else {
            child = CircularProgressIndicator();
          }
          return Center(
            child: child,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          upload(context);
        },
        child: const Icon(Icons.cloud_upload),
        backgroundColor: Colors.red,
      ),
    );
  }
}
