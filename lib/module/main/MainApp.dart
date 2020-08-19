import 'dart:io';
 
import 'package:camera/camera.dart';
import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:flutter/material.dart';
import 'package:estado/service/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estado/module/main/Home.dart';
 
import 'LocalDonations.dart';
import 'dart:async';
import 'package:package_info/package_info.dart';
 
FormBackup backup = new FormBackup();
Icon iconInternet = Icon(Icons.cloud);
String estadoInternet = "Internet activo";

class MainApp extends StatefulWidget {
  MainApp({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final User user;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainApp> {
   PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future readStatusInternet() async {
    await backup.open();
    dynamic activeInternet = await backup.read("activeInternet", "true");
    print("readStatusInternet");
    print(activeInternet);
    if (activeInternet == "true") {
      setState(() {
        iconInternet = Icon(Icons.cloud);
        estadoInternet = "Internet Activo";
      });
    } else {
      setState(() {
        iconInternet = Icon(Icons.cloud_off);
        estadoInternet = "Internet Inactivo";
      });
    }
  }
 Future<String> getVersionNumber() async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  final prefs2 = await SharedPreferences.getInstance();
  prefs2.setString('packageInfoVersion',info.version);
  
    setState(() {
      _packageInfo = info;
    });
  }
  Future internetStatus() async {
    await backup.open();

    dynamic activeInternet = await backup.read("activeInternet", "true");
    backup.save("activeInternet", activeInternet == "true" ? "false" : "true");
    if (activeInternet == "true") {
      setState(() {
        iconInternet = Icon(Icons.cloud_off);
        estadoInternet = "Internet Inactivo";
      });
    } else {
      setState(() {
        iconInternet = Icon(Icons.cloud);
        estadoInternet = "Internet Activo";
      });
    }
  }

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
      readStatusInternet();
      getVersionNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: iconInternet,
            tooltip: estadoInternet,
            onPressed: () {
              internetStatus();
            },
          )
        ],
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
            Container(
              alignment: Alignment.bottomCenter,
              child: Text('v. '+_packageInfo.version),

            ),
          ],
        ),
      ),
      body: getCurrentView(),
    );
  }
}
