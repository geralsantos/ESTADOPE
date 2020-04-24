
import 'package:flutter/material.dart';
class Intro extends StatefulWidget{
  _IntroState createState(){
    return new _IntroState();
  }
}
class _IntroState extends State<Intro>{
int _index=0;
List<Widget> images=new List();
Image img1,img2,img3;
@override
  void initState() {
    super.initState();
    img1=Image.asset('assets/1.jpg');
    img2=Image.asset('assets/2.jpg');
    img3=Image.asset('assets/3.jpg');
   

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(img1.image,context);
    precacheImage(img2.image,context);
    precacheImage(img3.image,context);
  }
 void next(){
 setState(() {
    if(_index<2){
      _index++;
    }
  });
 }
 void back(){
  setState(() {
    if(_index>0){
      _index--;
    }
  });
 }
void toLogin(){
  //Navigator.of(context).pop();
 Navigator.pushReplacementNamed(context, '/login');
}
 Widget buildBackBtn(){
        if(_index>0){
          return  Positioned(
            bottom: 10,
            left: 20,
            child: RaisedButton(
              onPressed: back,
              child: Text('Anterior')
            ),
          );
        }
        return Positioned(
            bottom: 10,
            left: 20,
            child: RaisedButton(
              onPressed:toLogin,
              child: Text('Saltar')
            ),
          );
 }
Widget buildNextBtn(){
  if(_index==2){
     return Positioned(
            bottom: 10,
            right: 20,
            child: RaisedButton(
              onPressed:toLogin,
              child: Text('Iniciar sesión')
            ),
          );
  }
  return Positioned(
            bottom: 10,
            right: 20,
            child: RaisedButton(
              onPressed:next,
              child: Text('Siguiente')
            ),
          );
}

  @override
  Widget build(BuildContext context) {
 
    return  Container(
      height: MediaQuery.of(context).size.height,
      child:Stack(
       children: [
         Visibility(
           visible: _index==0,
            child: Image(image: img1.image,
               fit: BoxFit.cover,
              height:MediaQuery.of(context).size.height
          )
          
         ),
         Visibility(
           visible: _index==1,
          child: Image(image: img2.image,
               fit: BoxFit.cover,
              height:MediaQuery.of(context).size.height
          )
         ),
          Visibility(
           visible: _index==2,
          child: Image(image: img3.image,
               fit: BoxFit.cover,
              height:MediaQuery.of(context).size.height
          )
         ),
          buildBackBtn(),
          buildNextBtn()
       ],
      )
    );
  }

}