
import 'package:estado/service/Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
class WizardFormBloc extends FormBloc<String, String> {
   @override
   void onLoading() async {
    super.onLoading();
    Helper helper=new Helper();
    var docs=await helper.getDocuments();
    if(docs!=null){
     select1.updateItems(docs);
     select1.updateInitialValue(docs[0]);
    emitLoaded();
    }else{
      emitLoadFailed();
    }
  }
   
   final select1 = SelectFieldBloc(
   items:[],
   );
  final documentNumber = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );

  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  final firstName = TextFieldBloc(
    validators: [FieldBlocValidators.required,]
  );

  final lastName = TextFieldBloc(
    validators: [FieldBlocValidators.required,]
  );

  final gender = SelectFieldBloc(
    items: ['Male', 'Female'],
  );

  final birthDate = InputFieldBloc<DateTime, Object>(
    validators: [FieldBlocValidators.required],
  );

  final github = TextFieldBloc();

  final twitter = TextFieldBloc();

  final facebook = TextFieldBloc();

  WizardFormBloc():super(isLoading:true) {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [select1,documentNumber, firstName, lastName],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [email],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [github, twitter, facebook],
    );
  }

  @override
  void onSubmitting() async {

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
  @override
  _WizardFormState createState() => _WizardFormState();
}

class _WizardFormState extends State<WizardForm> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WizardFormBloc(),
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

                    physics: ClampingScrollPhysics(),
                    onStepContinue:null,
                    stepsBuilder: (formBloc) {
                     
                      return [
                        _accountStep(formBloc),
                        _personalStep(formBloc),
                        _socialStep(formBloc),
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

  FormBlocStep _accountStep(WizardFormBloc wizardFormBloc) {

    return FormBlocStep(
      title: Text('General'),
      
      content: Column(
        children: <Widget>[
           DropdownFieldBlocBuilder(
                          selectFieldBloc: wizardFormBloc.select1,
                          decoration: InputDecoration(
                            labelText: 'Tipo documento',
                            prefixIcon: Icon(Icons.sentiment_satisfied),
                          ),
                          itemBuilder: (context, value){
                            return value['nombre'];
                          },
                        ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.documentNumber,
            decoration: InputDecoration(
              labelText: 'Número de documento',
              prefixIcon: Icon(Icons.credit_card),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.firstName,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Apellido paterno',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.lastName,
            decoration: InputDecoration(
              labelText: 'Apellido materno',
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }

  FormBlocStep _personalStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Adjuntos'),
      content: Column(
        children: <Widget>[
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'First Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          
        ],
      ),
    );
  }

  FormBlocStep _socialStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Observaciones'),
      content: Column(
        children: <Widget>[
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.github,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Github',
              prefixIcon: Icon(Icons.sentiment_satisfied),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.twitter,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Twitter',
              prefixIcon: Icon(Icons.sentiment_satisfied),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.facebook,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Facebook',
              prefixIcon: Icon(Icons.sentiment_satisfied),
            ),
          ),
        ],
      ),
    );
  }
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

