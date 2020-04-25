
import 'package:flutter/material.dart';
import 'package:swipe_gesture_recognizer/swipe_gesture_recognizer.dart';
class Intro extends StatefulWidget{
  _IntroState createState(){
    return new _IntroState();
  }
}
class _IntroState extends State<Intro>{
int _index=0;
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
  return Container();
}

  @override
  Widget build(BuildContext context) {
 
    return  Container(
      height: MediaQuery.of(context).size.height,
      child:Stack(
       children: [
         SwipeGestureRecognizer(
           onSwipeLeft: next,
           child: Visibility(
           visible: _index==0,
            child: Image(image: img1.image,
               fit: BoxFit.cover,
              height:MediaQuery.of(context).size.height
          )
          
         )
         )
         ,
         SwipeGestureRecognizer(
           onSwipeRight: back,
           onSwipeLeft: next,
           child: Visibility(
           visible: _index==1,
          child: Image(image: img2.image,
               fit: BoxFit.cover,
              height:MediaQuery.of(context).size.height
          )
         )
         )
         ,
         SwipeGestureRecognizer(
           onSwipeRight: back,
           child:  Visibility(
           visible: _index==2,
          child: Image(image: img3.image,
               fit: BoxFit.cover,
              height:MediaQuery.of(context).size.height
          )
         )
         )
         ,

          buildNextBtn()
       ],
      )
    );
  }

}