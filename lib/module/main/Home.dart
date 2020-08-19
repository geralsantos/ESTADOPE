import 'dart:convert';

import 'package:estado/config.dart';
import 'package:estado/module/entity/Tables.dart';
import 'package:estado/module/main/AtachStep.dart';
import 'package:estado/module/main/CFDialog.dart';
import 'package:estado/module/sotorage/Storage.dart';
import 'package:estado/module/sotorage/Storage2.dart';
import 'package:estado/service/Helper.dart';
import 'package:estado/utils/CustomValidator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:estado/service/User.dart';
import 'package:estado/service/LocationService.dart';
import 'package:estado/service/Composition.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MainApp.dart';
import 'package:estado/module/main/LoadingDialog.dart';
import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/module/main/DropdownField.dart';
import 'dart:io';
import 'package:data_connection_checker/data_connection_checker.dart';

TextInputType _inputType = TextInputType.number;
var tiposDocumento = [];
var zonasEntregaG = [];
Storage storage = new Storage();
var codigoDni = "";
var isPasaporte = false, sinDNI = false;
int _ubigeoId;
FocusNode focusApeP;
FocusNode focusNumDoc;

class WizardFormBloc extends FormBloc<String, String> {
  int ubigeoId, userId;
  String documentPath, beneficiarioPath, geoLocation;
  Helper helper = new Helper();
  List<Composition> compositions = new List();
  var originalCompositions;
  bool savedInLocal = false;
  bool connectionStatus = false;
  BuildContext contexto;
  var searchBen = false;

  var _varprueba = true;

  FormBackup backup = new FormBackup();
  dynamic documentType = null;
  dynamic findObject(String id, List arr) {
    for (var o in arr) {
      if (o['id'].toString() == id) {
        return o;
      }
    }
    return null;
  }

