import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/service/Helper.dart';
import 'package:flutter/material.dart';
import 'package:estado/module/main/LoadingDialog.dart';

FormBackup backup = new FormBackup();

class LocalDonations extends StatefulWidget {
  @override
  LocalDonationsState createState() {
    return new LocalDonationsState();
  }
}

class LocalDonationsState extends State<LocalDonations> {
  Helper helper = new Helper();
  bool hasData=false;
  Future<dynamic> messageDialog(IconData icon, Color color, String msj,bool isConfirm) async{
    List<Widget> children=[];

                      if(isConfirm){
                       children.add( FlatButton(
                          child: Text("Cancelar"),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ));
                      }
                      children.add( FlatButton(
                          child: Text("Aceptar"),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ));
    return await showDialog(
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
                      children:children,
                    )
                  ],
                )),
          );
        });
  }

  void upload() async {
    await backup.open();
    var connectivityResult = await (Connectivity().checkConnectivity());
    dynamic activeInternet =await backup.read("activeInternet", "true");
    if (activeInternet =="true"? (connectivityResult == ConnectivityResult.none) : true) {
      messageDialog(Icons.cloud_off, Colors.red, "¡Sin conexión!",false);
    }else{
  if(hasData){
          bool go= await messageDialog(Icons.help, Colors.grey, "¿Sincronizar?",true);
      if(go){
          LoadingDialog.show(context);
        bool result=await helper.upload();
          LoadingDialog.hide(context);
        if(result){
          messageDialog(Icons.check_circle, Colors.green, "Sincronizado",false);
        }else{
          messageDialog(Icons.error, Colors.red, "Ocurrió un error al enviar",false);
        }
      }
  }else{
     messageDialog(Icons.check_circle, Colors.green, "Nada que sincronizar",false);
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
                            width: MediaQuery.of(context).size.width-35,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(d['nombre'] + ' ' + d['primer_apellido']+' '+d['segundo_apellido'],
                             softWrap: false,overflow: TextOverflow.clip,),
                              InputChip(
                                label: Text("Documento:"+d['numero_documento']),
                              ),
                            ],
                          )
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
            }
            if(items.length>0){
              child=GridView.count(
                primary: false,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                crossAxisCount: 1,
                children: items);
   
                   hasData=true;
     
            }else{
              child=Text('Sin registros');

                hasData=false;
   
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
        onPressed: upload,
        child: const Icon(Icons.cloud_upload),
        backgroundColor: Colors.red,
      ),
    );
  }
}
