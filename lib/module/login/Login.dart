import 'dart:io';

import 'package:estado/module/main/MainApp.dart';
import 'package:estado/service/Helper.dart';
import 'package:estado/service/User.dart';
import 'package:estado/utils/CustomValidator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estado/config.dart';
import 'package:estado/module/main/LoadingDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

User loggedUser;

class LoginFormBloc extends FormBloc<String, String> {
  final email = TextFieldBloc(
    validators: [CustomValidator.req("Ingrese su usuario")],
  );

  final password = TextFieldBloc(
    validators: [CustomValidator.req("Ingrese su contraseña")],
  );
BuildContext context;
  LoginFormBloc(BuildContext c) {
    context=c;
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }
  Future<bool> isInternet() async {
     Helper helper = new Helper();
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
          } catch (ex) {
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
          } catch (ex) {
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
  Future<bool> _login() async {
   
    final request = await http.post(ROOT+'/login/supervisor', body: {
      "usuario": email.value.trim(),
      "contrasena": password.value.trim(),
    });

    try {
      var response = json.decode(request.body);
      if (response.length == 0 || response['estado'] != 1) {
        return false;
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('nombres', response['nombres']);
        prefs.setString('apellidos', response['apellidos']);
        prefs.setString('usuario', response['usuario']);
        prefs.setString('contrasena', password.value.trim());
        prefs.setInt('id', response['id']);
        print("useriddddd");print(response['id']);
        prefs.setInt('ubigeo_id', response['ubigeo_id']);
        loggedUser = new User();
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
    bool internet = await isInternet();
    if(!internet){
      emitFailure(failureResponse: 'No hay conexión a internet.');
    }else{
      print(internet);

      bool state  = await _login();
      // print(state);
      if (state) {
        emitSuccess();
      } else {
        emitFailure(failureResponse: 'Usuario y/o contraseña incorrecta!');
      }
    }

    
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormBloc(context),
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
                    builder: (context) => MainApp(
                      user: loggedUser,
                      title: APP_TITLE,
                    ),
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
                      image: AssetImage("assets/logo.png"),
                      fit: BoxFit.contain,
                      height: 170,
                    ),
                    Container(
                      height: 50,
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
                      child: RaisedButton(
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

