import 'package:estado/module/main/About.dart';
import 'package:flutter/material.dart';
import 'package:estado/service/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estado/module/main/Home.dart';

class MainApp extends StatefulWidget {
  MainApp({Key key, this.title,this.user}) : super(key: key);
  final String title;
  final User user;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainApp> {

  String user="",name="None";
  int id=-1,ubigeId=-1,_selectedDrawerIndex=1;
  void _exitApp() async{
     final prefs= await SharedPreferences.getInstance();
     prefs.clear();
     Navigator.pop(context);
     Navigator.pushReplacementNamed(context, '/login');
  }
  void setDrawer(int index){
     setState(() {
      _selectedDrawerIndex=index;
     });
      Navigator.of(context).pop();
  }
  getCurrentView(){
    switch(_selectedDrawerIndex){
      case 1:
      return new WizardForm(widget.user);
      case 2:
      return new About();
      default:
    return new Text("error");
    }
  }
@override
  void initState() {
    super.initState();
   if(widget.user!=null){
     user=widget.user.getUser();
     name=widget.user.getName();
     id=widget.user.getId();
     ubigeId=widget.user.getubigeoId();
   }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
        drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.redAccent,
          ),
          
          child: Text(
             name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap:(){
            setDrawer(1);
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('About'),
          onTap: (){
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
  body: getCurrentView()
    );
  }
}