  Future<bool> isInternet() async {
    try {
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
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void onLoading() async {
    super.onLoading();
    await backup.open();
    final prefs = await SharedPreferences.getInstance();
    dialogLoadingData(Icons.check_circle, Colors.green,
        "Verificando conexión a internet...", contexto);

    bool connectivityResult = await isInternet();
    cerrarDialogGlobal(contexto);
    var zonaentregainitvalue;
    var parentescoinitvalue;
    dynamic activeInternet = await backup.read("activeInternet", "true");
    if (activeInternet == "true" ? (connectivityResult) : false) {
      dialogLoadingData(
          Icons.check_circle,
          Colors.green,
          "Obteniendo datos del servidor, no retirar la conexión a internet...",
          contexto);
      connectionStatus = true;
      var docs = await helper.getDocuments();
      var types = await helper.getCaptureTypes(ubigeoId.toString());
      var states = await helper.getStates();
      var tipovivienda_sql = await helper.getTipoViviendas();
      var zonasentrega_sql = await helper.getZonasEntrega(ubigeoId.toString());
      var parentesco_sql = await helper.getParentesco();
      if (docs != null &&
          types != null &&
          states != null &&
          tipovivienda_sql != null &&
          docs.length > 0 &&
          types.length > 0 &&
          states.length > 0 &&
          tipovivienda_sql.length > 0) {
        select1.updateItems(docs);
        var bdoc = await backup.read("select1", docs[0]['id'].toString());
        if (bdoc == "1") {
          _inputType = TextInputType.number;
        } else {
          _inputType = TextInputType.text;
        }
        isPasaporte = bdoc == "3";
        sinDNI = bdoc == "4";

        //select1.updateInitialValue(findObject(bdoc.toString(), docs));
        var docType = findObject(bdoc.toString(), docs);
        select1.updateInitialValue(docType);
        documentType = docType;

        captureField.updateItems(types);
        var btype =
            await backup.read("captureField", types[0]['id'].toString());
        captureField.updateInitialValue(findObject(btype.toString(), types));
        //captureField.updateItems(types);

        if (zonasentrega_sql != null && zonasentrega_sql.length > 0) {
          zonaentregaField.updateItems(zonasentrega_sql);
          zonaentregainitvalue = await backup.read(
              "zonaentrega", zonasentrega_sql[0]['id'].toString());
          zonaentregaField.updateInitialValue(
              findObject(zonaentregainitvalue.toString(), zonasentrega_sql));
        }
        /*if(parentesco_sql != null && parentesco_sql.length > 0){
          zonaentregaField.updateItems(parentesco_sql);
          parentescoinitvalue =  await backup.read("zonaentrega", parentesco_sql[0]['id'].toString());
          zonaentregaField.updateInitialValue(findObject(parentescoinitvalue.toString(), parentesco_sql));
        }*/

        stateField.updateItems(states);
        var bstate =
            await backup.read("stateField", states[0]['id'].toString());
        stateField.updateInitialValue(findObject(bstate.toString(), states));

        tipovivienda.updateItems(tipovivienda_sql);
        var btipovivienda = await backup.read(
            "tipovivienda", tipovivienda_sql[0]['id'].toString());
        tipovivienda.updateInitialValue(
            findObject(btipovivienda.toString(), tipovivienda_sql));

        emitLoaded();
        cerrarDialogGlobal(contexto);
        if (savedInLocal == null || savedInLocal == false) {
          try {
            //await storage.open();
            await storage.dropDatabase();
            for (var doc in docs) {
              await storage.insert(
                  "tipodocumento", new TipoDocumento(doc['id'], doc['nombre']));
            }

            for (var row in types) {
              await storage.insert("tipocaptura",
                  new TipoCaptura(row['id'], row['nombre'], row['codigo']));
            }
            for (var row in states) {
              await storage.insert(
                  "estadoentrega", new EstadoEntrega(row['id'], row['nombre']));
            }
            for (var row in tipovivienda_sql) {
              await storage.insert(
                  "tipovivienda", new TipoVivienda(row['id'], row['nombre']));
            }

            for (var row in zonasentrega_sql) {
              await storage.insert(
                  "zonaentrega", new ZonaEntrega(row['id'], row['nombre']));
            }
            for (var row in parentesco_sql) {
              await storage.insert(
                  "parentesco", new Parentesco(row['id'], row['nombre']));
            }

            backup.pref.setBool("saved_in_local", true);
          } catch (err) {
            print("err");
            print(err);
          }
        }

        String usu = prefs.getString('usuario').toString(),
            contrasena = prefs.getString('contrasena').toString();
        if (usu != "" && contrasena != "") {
          print("helper.checkUser");
          await helper.checkUser(usu, contrasena).then((usuarioExiste) {
            if (usuarioExiste["estado"] == "error") {
              //si no existe el usuario
              responseDialogSaved(
                  Icons.error, Colors.red, usuarioExiste["mensaje"], contexto,
                  () async {
                prefs.clear();
                Navigator.pushReplacementNamed(contexto, '/login');
              });
            }
          }).catchError((onError) {
            print("helper.checkUser2 ERror");
            print(onError);
          });
        }
      } else {
        emitLoadFailed();
        responseDialog(Icons.error, Colors.red,
            "Ocurrió un error al obtener información del servidor!", contexto);
      }
    } else {
      responseDialog(
          Icons.warning, Colors.yellow, "No hay conexión a internet", contexto);
      //sin internet
      //await storage.open();
      var docs = await storage.getAll("tipodocumento", (var maps, int index) {
        return maps;
      });
      var types = await storage.getAll("tipocaptura", (var maps, int index) {
        return maps;
      });

      var states = await storage.getAll("estadoentrega", (var maps, int index) {
        return maps;
      });
      var tipovivienda_sql =
          await storage.getAll("tipovivienda", (var maps, int index) {
        return maps;
      });
      if (docs != null &&
          states != null &&
          types != null &&
          tipovivienda_sql != null) {
        docs = json.decode(json.encode(docs));
        states = json.decode(json.encode(states));
        types = json.decode(json.encode(types));
        tipovivienda_sql = json.decode(json.encode(tipovivienda_sql));

        select1.updateItems(docs);
        var bdoc = await backup.read("select1", docs[0]['id'].toString());
        select1.updateInitialValue(findObject(bdoc.toString(), docs));

        if (bdoc == "1") {
          _inputType = TextInputType.number;
        } else {
          _inputType = TextInputType.text;
        }
        isPasaporte = bdoc == "3";
        sinDNI = bdoc == "4";

        captureField.updateItems(types);
        var btype =
            await backup.read("captureField", types[0]['id'].toString());
        captureField.updateInitialValue(findObject(btype.toString(), types));
        stateField.updateItems(states);
        var bstate =
            await backup.read("stateField", states[0]['id'].toString());
        stateField.updateInitialValue(findObject(bstate.toString(), states));

        tipovivienda.updateItems(tipovivienda_sql);
        var btipovivienda = await backup.read(
            "tipovivienda", tipovivienda_sql[0]['id'].toString());
        tipovivienda.updateInitialValue(
            findObject(btipovivienda.toString(), tipovivienda_sql));

        emitLoaded();
      } else {
        emitLoadFailed();
      }
    }

    telephoneNumber.updateValue(await backup.read("telephoneNumber", ""));
    if (sinDNI) {
      backup.save("documentnumber", null);
      documentNumber.updateValue(null);
    } else {
      documentNumber.updateValue(await backup.read("documentNumber", ""));
    }

    firstName.updateValue(await backup.read("firstName", ""));
    lastName.updateValue(await backup.read("lastName", ""));
    name.updateValue(await backup.read("name", ""));
    direcction.updateValue(await backup.read("direcction", ""));

    description.updateValue(await backup.read("description", ""));
    populatedCenter.updateValue(await backup.read("populatedCenter", ""));

    select1.addValidators([
      (var value) {
        backup.save("select1", value['id'].toString());
        return null;
      }
    ]);

    zonaentregaField.addValidators([
      (value) {
        backup.save(
            "zonaentrega", value == null ? "0" : value['id'].toString());
        return null;
      }
    ]);

    captureField.addValidators([
      (var value) {
        backup.save("captureField", value['id'].toString());
        return null;
      }
    ]);
    tipovivienda.addValidators([
      (var value) {
        backup.save("tipovivienda", value['id'].toString());
        return null;
      }
    ]);
    stateField.addValidators([
      (var value) {
        backup.save("stateField", value['id'].toString());
        return null;
      }
    ]);
    geoLocation = await getLocation();
    userId = prefs.getInt('id');
  }

  var select1 = SelectFieldBloc(
    name: 'tipo_documento_id',
    items: [],
    validators: [CustomValidator.req("Seleccione el tipo de documento")],
    toJson: (value) => value['id'],
  );

  var zonaentregaField = SelectFieldBloc(
    name: 'zona_entrega_id',
    items: [],
    //validators: [CustomValidator.req("Seleccione una zona de entrega")],
    toJson: (value) => value['id'],
  );

  var captureField = SelectFieldBloc(
      name: 'tipo_captura_id',
      items: [],
      validators: [CustomValidator.req("Seleccione el tipo de entrega")],
      toJson: (value) => value['id']);
  var stateField = SelectFieldBloc(
      name: 'estado_entrega_id',
      items: [],
      validators: [CustomValidator.req("Seleccione el estado de entrega")],
      toJson: (value) => value['id']);
  var tipovivienda = SelectFieldBloc(
      name: 'tipo_vivienda_id',
      items: [],
      validators: [CustomValidator.req("Seleccione el tipo de vivienda")],
      toJson: (value) => value['id']);

  var documentNumber = TextFieldBloc(
    name:
        'numero_documento' /*,
    validators: [CustomValidator.req("Ingrese un número de documento")]*/
    ,
  );
  var telephoneNumber = TextFieldBloc(
    name: 'numero_telefono',
  );

  var name = TextFieldBloc(
      name: 'nombre', validators: [CustomValidator.req("Ingrese nombres")]);
  var description = TextFieldBloc(name: 'observaciones');

  var firstName = TextFieldBloc(
      name: 'primer_apellido',
      validators: [CustomValidator.req("Ingrese un apellido paterno")]);

  var lastName = TextFieldBloc(
      name: 'segundo_apellido',
      validators: [CustomValidator.req("Ingrese un aepllido materno")]);

  var direcction = TextFieldBloc(name: 'direccion');
  var populatedCenter = TextFieldBloc(name: 'centro_poblado');
  var ghost = TextFieldBloc(name: 'ghost');

  WizardFormBloc(int uId, int id, bool sil, BuildContext c)
      : super(isLoading: true) {
    documentNumber.addValidators([
      (value) {
        if (sinDNI) {
          return null;
        }
        if (value != null) {
          if (_inputType == TextInputType.number) {
            if (value.length == 8) {
              if (!isNumeric(value)) {
                return 'El núm. de DNI debe ser numérico';
              }
            } else {
              return 'El núm. de DNI debe ser igual a 8 dígitos';
            }
          } else if (_inputType == TextInputType.text) {
            if (isPasaporte) {
              if (value.length > 12) {
                return "El pasaporte debe ser máximo 12 dígitos";
              }
              return null;
            }
            if (value.length > 12) {
              return 'El núm. de carnet debe ser máximo 12 dígitos';
            }
          }
        } else {
          return 'Ingrese un número de documento';
        }
        return null;
      }
    ]);
    telephoneNumber.addValidators([
      (value) {
        if (value != null) {
          if (value.length > 9) {
            return 'El número debe ser menor o igual a 9 dígitos';
          }
        }
        return null;
      }
    ]);

    this.ubigeoId = uId;
    _ubigeoId = uId;
    //this.userId = id;

    //this.savedInLocal = sil;
    this.contexto = c;

    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        captureField,
        select1,
        documentNumber,
        firstName,
        lastName,
        name,
        telephoneNumber
      ],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [
        zonaentregaField,
        tipovivienda,
        direcction,
        populatedCenter,
        description,
        stateField
      ],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [ghost],
    );
  }
  @override
  void onSubmitting() async {
    if (geoLocation == null) {
      geoLocation = await getLocation();
    }
    if (state.currentStep == 0) {
      emitSuccess();
    } else if (state.currentStep == 1) {
      if (captureField.value['codigo'].toString() == '2' &&
          description.value.toString().trim().length == 0) {
        description.addError("Ingrese una observación");
        emitFailure(failureResponse: "Ingrese una observación");
      } else {
        emitSuccess();
      }
    } else if (state.currentStep == 2) {
      if (documentPath == null) {
        emitFailure(failureResponse: "Adjunte una foto de la Evidencia 1");
      } else {
        dynamic activeInternet = await backup.read("activeInternet", "true");
        bool connectivityResult = await isInternet();

        if (activeInternet == "true" ? (connectivityResult) : false) {
          var prefs = await SharedPreferences.getInstance();
          String usu = prefs.getString('usuario').toString(),
              contrasena = prefs.getString('contrasena').toString();
          if (usu != "" && contrasena != "") {
            await helper.checkUser(usu, contrasena).then((usuarioExiste) {
              if (usuarioExiste["estado"] == "error") {
                //si no existe el usuario
                responseDialogSaved(
                    Icons.error, Colors.red, usuarioExiste["mensaje"], contexto,
                    () async {
                  prefs.clear();
                  Navigator.pushReplacementNamed(contexto, '/login');
                });
              }
            }).catchError((onError) {
              print("helper.checkUser2 ERror");
              print(onError);
            });
          }
        }
        bool send = false, sendLocal = false;
        if (activeInternet == "true" ? (connectivityResult) : false) {
          send = await confirmSave(contexto, "¿Está seguro(a) de enviar?");
        } else {
          send = await confirmSave(contexto,
              "No hay conexión a internet, se va a guardar en local para luego sincronizar.");
          sendLocal = true;
        }

        if (send) {
          var tipodoc = await backup.read("select1", null);
          var frnumero_documento = await backup.read("frnumero_documento", "");
          var frapellido_paterno = await backup.read("frapellido_paterno", "");
          var frapellido_materno = await backup.read("frapellido_materno", "");
          var frnombres = await backup.read("frnombres", "");
          var frparentesco = await backup.read("parentesco", "0");
          var zonaentrega_ = await backup.read("zonaentrega", "0");
          print("sendddd userId");print(userId);
          dynamic status = await helper.save(
              state.toJson(),
              documentPath,
              beneficiarioPath,
              ubigeoId,
              userId,
              geoLocation,
              compositions,
              tipodoc,
              zonaentrega_,
              frnumero_documento,
              frapellido_paterno,
              frapellido_materno,
              frnombres,
              frparentesco,
              sendLocal);

          if (status != null) {
            backup.remove("documentNumber");
            backup.remove("telephoneNumber");
            backup.remove("firstName");
            backup.remove("lastName");
            backup.remove("name");
            backup.remove("direcction");
            backup.remove("description");
            backup.remove("populatedCenter");
            //backup.remove("select1");
            //backup.remove("captureField");
            //backup.remove("stateField");
            backup.remove("compositions");
            backup.remove("documentPath");
            backup.remove("beneficiarioPath");
            backup.remove("zonaentrega");
            backup.remove("parentesco");
            backup.remove("frnumero_documento");
            backup.remove("frapellido_paterno");
            backup.remove("frapellido_materno");
            backup.remove("frnombres");
            //if (status == true) {
            if (status["estado"] == "success" && sendLocal) {
              //se guarda local
              emitSuccess(successResponse: status["mensaje"]);
            } else {
              //status == false
              if (status["estado"] == "error") {
                // enviado a servidor pero sale error
                emitFailure(failureResponse: status["mensaje"]);
              } else {
                // enviado a servidor
                if (tipodoc == "4") {
                  var data = json.decode(status["data"]);
                  responseDialogSaved(
                      Icons.check,
                      Colors.green,
                      "EL CÓDIGO GENERADO PARA EL BENEFICIARIO ES: " +
                          data["data"],
                      contexto, () {
                    emitSuccess(successResponse: status["mensaje"]);
                  });
                } else {
                  emitSuccess(successResponse: status["mensaje"]);
                }
              }
            }
          } else {
            emitFailure(
                failureResponse:
                    "Ocurrió un error inesperado, intentelo nuevamente!");
          }
        } else {
          emitSuccess(successResponse: "nosave");
        }
      }
    }
  }

