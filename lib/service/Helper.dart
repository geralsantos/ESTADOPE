import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:estado/config.dart';
import 'package:estado/module/entity/Donation.dart';
import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/module/sotorage/Storage.dart';
import 'package:estado/module/sotorage/Storage2.dart';
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
  Future getParentesco() async {
    try {
      var request = await http.get(ROOT + '/registros/parentesco/ver/');
      return json.decode(request.body);
    } catch (e) {
      print(e);
    }

    return null;
  }
   Future<bool> checkUser(String email,String contrasena) async {
    try {
      var request = await http.post(ROOT + '/login/checkUser/',body: {
      "usuario": email.trim(),"contrasena":contrasena.trim(),
    });
    print("request.body");print(request.body=="200");
      return request.body=="200";
    } catch (e) {
      print(e);
    }
    return false;
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
  Future<List> getZonasEntrega(String id) async {
    try {
      var request = await http.get(ROOT + '/registros/zonasentrega/' + id);
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

  Future<List> getTipoViviendas() async {
    try {
      var request = await http.get(ROOT + '/registros/tiposvivienda/ver/');
      return json.decode(request.body);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<List<dynamic>> getDonations() async {
    Storage2 s = new Storage2();
    await s.open();
    return await s.getAll("donacion", null);
  }

  Future getDataBeneficiario(String numero_documento) async {
    try {
      var request = await http
          .post(ROOT + '/registros/obtenerBeneficiario/', body: {
        "numero_documento": numero_documento.trim()
      });
      return json.decode(request.body);
    } catch (e) {
      print(e);
    }
    return null;
  }
Future getDataWsReniec(String numero_documento) async {
    try {
      var request = await http.post(ROOT + '/registros/consultabeneficiarioWs/',
      body: {
        "DNI": numero_documento.trim(),
        "KEY": KEY
      });
      return json.decode(request.body);
    } catch (e) {
      print(e);
    }

    return null;
  }
  Future<bool> upload() async {
    try {
      Storage2 s = new Storage2();
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
          "observaciones": Uri.decodeComponent(row['observaciones']),
          "numero_telefono": row['numero_telefono'],
          "tipo_vivienda_id": row['tipo_vivienda_id'],
          "zona_entrega_id": row['zona_entrega_id'],
        };
        print("args locale");
        print(args);
        List<Composition> compositions = new List();
        var compostionsRows = json.decode(row['composicion']);
        for (var c in compostionsRows) {
          compositions
              .add(new Composition(c['nombre'], c['cantidad'], c['id']));
        }
        dynamic uploaded = await save(
            args,
            row['documento_path'],
            row['beneficiario_path'],
            row['ubigeo_id'],
            row['usuario_id'],
            row['georeferencia'],
            compositions,
            row['tipo_documento_id'],
            row['zona_entrega_id'],
            
            row['fr_numero_documento'],
            row['fr_apellido_paterno'],
            row['fr_apellido_materno'],
            row['fr_nombres'],
            row['fr_parentesco_id'],
            );
        print("uploaded");
        print(uploaded);
        if (uploaded!=null){
          if(uploaded!=false){
            print("destroy");
            print(row['id']);
            await s.destroy("donacion", row['id']);
          }
        }
      }
      return true;
    } catch (err) {
      print(err);
    }
    return false;
  }

  Future<dynamic> localSave(args, String docPath, String bePath, int ubigeo,
      int user, String geoLocation, compositions, int tipodocumento,int zonaentrega_,String frnumero_documento, String frapellido_paterno, String frapellido_materno, String frnombres,int frparentesco) async {
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
          frnumero_documento,
          frapellido_paterno,
          frapellido_materno,
          frnombres,
          frparentesco,
          args['estado_entrega_id'],
          args['numero_documento']==null?"":args['numero_documento'],
          Uri.encodeComponent(args['primer_apellido']),
          Uri.encodeComponent(args['segundo_apellido']),
          Uri.encodeComponent(args['nombre']),
          Uri.encodeComponent(args['direccion']),
          Uri.encodeComponent(args['centro_poblado']),
          json.encode(j),
          Uri.encodeComponent(args['observaciones']),
          geoLocation,
          docPath,
          bePath,
          args['numero_telefono'],
          args['tipo_vivienda_id'],
          zonaentrega_
      );
      Storage2 s = new Storage2();
      await s.open();
      await s.insert("donacion", donation);
      return true;
    } catch (err) {
      print(err);
    }
    return false;
  }

  Future<dynamic> save(args, String docPath, String bePath, int ubigeo, int user,
      String geoLocation, compositions, var tipodocumento,String zonaentrega_,String frnumero_documento, String frapellido_paterno, String frapellido_materno, String frnombres,var frparentesco) async {
    FormBackup backup = new FormBackup();

    await backup.open();
    dynamic activeInternet =await backup.read("activeInternet", "true");

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (activeInternet == "true" ? (connectivityResult == ConnectivityResult.none) : true) {
      return await localSave(args, docPath, bePath, ubigeo, user, geoLocation,
          compositions, int.parse(tipodocumento),int.parse(zonaentrega_),frnumero_documento,frapellido_paterno,frapellido_materno,frnombres,int.parse(frparentesco));
    } else {
      try {
        var postUri = Uri.parse(ROOT + '/registros/guardarBeneficiario/');
        var request = new http.MultipartRequest("POST", postUri);
        request.fields['tipo_captura_id'] = args['tipo_captura_id'].toString();
        request.fields['tipo_documento_id'] = tipodocumento.toString();
        request.fields['fr_numero_documento'] = frnumero_documento.toString();
        request.fields['fr_apellido_paterno'] = frapellido_paterno.toString();
        request.fields['fr_apellido_materno'] = frapellido_materno.toString();
        request.fields['fr_nombres'] = frnombres.toString();
        print("frparentesco.toString()");
        print(frparentesco.toString());
        print(frparentesco.toString()=="0");
        request.fields['fr_parentesco_id'] = frparentesco.toString()=="0"||frparentesco.toString()==""?"":frparentesco.toString();
        request.fields['numero_documento'] = args['numero_documento']==null?"":args['numero_documento'];
        request.fields['primer_apellido'] = args['primer_apellido'];
        request.fields['segundo_apellido'] = args['segundo_apellido'];
        request.fields['nombre'] = args['nombre'];
        request.fields['direccion'] = args['direccion'];
        request.fields['centro_poblado'] = args['centro_poblado'];
        request.fields['observaciones'] = args['observaciones'];
        request.fields['estado_entrega_id'] =
            args['estado_entrega_id'].toString();
        request.fields['georeferencia'] =
            geoLocation == null ? '' : geoLocation;
        request.fields['usuario_id'] = user.toString();
        request.fields['ubigeo_id'] = ubigeo.toString();
        request.fields['numero_telefono'] = args['numero_telefono'].toString();
        request.fields['tipo_vivienda_id'] =  args['tipo_vivienda_id'].toString();
        request.fields['zona_entrega_id'] =  zonaentrega_.toString()=="0"||zonaentrega_.toString()=="" ?"":zonaentrega_.toString();
        request.fields['last_version'] =  APP_TITLE;
        print("before save");
        print(args);
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
        final respStr = await http.Response.fromStream(response);
        print("respStr");
        print(response.statusCode);

/*
response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        return Future.value(value);
      });
   */
        if (response.statusCode == 200) {
          final file = File(docPath);
          if (file.existsSync()) {
            await file.delete();
          }
          if (bePath != null) {
            final file = File(bePath);
            if (file.existsSync()) {
              await file.delete();
            }
          }
          return respStr.body;
        }
        return false;
      } catch (e) {
        print(e);
      }

      return false;
    }
  }
}
