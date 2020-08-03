import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:estado/module/main/DropdownField2.dart';
import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/module/sotorage/Storage.dart';
import 'package:estado/service/Helper.dart';
import 'package:flutter/material.dart';

FormBackup backup = new FormBackup();
Storage storage = new Storage();

class FamiliaReceptoraState extends StatefulWidget {
  String title;

  FamiliaReceptoraState({Key key, this.title}) : super(key: key);

  @override
  _FamiliaReceptoraStateState createState() => _FamiliaReceptoraStateState();
}

class _FamiliaReceptoraStateState extends State<FamiliaReceptoraState> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;
  TextEditingController _controllerApeP;
  TextEditingController _controllerApeM;
  TextEditingController _controllerNombres;
  var itemsParentesco = [];
  var parentesco = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
    _controllerApeP = TextEditingController();
    _controllerApeM = TextEditingController();
    _controllerNombres = TextEditingController();
    readinitData();
    // _readBackupParentesco();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controllerApeP.dispose();
    _controllerApeM.dispose();
    _controllerNombres.dispose();
    _controller.dispose();
    super.dispose();
  }
/*
  void _readBackupParentesco() {
    readBackupParentesco().then((onValue) {
      setState(() {
        itemsParentesco = onValue;
      });
    });
  }*/
  void readinitData()async{
    _controller.text = await backup.read("frnumero_documento", "");
    _controllerApeP.text = await backup.read("frapellido_paterno", "");
    _controllerApeM.text = await backup.read("frapellido_materno", "");
    _controllerNombres.text = await backup.read("frnombres", "");
  }
  Future readBackupParentesco() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    var docs;
    //await storage.open();
    dynamic activeInternet = await backup.read("activeInternet", "true");
    parentesco = int.parse(await backup.read("parentesco", "0"));
    
    //print("qqqqqqqqqqqqqqqqqq");
    if (activeInternet == "true"
        ? (connectivityResult != ConnectivityResult.none)
        : false) {
      Helper helper = new Helper();
      docs = await helper.getParentesco();
      //List<dynamic> dd;
      docs.insert(0, {"id": 0, "nombre": ""});
      return docs;
    } else {
      docs = await storage.getAll("parentesco", (var maps, int index) {
        return maps;
      });
      List<dynamic> d = json.decode(json.encode(docs));
      d.insert(0, {"id": 0, "nombre": ""});
      return d;
    }
  }

  Future<bool> findDataFromServiceFamilia(
      BuildContext contexto, String numero_documento) async {
    Helper help = new Helper();
    var connectivityResult = await (Connectivity().checkConnectivity());
    dynamic activeInternet = await backup.read("activeInternet", "true");
    var response = false;
    if (activeInternet == "false"
        ? true
        : (connectivityResult == ConnectivityResult.none)) {
      return false;
    }
    dialogLoadingData(Icons.check_circle, Colors.green,
        "Buscando persona en la Reniec...", contexto);
    help.getDataWsReniec(numero_documento).then((value) async {
      cerrarDialogGlobal(contexto);
      if (value["coResultado"] == "0000" || value["coResultado"] == "0001") {
        responseDialog(Icons.check, Colors.green,
            "Se han encontrado datos de la persona en la Reniec.", contexto);
        _controllerApeP.text = value["APPAT"].toString();
        _controllerApeM.text = value["APMAT"].toString();
        _controllerNombres.text = value["NOMBRES"].toString();
        backup.save("frapellido_paterno", value["APPAT"].toString());
        backup.save("frapellido_materno", value["APMAT"].toString());
        backup.save("frnombres", value["NOMBRES"].toString());
      } else {
        responseDialog(Icons.error, Colors.red,
            "No se han encontrado datos de la persona.\nRealice el registro manual.", contexto);
      }
    });

    //b.firstName.updateValue(await b.backup.read("firstName", ""));
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          padding: EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: readBackupParentesco(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      return DropDownField(
                        contentPadding: const EdgeInsets.only(bottom: 35.0),
                        titleText: 'Parentesco',
                        value: parentesco,
                        onChanged: (value) {
                          setState(() {
                            parentesco = value;
                          });
                          backup.save("parentesco", value.toString());
                        },
                        dataSource: snapshot.data.toList(),
                        textField: 'nombre',
                        valueField: 'id',
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: size.width - 68,
                  child: TextFormField(
                    controller: _controller,
                    autovalidate: true,
                    onChanged: (val) {
                      backup.save("frnumero_documento", val.toString());
                      if (val.length == 8) {
                        findDataFromServiceFamilia(context, val);
                      }
                    },
                    onSaved: (String val) {
                      //setState(() => _controller.text = val);
                    },
                    validator: (val) {
                      if (val.length != 8) {
                        return "El número de documento debe tener 8 dígitos";
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(
                          Icons.credit_card,
                          size: 28.0,
                        ),
                        labelText: "Número de documento"),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: size.width - 68,
                  child: TextFormField(
                    controller: _controllerApeP,
                    onChanged: (val) {
                      backup.save("frapellido_paterno", val.toString());
                      print("changed");
                    },
                    onSaved: (String val) {
                      //setState(() => _controllerApeP.text = val);
                    },
                    keyboardType: TextInputType.text,
                    validator: (val) {},
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(
                          Icons.person,
                          size: 28.0,
                        ),
                        labelText: "Apellido Paterno"),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: size.width - 68,
                  child: TextFormField(
                    controller: _controllerApeM,
                    autovalidate: true,
                    onChanged: (val) {
                      backup.save("frapellido_materno", val.toString());
                    },
                    onSaved: (String val) {
                      //setState(() => _controllerApeM.text = val);
                    },
                    keyboardType: TextInputType.text,
                    validator: (val) {},
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(
                          Icons.person,
                          size: 28.0,
                        ),
                        labelText: "Apellido Materno"),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: size.width - 68,
                  child: TextFormField(
                    controller: _controllerNombres,
                    autovalidate: true,
                    onChanged: (val) {
                      backup.save("frnombres", val.toString());
                    },
                    onSaved: (String val) {
                      //setState(() => _controllerNombres.text = val);
                    },
                    validator: (val) {},
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(
                          Icons.person,
                          size: 28.0,
                        ),
                        labelText: "Nombres"),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      //width: double.infinity,
                      padding: EdgeInsets.only(top: 30.0, left: 5),
                      child: RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        color: Colors.red,
                        onPressed: () {
                          if (_controller.text.length == 8) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Guardar",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Container(
                      //width: double.infinity,
                      padding: EdgeInsets.only(top: 30.0, left: 10),
                      child: RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        color: Colors.white,
                        onPressed: () {
                          backup.remove("frnumero_documento");
                          backup.remove("frapellido_paterno");
                          backup.remove("frapellido_materno");
                          backup.remove("frnombres");
                          backup.save("parentesco", "0");
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ));
  }
}

void responseDialog(
    IconData icon, Color color, String msj, BuildContext context) {
  showDialog(
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
                    children: <Widget>[
                      FlatButton(
                        child: Text("Aceptar"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  )
                ],
              )),
        );
      });
}

void cerrarDialogGlobal(BuildContext context) {
  Navigator.of(context).pop();
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
