import 'package:estado/module/main/MainApp.dart';
import 'package:estado/service/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estado/config.dart';
User loggedUser;
class LoginFormBloc extends FormBloc<String, String> {
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );


  LoginFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }
Future<bool> _login() async {
  
  final request = await http.post(ROOT+'/login/supervisor/', body: {
    "usuario": email.value.trim(),
    "contrasena": password.value.trim(),
  });
//print(request.body);
try {
    var response = json.decode(request.body);
   // print(request.body);
    if(response.length==0 || response['estado']!=1){
  return false;
  }else{

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('nombres',response['nombres']);
  prefs.setString('apellidos', response['apellidos']);
  prefs.setString('usuario', response['usuario']);
  prefs.setInt('id', response['id']);
  prefs.setInt('ubigeo_id', response['ubigeo_id']);
 loggedUser=new User();
  loggedUser.setId(response['id']);
  loggedUser.setUser(response['usuario']);
  loggedUser.setName(response['nombres']);
  loggedUser.setSurnames(response['apellidos']);
  loggedUser.setUbigeoId(response['ubigeo_id']);
  
return true;
  }

  
} catch (e) {
  print(e.toString());
}
return false;
}
  @override
  void onSubmitting() async {
    print(email.value);
    print(password.value);

     bool state= await _login();
    // print(state);
    if (state) {
      emitSuccess();
    } else {
      emitFailure(failureResponse: 'Usuario y/o contraseña incorrecta!');
    }
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return BlocProvider(
      create: (context) => LoginFormBloc(),
      child: Builder(
        builder: (context) {
          final loginFormBloc = context.bloc<LoginFormBloc>();

          return Scaffold(
            resizeToAvoidBottomInset: false,
           // appBar: AppBar(title: Text('Login')),
            body: FormBlocListener<LoginFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
              // Navigator.pushReplacementNamed(context, '/app');
              Navigator.of(context).pop();
              Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainApp(user:loggedUser,title: APP_TITLE,),
          ),
        );
        
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);

                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
              },
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                   Container(
                     height: 50,
                   ),
                      Image(
                image:AssetImage("assets/logo.png"),
                fit: BoxFit.contain,
                height: 120,
                
              ),
                   Container(
                     height: 70,
                   ),
                    TextFieldBlocBuilder(
                      textFieldBloc: loginFormBloc.email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                         labelText: "Usuario",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_box),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: loginFormBloc.password,
                      suffixButton: SuffixButton.obscureText,
                      decoration: InputDecoration(
                         labelText: "Contraseña",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                   Container(
                     height: 30,
                   ),
                   SizedBox(
                     width: MediaQuery.of(context).size.width,
                     height: 48,
                     child:RaisedButton(
                      onPressed: loginFormBloc.submit,
                       shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                 ),
                 color: Colors.red,
                 textColor: Colors.white,
                      child: Text('INGRESAR'),
                    ),
                     ),
                  ],
                ),
              ),
            ),
          );
        },
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

