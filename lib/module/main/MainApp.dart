import 'package:flutter/material.dart';
import 'package:estado/service/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estado/module/main/Home.dart';

import 'LocalDonations.dart';

class MainApp extends StatefulWidget {
  MainApp({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final User user;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainApp> {
  String user = "", name = "";
  int id = -1, ubigeId = -1, _selectedDrawerIndex = 1;
  void _exitApp() async {
    var result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
                  height: 120,
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('¿Está seguro(a) que desea cerrar sesión?'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text('Cerrar sesión'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          )
                        ],
                      )
                    ],
                  )));
        });
    if (result) {
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.of(context).pop();
    }
  }

  void setDrawer(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    Navigator.of(context).pop();
  }

  getCurrentView() {
    switch (_selectedDrawerIndex) {
      case 1:
        return new WizardForm(widget.user);
        case 2:
        return new LocalDonations();
      default:
        return new Text("error");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      user = widget.user.getUser();
      name = widget.user.getName();
      id = widget.user.getId();
      ubigeId = widget.user.getubigeoId();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        user,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Image(
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.contain,
                        height: 100,
                      )
                    ],
                  )),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Donaciones'),
                onTap: () {
                  setDrawer(1);
                },
              ),
                            ListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text('Sincronización'),
                onTap: () {
                  setDrawer(2);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Salir'),
                onTap: _exitApp,
              ),
            ],
          ),
        ),
        body: getCurrentView());
  }
}
