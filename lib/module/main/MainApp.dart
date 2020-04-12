import 'package:flutter/material.dart';
import 'package:estado/service/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MainApp extends StatefulWidget {
  MainApp({Key key, this.title,this.user}) : super(key: key);
  final String title;
  final User user;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainApp> {
  int _counter = 0;
  String user="",name="None";
  int id=-1,ubigeId=-1;

  void _incrementCounter() {

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  void _exitApp() async{
     final prefs= await SharedPreferences.getInstance();
     prefs.clear();
     Navigator.pop(context);
     Navigator.pushReplacementNamed(context, '/login');
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
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Perfil'),
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
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hiciste click:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.camera),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
