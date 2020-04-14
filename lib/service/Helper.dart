import 'package:estado/config.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
class Helper{
  Future getDocuments() async{
    try{
      var request= await http.get(ROOT+'/registros/tipodocumento/ver/');
      return json.decode(request.body); 
    }catch(e){
      print(e);
    }

    return null;
  }
  Future<List>  getCaptureTypes(String id) async{
    try{
      var request= await http.get(ROOT+'/registros/tipocaptura/ver/'+id);
      return json.decode(request.body); 
    }catch(e){
      print(e);
    }

    return null;
  }
  Future<List> getStates() async{
    try{
      var request=await http.get(ROOT+'/registros/estadoentrega/ver/');
    return json.decode(request.body); 
    }catch(e){
      print(e.toString());
    }
    return null;
  }
}