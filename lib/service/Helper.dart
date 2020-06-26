import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:estado/config.dart';
import 'package:estado/module/entity/Donation.dart';
import 'package:estado/module/sotorage/Storage.dart';
import 'package:estado/service/Composition.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Helper {
  Future getDocuments() async {
    try {
      var request = await http.get(ROOT + '/registros/tipodocumento/ver/');
      return json.decode(request.body);
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<List> getCaptureTypes(String id) async {
    try {
      var request = await http.get(ROOT + '/registros/tipocaptura/ver/' + id);
      return json.decode(request.body);
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<List> getStates() async {
    try {
      var request = await http.get(ROOT + '/registros/estadoentrega/ver/');
      return json.decode(request.body);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<List<dynamic>> getDonations() async {
    Storage s = new Storage();
    await s.open();
    return await s.getAll("donacion", null);
  }

  Future<bool> upload() async {
   try{
      Storage s = new Storage();
    await s.open();
    var rows = await s.getAll("donacion", null);
    for (var row in rows) {
      var args = {
        "tipo_captura_id": row['tipo_captura_id'],
        "tipo_documento_id": row['tipo_documento_id'],
        "estado_entrega_id": row['estado_entrega_id'],
        "numero_documento": row['numero_documento'],
        "primer_apellido": Uri.decodeComponent(row['primer_apellido']),
        "segundo_apellido": Uri.decodeComponent(row['segundo_apellido']),
        "nombre": Uri.decodeComponent(row['nombre']),
        "direccion": Uri.decodeComponent(row['direccion']),
        "centro_poblado": Uri.decodeComponent(row['centro_poblado']),
        "observaciones": Uri.decodeComponent(row['observaciones'])
      };
      List<Composition> compositions=new List();
      var compostionsRows=json.decode(row['composicion']);
      for(var c in compostionsRows){
        compositions.add(new Composition(c['nombre'], c['cantidad'], c['id']));
      }
     bool uploaded= await save(args, 
      row['documento_path'], 
      row['beneficiario_path'],
       row['ubigeo_id'], 
       row['usuario_id'],
        row['georeferencia'],compositions,row['tipo_documento_id']);
        if(uploaded){
          await s.destroy("donacion",row['id']);
        }
    }
    return true;
   }catch(err){
     print(err);
   }
   return false;
  }

  Future<bool> localSave(args, String docPath, String bePath, int ubigeo,
      int user, String geoLocation, compositions, int tipodocumento) async {
    try {
      List j = new List();
      for (var c in compositions) {
        j.add(c.toMap());
      }

      Donation donation = new Donation(
          user,
          ubigeo,
          args['tipo_captura_id'],
          tipodocumento,
          args['estado_entrega_id'],
          args['numero_documento'],
          Uri.encodeComponent(args['primer_apellido']),
          Uri.encodeComponent(args['segundo_apellido']),
          Uri.encodeComponent(args['nombre']),
          Uri.encodeComponent(args['direccion']),
          Uri.encodeComponent(args['centro_poblado']),
          json.encode(j),
          Uri.encodeComponent(args['observaciones']),
          geoLocation,
          docPath,
          bePath);
      Storage s = new Storage();
      await s.open();
      await s.insert("donacion", donation);
      return true;
    } catch (err) {
      print(err);
    }
    return false;
  }

  Future<bool> save(args, String docPath, String bePath, int ubigeo, int user,
      String geoLocation, compositions, var tipodocumento) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return await localSave(
          args, docPath, bePath, ubigeo, user, geoLocation, compositions,int.parse(tipodocumento));
    } else {
      try {
        var postUri = Uri.parse(ROOT + '/registros/guardarBeneficiario/');
        var request = new http.MultipartRequest("POST", postUri);
        request.fields['tipo_captura_id'] = args['tipo_captura_id'].toString();
        request.fields['tipo_documento_id'] =
            tipodocumento.toString();
        request.fields['numero_documento'] = args['numero_documento'];
        request.fields['primer_apellido'] = args['primer_apellido'];
        request.fields['segundo_apellido'] = args['segundo_apellido'];
        request.fields['nombre'] = args['nombre'];
        request.fields['direccion'] = args['direccion'];
        request.fields['centro_poblado'] = args['centro_poblado'];
        request.fields['observaciones'] = args['observaciones'];
        request.fields['estado_entrega_id'] =
            args['estado_entrega_id'].toString();
        request.fields['georeferencia'] = geoLocation==null?'':geoLocation;
        request.fields['usuario_id'] = user.toString();
        request.fields['ubigeo_id'] = ubigeo.toString();
        if (compositions != null && compositions.length > 0) {
          var i = 0;
          for (var c in compositions) {
            var arg = {"id": c.id, "nombre": c.nombre, "cantidad": c.cantidad};
            request.fields['composicion[' + i.toString() + ']'] =
                json.encode(arg);
            i++;
          }
        }
        if (docPath != null) {
          request.files
              .add(await http.MultipartFile.fromPath("adjuntos[0]", docPath));
        }
        if (bePath != null) {
          request.files
              .add(await http.MultipartFile.fromPath("adjuntos[1]", bePath));
        }
        http.StreamedResponse response = await request.send();

/*
response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        return Future.value(value);
      });
   */
        if(response.statusCode==200){
final file = File(docPath);
if( file.existsSync()){
    await file.delete();
}
if(bePath!=null){
  final file = File(bePath);
if( file.existsSync()){
    await file.delete();
}
}
          return true;
        }
        return false;
      } catch (e) {
        print(e);
      }

      return false;
    }
  }
}
