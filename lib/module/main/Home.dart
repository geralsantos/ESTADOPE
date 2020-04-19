import 'dart:convert';

import 'package:estado/config.dart';
import 'package:estado/module/entity/Tables.dart';
import 'package:estado/module/main/AtachStep.dart';
import 'package:estado/module/main/CFDialog.dart';
import 'package:estado/module/sotorage/Storage.dart';
import 'package:estado/service/Helper.dart';
import 'package:estado/utils/CustomValidator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:estado/service/User.dart';
import 'package:estado/service/LocationService.dart';
import 'package:estado/service/Composition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'MainApp.dart';
import 'package:estado/module/main/LoadingDialog.dart';

class WizardFormBloc extends FormBloc<String, String> {
  int ubigeoId, userId;
  String documentPath, beneficiarioPath, geoLocation;
  Helper helper = new Helper();
  List<Composition> compositions = new List();
  bool savedInLocal = false;
  bool connectionStatus = false;
  BuildContext context;
  @override
  void onLoading() async {
    super.onLoading();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      connectionStatus = true;
      var docs = await helper.getDocuments();
      var types = await helper.getCaptureTypes(ubigeoId.toString());
      var states = await helper.getStates();
      if (docs != null && types != null && states != null
         && docs.length>0 && types.length>0 && states.length>0) {
        select1.updateItems(docs);
        select1.updateInitialValue(docs[0]);
        captureField.updateItems(types);
        captureField.updateInitialValue(types[0]);
        stateField.updateItems(states);
        stateField.updateInitialValue(states[0]);

        emitLoaded();
        if (!savedInLocal) {
          try {
            Storage storage = new Storage();
            await storage.open();
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
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool("saved_in_local", true);
            print("saved in local");
          } catch (err) {
            print(err);
          }
        }
      } else {
        emitLoadFailed();
        responseDialog(Icons.error, Colors.red, "Ocurrió un error al obtener información del servidor!", context);
      }
    } else {
      Storage storage = new Storage();
      await storage.open();
      var docs = await storage.getAll("tipodocumento", (var maps, int index) {
        return maps;
      });
      var types = await storage.getAll("tipocaptura", (var maps, int index) {
        return maps;
      });
      var states = await storage.getAll("estadoentrega", (var maps, int index) {
        return maps;
      });
      if (docs != null && states != null && types != null) {
        docs = json.decode(json.encode(docs));
        states = json.decode(json.encode(states));
        types = json.decode(json.encode(types));
        select1.updateItems(docs);
        select1.updateInitialValue(docs[0]);
        captureField.updateItems(types);
        captureField.updateInitialValue(types[0]);
        stateField.updateItems(states);
        stateField.updateInitialValue(states[0]);
        emitLoaded();
      } else {
        emitLoadFailed();
      }
    }
    geoLocation = await getLocation();
  }

  final select1 = SelectFieldBloc(
      name: 'tipo_documento_id',
      items: [],
      validators: [CustomValidator.req("Seleccione el tipo de documento")],
      toJson: (value) => value['id']);
  final captureField = SelectFieldBloc(
      name: 'tipo_captura_id',
      items: [],
      validators: [CustomValidator.req("Seleccione el tipo de entrega")],
      toJson: (value) => value['id']);
  final stateField = SelectFieldBloc(
      name: 'estado_entrega_id',
      items: [],
      validators: [CustomValidator.req("Seleccione el estado de entrega")],
      toJson: (value) => value['id']);
  final documentNumber = TextFieldBloc(
    name: 'numero_documento',
    validators: [
      CustomValidator.req("Ingrese un número de documento"),
      CustomValidator.equal("El número de documento debe tener 8 caracteres", 8)
    ],
  );
  final name = TextFieldBloc(
      name: 'nombre', validators: [CustomValidator.req("Ingrese nombres")]);
  final description = TextFieldBloc(name: 'observaciones');

  final firstName = TextFieldBloc(
      name: 'primer_apellido',
      validators: [CustomValidator.req("Ingrese un apellido paterno")]);

  final lastName = TextFieldBloc(
      name: 'segundo_apellido',
      validators: [CustomValidator.req("Ingrese un aepllido materno")]);

  final direcction = TextFieldBloc(name: 'direccion');
  final populatedCenter = TextFieldBloc(name: 'centro_poblado');
  final ghost = TextFieldBloc(name: 'ghost');
  WizardFormBloc(int uId, int id, bool sil,BuildContext c) : super(isLoading: true) {
    this.ubigeoId = uId;
    this.userId = id;
    this.savedInLocal = sil;
    this.context=c;

    addFieldBlocs(
      step: 0,
      fieldBlocs: [
        captureField,
        select1,
        documentNumber,
        firstName,
        lastName,
        name
      ],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [direcction, populatedCenter, description, stateField],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [ghost],
    );
  }

  @override
  void onSubmitting() async {
    print("submit");
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
        emitFailure(failureResponse: "Adjunte una foto del DNI+PLANILLA");
      } else {
       bool send=await confirmSave(context, "¿Está seguro(a) de enviar?");
       if(send){

          bool status = await helper.save(state.toJson(), documentPath,
            beneficiarioPath, ubigeoId, userId, geoLocation, compositions);
        if (status) {
          emitSuccess(successResponse: "Registro enviado con éxito");
        } else {
          emitFailure(
              failureResponse:
                  "Ocurrió un error inesperado, intentelo nuevamente!");
        }

       }else{
         emitSuccess(successResponse: "nosave");
       }
      }
    }
  }
}

