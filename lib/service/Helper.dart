import 'package:estado/config.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
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
  Future<bool> save(args,String docPath,String bePath,int ubigeo,int user,String geoLocation,compositions) async{
    print(args);
    var postUri = Uri.parse(ROOT+'/registros/guardarBeneficiario/');
    var request = new http.MultipartRequest("POST", postUri);
    request.fields['tipo_captura_id'] = args['tipo_captura_id'].toString();
    request.fields['tipo_documento_id'] = args['tipo_documento_id'].toString();
    request.fields['numero_documento'] = args['numero_documento'];
    request.fields['primer_apellido'] = args['primer_apellido'];
    request.fields['segundo_apellido'] = args['segundo_apellido'];
    request.fields['nombre'] = args['nombre'];
    request.fields['direccion'] = args['direccion'];
    request.fields['centro_poblado'] = args['centro_poblado'];
    request.fields['observaciones'] = args['observaciones'];
    request.fields['estado_entrega_id'] = args['estado_entrega_id'].toString();
    request.fields['georeferencia'] = geoLocation;
    request.fields['usuario_id'] = user.toString();
    request.fields['ubigeo_id'] = ubigeo.toString();
  
 var aux=[];
 for(var c in compositions){
   var prop={"nombre":c.nombre,"cantidad":c.cantidad,"id":c.id};
   aux.add(prop);
 }
 var compositionList=json.encode(aux);
 print(compositionList);
 request.fields['composicion']=compositionList;
     var dformatter = new DateFormat('yyyy-MM-dd');
     var tformatter = new DateFormat('Hms');
   if(docPath!=null){
     String key="DNI_"+dformatter.format(DateTime.now())+"_"+tformatter.format(DateTime.now());
    request.files.add(
      new http.MultipartFile.fromBytes(key, await File.fromUri(Uri.parse(docPath)).readAsBytes(), 
      contentType: new MediaType('image', 'jpg')));
   }
       if(bePath!=null){
          String key="BENEFICIARIO_"+dformatter.format(DateTime.now())+"_"+tformatter.format(DateTime.now());
    request.files.add(
      new http.MultipartFile.fromBytes(key, await File.fromUri(Uri.parse(bePath)).readAsBytes(), 
      contentType: new MediaType('image', 'jpg')));
   }

    var res=await request.send().then((response){
    
      print(response.statusCode);
      if (response.statusCode == 200){
        print("Uploaded!");
       
      }
    });
      /*  res.stream.transform(utf8.decoder).listen((value) {
        print(value);
        return Future.value(value);
      });*/
    return false;
  }
}