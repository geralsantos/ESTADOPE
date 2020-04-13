import 'package:estado/config.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
class Helper{
  Future<List>  getDocuments() async{
    try{
      var request= await http.get(ROOT+'/registros/tipodocumento/ver/');
      return json.decode(request.body); 
    }catch(e){
      print(e);
    }

    return null;
  }
  Future<List>  getCaptureTypes() async{
    try{
      var request= await http.get(ROOT+'/registros/tipocaptura/ver/');
      return json.decode(request.body); 
    }catch(e){
      print(e);
    }

    return null;
  }
}