class WizardForm extends StatefulWidget {
  final User user;
  WizardForm(this.user);
  @override
  _WizardFormState createState() => _WizardFormState();
}

class _WizardFormState extends State<WizardForm> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WizardFormBloc(widget.user.getubigeoId(),
          widget.user.getId(), widget.user.savedInLocal,context),
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

                    if (state.stepCompleted == state.lastStep && state.successResponse!="nosave") {
                      responseDialog(Icons.check_circle, Colors.green,
                          state.successResponse, context);
                          
                      Future.delayed(Duration(seconds: 3), () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) =>
                                MainApp(title: APP_TITLE, user: widget.user)));
                      });
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                    responseDialog(Icons.error, Colors.redAccent,
                        state.failureResponse, context);
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    type: StepperType.vertical,
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
    return FormBlocStep(
      title: Text('General'),
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
          DropdownFieldBlocBuilder(
            selectFieldBloc: wizardFormBloc.select1,
            decoration: InputDecoration(
                labelText: 'Tipo documento',
                prefixIcon: Icon(Icons.credit_card)),
            itemBuilder: (context, value) {
              return value['nombre'];
            },
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.documentNumber,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
                labelText: 'Número de documento',
                prefixIcon: Icon(Icons.credit_card)),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.firstName,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                labelText: 'Apellido paterno',
                prefixIcon: Icon(Icons.account_circle)),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.lastName,
            decoration: InputDecoration(
                labelText: 'Apellido materno',
                prefixIcon: Icon(Icons.account_circle)),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.name,
            decoration: InputDecoration(
                labelText: 'Nombres', prefixIcon: Icon(Icons.person)),
          ),
        ],
      ),
    );
  }

  FormBlocStep _aditionalStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Observaciones'),
      content: Column(
        children: <Widget>[
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.direcction,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.populatedCenter,
            decoration: InputDecoration(
              labelText: 'Centro poblado',
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          CFDialog((chips) {
            wizardFormBloc.compositions = chips;
          }),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.description,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: 'Observaciones',
              prefixIcon: Icon(Icons.comment),
            ),
          ),
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
      title: Text('Adjuntos'),
      content: AtachStep((String docPath) {
        wizardFormBloc.documentPath = docPath;
      }, (String bePath) {
        wizardFormBloc.beneficiarioPath = bePath;
      }));
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
              height: 160,
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