  Future<bool> findDataFromServiceCanasta(
      WizardFormBloc b, String numero_documento) async {
    Helper help = new Helper();
    bool connectivityResult = await isInternet();

    dynamic activeInternet = await backup.read("activeInternet", "true");
    var response = false;
    if (activeInternet == "false" ? true : (connectivityResult == false)) {
      return false;
    }
    dialogLoadingData(Icons.check_circle, Colors.green,
        "Buscando beneficiario en Canastas...", contexto);
    help.getDataBeneficiario(numero_documento).then((value) async {
      if (value["beneficiario"] != null) {
        String direccion = value["beneficiario"]["direccion"] == null
            ? ""
            : value["beneficiario"]["direccion"].toString();
        String numero_telefono =
            value["beneficiario"]["numero_telefono"] == null
                ? ""
                : value["beneficiario"]["numero_telefono"].toString();
        String centro_poblado = value["beneficiario"]["centro_poblado"] == null
            ? ""
            : value["beneficiario"]["centro_poblado"].toString();
        String zona_entrega_id =
            value["beneficiario"]["zona_entrega_id"] == null
                ? "0"
                : value["beneficiario"]["zona_entrega_id"].toString();

        b.firstName
            .updateValue(value["beneficiario"]["primer_apellido"].toString());
        b.lastName
            .updateValue(value["beneficiario"]["segundo_apellido"].toString());
        b.name.updateValue(value["beneficiario"]["nombre"].toString());
        b.direcction.updateValue(direccion);
        b.telephoneNumber.updateValue(numero_telefono);
        b.populatedCenter.updateValue(centro_poblado);

        b.backup.save(
            "firstName", value["beneficiario"]["primer_apellido"].toString());
        b.backup.save(
            "lastName", value["beneficiario"]["segundo_apellido"].toString());
        b.backup.save("name", value["beneficiario"]["nombre"].toString());
        b.backup.save("direcction", direccion);
        b.backup.save("telephoneNumber", numero_telefono);
        b.backup.save("populatedCenter", centro_poblado);
        b.backup.save("zonaentrega", zona_entrega_id.toString());

        cerrarDialogGlobal(contexto);
        responseDialog(
            Icons.check,
            Colors.green,
            "Se han encontrado datos de el beneficiario en Canastas.",
            contexto);
        focusApeP.requestFocus();

        if (value["composicion"] != null) {
          var obs = {};
          value["composicion"].forEach((element) {
            obs["cf011"] = "0";
            obs["cf1217"] = "0";
            obs["cf1829"] = "0";
            obs["cf3059"] = "0";
            obs["cf60"] = "0";
            if (element["composicion_familiar_id"] == 1) {
              obs["cf011"] = element["cantidad"].toString();
            }
            if (element["composicion_familiar_id"] == 2) {
              obs["cf1217"] = element["cantidad"].toString();
            }
            if (element["composicion_familiar_id"] == 3) {
              obs["cf1829"] = element["cantidad"].toString();
            }
            if (element["composicion_familiar_id"] == 4) {
              obs["cf3059"] = element["cantidad"].toString();
            }
            if (element["composicion_familiar_id"] == 5) {
              obs["cf60"] = element["cantidad"].toString();
            }
          });
          b.backup.save("compositions", json.encode(obs));
        }
      } else {
        cerrarDialogGlobal(contexto);
        responseDialog(
            Icons.error,
            Colors.red,
            "No se han encontrado datos de el beneficiario.\nRealice el registro manual.",
            contexto);
        focusApeP.requestFocus();
      }
      b._varprueba = true;
      response = true;
    });
  }

