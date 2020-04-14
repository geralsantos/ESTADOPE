
import 'package:estado/service/Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:estado/service/User.dart';
class WizardFormBloc extends FormBloc<String, String> {
  int ubigeoId;
   @override
   void onLoading() async {
    super.onLoading();
    Helper helper=new Helper();
    var docs=await helper.getDocuments();
    var types=await helper.getCaptureTypes(ubigeoId.toString());
    var states=await helper.getStates();
    if(docs!=null && types!=null && states!=null){
     select1.updateItems(docs);
     select1.updateInitialValue(docs[0]);
     captureField.updateItems(types);
     captureField.updateInitialValue(types[0]);
     stateField.updateItems(states);
     stateField.updateInitialValue(states[0]);
    emitLoaded();
    }else{
      emitLoadFailed();
    }
  }
   
   final select1 = SelectFieldBloc(
   items:[],
   validators: [FieldBlocValidators.required]
   );
   final captureField=SelectFieldBloc(
     items: [],
     validators: [FieldBlocValidators.required]
   );
   final stateField=SelectFieldBloc(
     items: [],
     validators: [FieldBlocValidators.required]
   );
  final documentNumber=TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );
 final name=TextFieldBloc(
   validators: [FieldBlocValidators.required]
 );
  final description = TextFieldBloc();


  final firstName = TextFieldBloc(
    validators: [FieldBlocValidators.required,]
  );

  final lastName = TextFieldBloc(
    validators: [FieldBlocValidators.required,]
  );

  final direcction = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final populatedCenter = TextFieldBloc();

   final aux = TextFieldBloc(validators: [FieldBlocValidators.required,]);
  WizardFormBloc( int uId):super(isLoading:true) {
    this.ubigeoId=uId;
    addFieldBlocs(
      step: 0,
      fieldBlocs: [captureField,select1,documentNumber, firstName, lastName,name],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [direcction, populatedCenter,description, stateField],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [aux],
    );
  }

  @override
  void onSubmitting() async {
     print("submit");
    if (state.currentStep == 0) {
        emitSuccess();
    } else if (state.currentStep == 1) {
      emitSuccess();
    } else if (state.currentStep == 2) {
      emitSuccess();
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
      create: (context) => WizardFormBloc(widget.user.getubigeoId()),
      child: Builder(
        builder: (context) {
          return Theme(

            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
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
                    /*  Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => SuccessScreen()));
                          */
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    type: StepperType.vertical,
              
                    onStepTapped: (FormBloc f,int i){
                        print("tapping");
                        print(i);
                    },
                    physics: ClampingScrollPhysics(),
                    stepsBuilder: (formBloc) {
                     
                      return [
                        _generalStep(formBloc),
                       
                        _aditionalStep(formBloc),
                        
                         _atachmentStep(formBloc),
                      
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
                          itemBuilder: (context, value){
                            return value['nombre'];
                          },
                        ),
           DropdownFieldBlocBuilder(
                          selectFieldBloc: wizardFormBloc.select1,
                          decoration: InputDecoration(
                            labelText: 'Tipo documento',
                            prefixIcon: Icon(Icons.credit_card)
                          ),
                          itemBuilder: (context, value){
                            return value['nombre'];
                          },
                        ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.documentNumber,
            decoration: InputDecoration(
              labelText: 'Número de documento',
              prefixIcon: Icon(Icons.credit_card)
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.firstName,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Apellido paterno',
              prefixIcon: Icon(Icons.account_circle)
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.lastName,
            decoration: InputDecoration(
              labelText: 'Apellido materno',
              prefixIcon: Icon(Icons.account_circle)
            ),
          ),
           TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.name,
            decoration: InputDecoration(
              labelText: 'Nombres',
              prefixIcon: Icon(Icons.person)
            ),
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
          InputChip(
            label: Text('Composición'),
          ),
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
                          itemBuilder: (context, value){
                            return value['nombre'];
                          },
                        ),
        ],
      ),
    );
  }
}

  FormBlocStep _atachmentStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Adjuntos'),
      content: Column(
        children: <Widget>[
                   TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.aux,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: 'Observaciones',
              prefixIcon: Icon(Icons.comment),
            ),
          ),
          
        ],
      ),
    );
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

