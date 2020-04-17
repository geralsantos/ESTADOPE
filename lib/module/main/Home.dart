import 'package:estado/config.dart';
import 'package:estado/module/main/AtachStep.dart';
import 'package:estado/module/main/CFDialog.dart';
import 'package:estado/service/Helper.dart';
import 'package:estado/utils/CustomValidator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:estado/service/User.dart';
import 'package:estado/service/LocationService.dart';
import 'package:estado/service/Composition.dart';

import 'MainApp.dart';

class WizardFormBloc extends FormBloc<String, String> {
  int ubigeoId, userId;
  String documentPath, beneficiarioPath, geoLocation;
  Helper helper = new Helper();
  List<Composition> compositions = new List();
  @override
  void onLoading() async {
    super.onLoading();

   var docs = await helper.getDocuments();
   var types = await helper.getCaptureTypes(ubigeoId.toString());
   var states = await helper.getStates();

    if (docs != null && types != null && states != null) {
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

  final direcction = TextFieldBloc(
      name: 'direccion',
      validators: [CustomValidator.req("Ingrese una dirección")]);
  final populatedCenter = TextFieldBloc(name: 'centro_poblado');
  final ghost = TextFieldBloc(name: 'ghost');
  WizardFormBloc(int uId, int id) : super(isLoading: true) {
    this.ubigeoId = uId;
    this.userId = id;

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
    description
      ..addValidators([addRequiredDescription(captureField)])
      ..subscribeToFieldBlocs([captureField]);
  }
  Validator addRequiredDescription(SelectFieldBloc cap) {
    return (var val) {
      if (cap.value != null && cap.value.codigo == 2) {
        description.addValidators([FieldBlocValidators.required]);
        return "Ingrese una observación";
      }
      return null;
    };
  }

  /*void reset() {
    captureField.updateValue(types[0]);
    select1.updateValue(docs[0]);
    stateField.updateValue(states[0]);
    documentNumber.clear();
    firstName.clear();
    lastName.clear();
    name.clear();
    direcction.clear();
    populatedCenter.clear();
    description.updateValue("");
    compositions = [];
    documentPath = null;
    beneficiarioPath = null;
  }*/

  @override
  void onSubmitting() async {
    print("submit");
    if (state.currentStep == 0) {
      emitSuccess();
    } else if (state.currentStep == 1) {
      print(compositions);
      if (compositions == null || compositions.length == 0) {
        emitFailure(failureResponse: "Seleccione la compisicón por edad");
      } else {
        emitSuccess();
      }
    } else if (state.currentStep == 2) {
      if (documentPath == null) {
        emitFailure(failureResponse: "Adjunte la foto del Documento");
      } else {
        emitSubmitting();
        bool status = await helper.save(state.toJson(), documentPath,
            beneficiarioPath, ubigeoId, userId, geoLocation, compositions);
        if (status) {
          emitSuccess(successResponse: "Registro enviado con éxito");
        } else {
          emitFailure(
              failureResponse:
                  "Ocurrió un error inesperado, intentelo nuevamente!");
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
      create: (context) =>
          WizardFormBloc(widget.user.getubigeoId(), widget.user.getId()),
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
                  onSubmitting: (context, state) => LoadingDialog.show(context),
                  onSuccess: (context, state) {
                    LoadingDialog.hide(context);

                    if (state.stepCompleted == state.lastStep) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text(state.successResponse)));
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) =>
                      MainApp(title: APP_TITLE, user: widget.user)));
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text(state.failureResponse)));
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    type: StepperType.vertical,
                    onStepTapped: (FormBloc f, int i) {
                      print("tapping");
                      print(i);
                    },
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
              labelText: 'Tipo captura',
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

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