  Future<bool> findDataFromService(
      WizardFormBloc b, String numero_documento) async {
    Helper help = new Helper();
    bool connectivityResult = await isInternet();

    dynamic activeInternet = await backup.read("activeInternet", "true");
    var response = false;
    if (activeInternet == "false" ? true : (connectivityResult == false)) {
      return false;
    }
    dialogLoadingData(Icons.check_circle, Colors.green,
        "Buscando beneficiario en la Reniec...", contexto);
    b._varprueba = false;
    help.getDataWsReniec(numero_documento).then((value) async {
      cerrarDialogGlobal(contexto);
      if (value["coResultado"] == "0000" || value["coResultado"] == "0001") {
        responseDialog(
            Icons.check,
            Colors.green,
            "Se han encontrado datos de el beneficiario en la Reniec.",
            contexto);
        b.firstName.updateValue(value["APPAT"].toString());
        b.lastName.updateValue(value["APMAT"].toString());
        b.name.updateValue(value["NOMBRES"].toString());
        b.backup.save("firstName", value["APPAT"].toString());
        b.backup.save("lastName", value["APMAT"].toString());
        b.backup.save("name", value["NOMBRES"].toString());
        focusApeP.requestFocus();
      } else {
        findDataFromServiceCanasta(b, numero_documento);
      }
    });

    //b.firstName.updateValue(await b.backup.read("firstName", ""));
    return response;
  }
}

