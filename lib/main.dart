import 'package:estado/service/User.dart';
import 'package:flutter/material.dart';
import './config.dart';
import './module/login/Login.dart';
import './module/main/MainApp.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
User currentUser;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_TITLE,
      supportedLocales: [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: Locale("es"),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: APP_TITLE),
      routes: <String,WidgetBuilder>{
        '/login':(BuildContext context)=>new LoginForm(),
        '/app':(BuildContext context)=>new MainApp(title: APP_TITLE,user: currentUser)
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
  
    super.initState();
       print("init");
     read();
  }
  void read() async{
   User u= new User();
     await u.read();
     setState(() {
       currentUser=u;
     });
     if(u.isAuth()){
       Navigator.pushReplacementNamed(context, '/app');
     }else{
        Navigator.pushReplacementNamed(context, '/login');
     }
    
  }
  Future<Widget> loadImage() async{
    return    Image(
                image:AssetImage("assets/logo.png"),
                fit: BoxFit.contain,
                height: 150,
                
           );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration( 
          color:Color(int.parse("0xfff44336"))
        ),
        child: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FutureBuilder(
              builder:(BuildContext c,s){
                return Text('Cargando datos...',
                style: TextStyle(color: Colors.white));
              },
              future:loadImage(),
              ),
            Text(
              APP_TITLE,
              style:TextStyle(color: Colors.white,fontSize: 20),
            
            ),
          ],
        ),
      ),
      )
      
    );
  }
}
