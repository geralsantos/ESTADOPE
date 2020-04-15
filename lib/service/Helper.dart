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
  Future<bool> save(args,String docPath,String bePath,int ubigeo,int user,String geoLocation) async{
    print(args);
    var postUri = Uri.parse(ROOT+'/registros/guardarBeneficiario/');
    var request = new http.MultipartRequest("POST", postUri);
    request.fields['tipo_captura_id'] = args['tipo_captura_id'];
    request.fields['tipo_documento_id'] = args['tipo_documento_id'];
    request.fields['numero_documento'] = args['numero_documento'];
    request.fields['primer_apellido'] = args['primer_apellido'];
    request.fields['segundo_apellido'] = args['segundo_apellido'];
    request.fields['nombre'] = args['nombre'];
    request.fields['direccion'] = args['direccion'];
    request.fields['centro_poblado'] = args['centro_poblado'];
    request.fields['observaciones'] = args['observaciones'];
    request.fields['estado_entrega_id'] = args['estado_entrega_id'];
    request.fields['georeferencia'] = geoLocation;
    request.fields['usuario_id'] = user.toString();
    request.fields['ubigeo_id'] = ubigeo.toString();
    print(geoLocation);
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

   /*
    request.send().then((response) {
      if (response.statusCode == 200){
        print("Uploaded!");
      }
    });*/
    return false;
  }
}