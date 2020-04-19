import 'package:shared_preferences/shared_preferences.dart';
class User{
   String name,surnames,user;
   int id;
   int ubigeoId;
   bool savedInLocal;
  Future read() async{
    final prefs = await SharedPreferences.getInstance();
    name=prefs.getString("nombres") ?? "None";
    surnames=prefs.getString("apellidos")??"None";
    user=prefs.getString("usuario")??"None";
    id=prefs.getInt("id") ?? -1;
    ubigeoId=prefs.getInt("ubigeo_id") ?? -1;
     savedInLocal=prefs.getBool("saved_in_local")??false;
    //prefs.setString("cool", "my cool value");
  }
  void setUser(String u){
   user=u;
  }
void setId(int id){
  this.id=id;
}
void setName(String name){
  this.name=name;
}
void setSurnames(String surnames){
  this.surnames=surnames;
}
void setUbigeoId(int ubigeoId){
  this.ubigeoId=ubigeoId;
}
 bool isAuth(){
   return id>0;
 }
  int getId(){
    return id;
  }
 
  String getName(){
    return name+' '+(surnames==null?'':surnames);
  }
   String getUser(){
    return user;
   }
   int getubigeoId(){
     return ubigeoId;
   }
}