class WizardForm extends StatefulWidget {
  final User user;

  WizardForm(this.user);
  @override
  _WizardFormState createState() => _WizardFormState();
}

class _WizardFormState extends State<WizardForm> {
  var _tipodocumento = 1;
  var _zonaentrega = 0;
  var cargarInit = false;
  var cargarInit2 = false;

  @override
  void initState() {
    super.initState();
    focusApeP = FocusNode();
    focusNumDoc = FocusNode();
    _readBackupSelect2();
    _readBackupZonaEntrega();
  }

  void _readBackupSelect2() {
    readBackupSelect2().then((onValue) {
      setState(() {
        tiposDocumento = onValue;
      });
    });
  }

  void _readBackupZonaEntrega() {
    readBackupZonaEntrega().then((onValue) {
      setState(() {
        zonasEntregaG = onValue;
      });
    });
  }

  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
         try {
            Helper helper = new Helper();
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
        // Wifi detected & internet connection confirmed.
         try {
            Helper helper = new Helper();
            var docs = await helper.getDocuments();
              if (docs == null) {
                return false;
              }
            } on SocketException catch (_) {
              return false;
            } catch(ex){
              return false;
            }
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

  Future readBackupZonaEntrega() async {
    final prefs = await SharedPreferences.getInstance();
    bool connectivityResult = await isInternet();

    var docs;
    //await storage.open();
    dynamic activeInternet = await backup.read("activeInternet", "true");
    if (activeInternet == "true" ? (connectivityResult) : false) {
      Helper helper = new Helper();
      docs = await helper.getZonasEntrega(prefs.getInt('ubigeo_id').toString());
      List list = docs;
      if (docs != null && docs.length > 0) {
        list.insert(0, {"id": 0, "nombre": "Zona de entrega"});
      }
      return list;
    } else {
      //await storage.open();
      docs = await storage.getAll("zonaentrega", (var maps, int index) {
        return maps;
      });
      List list_ = [];

      if (docs != null && docs.length > 0) {
        for (int i = 0; i < docs.length; i++) {
          if (i == 0) {
            list_.add({'id': 0, 'nombre': "Zona de entrega"});
          }
          list_.add(docs[i]);
        }
      }
      return json.decode(json.encode(list_));
    }
  }

  Future readBackupSelect2() async {
    bool connectivityResult = await isInternet();

    var docs;
    //await storage.open();
    dynamic activeInternet = await backup.read("activeInternet", "true");
    if (activeInternet == "true" ? (connectivityResult) : false) {
      Helper helper = new Helper();
      docs = await helper.getDocuments();
      return docs;
    } else {
      //await storage.open();
      docs = await storage.getAll("tipodocumento", (var maps, int index) {
        return maps;
      });

      return json.decode(json.encode(docs));
    }
  }

  Future<String> codigoDniGenerar(
      dynamic numero_documento, WizardFormBloc wizardFormBloc) async {
    var tipoDoc = await wizardFormBloc.backup.read("select1", "");
    if (tipoDoc != "1") {
      setState(() {
        codigoDni = "";
      });
      return "";
    }
    numero_documento = await wizardFormBloc.backup.read("documentNumber", "");
    if (numero_documento != "" && numero_documento != null) {
      var response = "";
      int i = 0, suma = 0;
      var residuo = 0, x_ = 0, posicion = 0;
      var factores = [3, 2, 7, 6, 5, 4, 3, 2],
          codigos = [
            "6 ó K",
            "7 ó A",
            "8 ó B",
            "9 ó C",
            "0 ó D",
            "1 ó E",
            "1 ó F",
            "2 ó G",
            "3 ó H",
            "4 ó I",
            "5 ó J"
          ];
      numero_documento.runes.forEach((int rune) {
        var character = new String.fromCharCode(rune);
        suma += int.parse(character) * factores[i];
        i++;
      });
      residuo = suma % 11;
      x_ = residuo == 0 ? 0 : 11 - residuo;
      posicion = x_;
      response = codigos[posicion];
      wizardFormBloc.backup.save("codigoDni", response);
      setState(() {
        codigoDni = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WizardFormBloc(widget.user.getubigeoId(),
          widget.user.getId(), widget.user.savedInLocal, context),
      child: Builder(
        builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(20),
                    ),
              ),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: FormBlocListener<WizardFormBloc, String, String>(
                  onSubmitting: (context, state) {
                    LoadingDialog.show(context);
                  },
                  onSuccess: (context, state) {
                    LoadingDialog.hide(context);

                    if (state.stepCompleted == state.lastStep &&
                        state.successResponse != "nosave") {
                      responseDialog(Icons.check_circle, Colors.green,
                          state.successResponse, context);

                      Future.delayed(Duration(seconds: 3), () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) =>
                                MainApp(title: APP_TITLE, user: widget.user)));
                      });
                    } else {
                      //cerrarDialogGlobal(context);
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                    responseDialog(Icons.error, Colors.redAccent,
                        state.failureResponse, context);
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    type: StepperType.vertical,
                    controlsBuilder: (context, onStepContinue, onStepCancel,
                        step, formBloc) {
                      return Row(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              onStepContinue();
                            },
                            color: Colors.red,
                            textColor: Colors.white,
                            child: const Text('Continuar'),
                          ),
                          FlatButton(
                            onPressed: onStepCancel,
                            child: const Text('Regresar'),
                          ),
                        ],
                      );
                    },
                    onStepTapped: (FormBloc f, int i) {},
                    physics: ClampingScrollPhysics(),
                    stepsBuilder: (formBloc) {
                      return [
                        _generalStep(formBloc),
                        _aditionalStep(formBloc),
                        _atachmentStep(formBloc, context),
                      ];
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  FormBlocStep _generalStep(WizardFormBloc wizardFormBloc) {
    if (!cargarInit2) {
      cargarInit2 = true;
      //setState(() {
      isPasaporte = wizardFormBloc.select1 == "3";
      sinDNI = wizardFormBloc.select1 == "4";
      //});
      codigoDniGenerar(wizardFormBloc.documentNumber, wizardFormBloc);
    }
    return FormBlocStep(
      title: Text('General.'),
      content: Column(
        children: <Widget>[
          DropdownFieldBlocBuilder(
            selectFieldBloc: wizardFormBloc.captureField,
            decoration: InputDecoration(
              labelText: 'Tipo de registro',
              prefixIcon: Icon(Icons.apps),
            ),
            itemBuilder: (context, value) {
              return value['nombre'];
            },
          ),
          FutureBuilder(
            future: readBackupSelect1(wizardFormBloc),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data != null) {
                return DropDownField(
                  contentPadding: const EdgeInsets.only(bottom: 30.0),
                  titleText: 'Tipo documento',
                  value: int.parse(snapshot.data),
                  onChanged: (value) {
                    if (value == 1) {
                      setState(() {
                        _inputType = TextInputType.number;
                      });
                      codigoDniGenerar(
                          wizardFormBloc.documentNumber, wizardFormBloc);
                    } else {
                      setState(() {
                        _inputType = TextInputType.text;
                        codigoDni = "";
                      });
                    }
                    _tipodocumento = value;
                    setState(() {
                      isPasaporte = value == 3;
                      sinDNI = value == 4;
                    });
                    wizardFormBloc.backup.save("firstName", null);
                    wizardFormBloc.backup.save("lastName", null);
                    wizardFormBloc.backup.save("telephoneNumber", null);
                    wizardFormBloc.backup.save("name", null);
                    wizardFormBloc.backup.save("documentnumber", null);
                    wizardFormBloc.firstName.updateValue(null);
                    wizardFormBloc.lastName.updateValue(null);
                    wizardFormBloc.telephoneNumber.updateValue(null);
                    wizardFormBloc.name.updateValue(null);
                    wizardFormBloc.documentNumber.updateValue(null);

                    wizardFormBloc.backup.save("select1", value.toString());
                    focusNumDoc.requestFocus();

                    /*if (value == 4) {
                      wizardFormBloc.backup.save("documentnumber", null);
                      wizardFormBloc.documentNumber.updateValue(null);
                    }else {
                      updateValueDocNumber(wizardFormBloc);
                    }*/
                    //wizardFormBloc.backup.save("documentNumber", "awdw");
                  },
                  dataSource: tiposDocumento,
                  textField: 'nombre',
                  valueField: 'id',
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          FutureBuilder(
            future: readBackupSelect1(wizardFormBloc),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data != null) {
                return TextFieldBlocBuilder(
                  textFieldBloc: wizardFormBloc.documentNumber,
                  isEnabled:
                      !cargarInit ? int.parse(snapshot.data) != 4 : !sinDNI,
                  onTap: () {
                    setState(() {
                      cargarInit = true;
                    });
                    if (int.parse(snapshot.data) != 1) {
                      setState(() {
                        _inputType = TextInputType.text;
                      });
                    } else {
                      setState(() {
                        _inputType = TextInputType.number;
                      });
                    }
                  },
                  keyboardType: (int.parse(snapshot.data) != 1
                      ? (!cargarInit ? TextInputType.text : _inputType)
                      : _inputType),
                  onChanged: (val) {
                    if (isNumeric(val) &&
                        val.length == 8 &&
                        !isPasaporte &&
                        !sinDNI &&
                        _inputType == TextInputType.number) {
                      codigoDniGenerar(val, wizardFormBloc);
                      wizardFormBloc
                          .findDataFromService(wizardFormBloc, val)
                          .then((value) async {
                        if (value) {
                          var ze = await wizardFormBloc.backup
                              .read("zonaentrega", 0);
                          setState(() {
                            _zonaentrega = int.parse(ze);
                          });
                        } else {
                          var ze = await wizardFormBloc.backup
                              .read("zonaentrega", 0);
                          setState(() {
                            _zonaentrega = int.parse(ze);
                          });
                        }
                      });
                    } else {
                      setState(() {
                        codigoDni = "";
                      });
                    }
                    wizardFormBloc.backup.save("documentNumber", val);
                  },
                  decoration: InputDecoration(
                      labelText: 'Número de documento',
                      prefixIcon: Icon(Icons.credit_card),
                      helperText: "Dígito: " +
                          (codigoDni == '' ? 'VISIBLE PARA DNI' : codigoDni)),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.firstName,
            onChanged: (val) {
              wizardFormBloc.backup.save("firstName", val);
            },
            focusNode: focusApeP,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                labelText: 'Apellido paterno',
                prefixIcon: Icon(Icons.account_circle)),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.lastName,
            onChanged: (val) {
              wizardFormBloc.backup.save("lastName", val);
            },
            decoration: InputDecoration(
                labelText: 'Apellido materno',
                prefixIcon: Icon(Icons.account_circle)),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.name,
            onChanged: (val) {
              wizardFormBloc.backup.save("name", val);
            },
            decoration: InputDecoration(
                labelText: 'Nombres', prefixIcon: Icon(Icons.person)),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.telephoneNumber,
            onChanged: (val) {
              wizardFormBloc.backup.save("telephoneNumber", val);
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'Número de teléfono', prefixIcon: Icon(Icons.phone)),
          ),
        ],
      ),
    );
  }

  FormBlocStep _aditionalStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Observaciones.'),
      content: Column(
        children: <Widget>[
          FutureBuilder(
            future: readBackupSelectZonaE(wizardFormBloc),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data != null) {
                return DropDownField(
                  contentPadding: const EdgeInsets.only(bottom: 30.0),
                  titleText: 'Zona / AAHH',
                  value: int.parse(snapshot.data) ?? _zonaentrega,
                  onChanged: (value) {
                    wizardFormBloc.backup.save("zonaentrega", value.toString());
                    setState(() {
                      _zonaentrega = value;
                    });
                  },
                  hintText: "Zona / AAHH",
                  dataSource: zonasEntregaG,
                  textField: 'nombre',
                  valueField: 'id',
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          DropdownFieldBlocBuilder(
            selectFieldBloc: wizardFormBloc.tipovivienda,
            decoration: InputDecoration(
              labelText: 'Lugar de registro de información',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) {
              return value['nombre'];
            },
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.direcction,
            onChanged: (val) {
              wizardFormBloc.backup.save("direcction", val);
            },
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.populatedCenter,
            onChanged: (val) {
              wizardFormBloc.backup.save("populatedCenter", val);
            },
            decoration: InputDecoration(
              labelText: 'Detalle',
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          wizardFormBloc._varprueba
              ? CFDialog((chips, args) {
                  wizardFormBloc.compositions = chips;
                  if (args != null) {
                    wizardFormBloc.backup
                        .save("compositions", json.encode(args));
                  }
                })
              : SizedBox(height: 10),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.description,
            onChanged: (val) {
              wizardFormBloc.backup.save("description", val);
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: 'Observaciones',
              prefixIcon: Icon(Icons.comment),
            ),
          ),
          Container(
            width: 250,
            height: 50,
            child: RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/familia');
              },
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'FAMILIAR RECEPTOR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                    Icon(
                      Icons.person_add,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          /*RaisedButton(
          
          color: Colors.red,
          textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/familia');
            },
          ),*/

          DropdownFieldBlocBuilder(
            selectFieldBloc: wizardFormBloc.stateField,
            decoration: InputDecoration(
              labelText: 'Estado de entrega',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) {
              return value['nombre'];
            },
          ),
        ],
      ),
    );
  }
}

FormBlocStep _atachmentStep(
    WizardFormBloc wizardFormBloc, BuildContext context) {
  return FormBlocStep(
      title: Text('Adjuntos.'),
      content: AtachStep((String docPath) {
        wizardFormBloc.documentPath = docPath;
        wizardFormBloc.backup.save("documentPath", docPath);
      }, (String bePath) {
        wizardFormBloc.beneficiarioPath = bePath;
        wizardFormBloc.backup.save("beneficiarioPath", bePath);
      }));
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

void responseDialogSaved(IconData icon, Color color, String msj,
    BuildContext context, dynamic callback) {
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
                  Icon(icon, size: 60, color: color),
                  Text(msj, style: TextStyle(fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Aceptar"),
                        onPressed: () {
                          callback();
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

Future<bool> confirmSave(BuildContext context, String msj) async {
  return await showDialog(
      context: context,
      builder: (BuildContext bc) {
        return Dialog(
          child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              height: 190,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.help, size: 60, color: Colors.grey),
                  Text(msj, style: TextStyle(fontSize: 18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Cancelar"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        child: Text("Enviar"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    ],
                  )
                ],
              )),
        );
      });
}

Future readBackupSelectZonaE(WizardFormBloc b) async {
  return await b.backup.read("zonaentrega", "1");
}

Future readBackupSelect1(WizardFormBloc b) async {
  return await b.backup.read("select1", "1");
}

Future updateValueDocNumber(WizardFormBloc b) async {
  b.documentNumber.updateValue(null);
  b.documentNumber.updateValue(await b.backup.read("documentNumber", ""));
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
