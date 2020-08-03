import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class Storage2 {
  Future<Database> database;
  Future open() async {
    database= openDatabase(
      join(await getDatabasesPath(), 'estadodb1.db'),
        version:2,
        onCreate: (db,sversion){
         db.execute('''create table  if not exists 
         tipodocumento( id integer not null primary key autoincrement, nombre varchar(200));''');
         db.execute('''create table  if not exists tipocaptura( 
           id integer not null primary key autoincrement,nombre varchar(200),codigo varchar(15));''');
         db.execute('''create table  if not exists estadoentrega(
           id integer not null primary key autoincrement,nombre varchar(200));''');
           db.execute('''create table  if not exists tipovivienda(
           id integer not null primary key autoincrement,nombre varchar(200));''');
         db.execute('''create table  if not exists zonaentrega(
           id integer not null primary key autoincrement,nombre varchar(200));''');

        return db.execute('''create table  if not exists donacion(
id integer not null primary key autoincrement,
usuario_id integer,
ubigeo_id integer,
tipo_captura_id integer,
tipo_documento_id integer,
estado_entrega_id integer,
tipo_vivienda_id integer,
zona_entrega_id integer null,
numero_documento varchar(45) null,
primer_apellido varchar(150),
segundo_apellido varchar(150),
nombre varchar(150),
direccion varchar(150),
centro_poblado varchar(150),
composicion text,
observaciones varchar(300),
georeferencia varchar(100),
documento_path text,
numero_telefono varchar(10),
fr_numero_documento varchar(50) null,
fr_apellido_paterno varchar(50) null,
fr_apellido_materno varchar(50) null,
fr_nombres varchar(50) null,
fr_parentesco_id integer null,
beneficiario_path text);''');         
      }
    );
  }

  Future<void> insert(String table,var obj) async{
    await open();
    final Database db= await database;
    await db.insert(table, obj.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    //db.close();
  }
  Future<List<dynamic>> getAll(String table,Function callback) async {
    await open();
    final Database db = await database;
    final maps = await db.query(table);
    /*return List.generate(maps.length, (i) {
      return callback(maps,i);
    });*/
    //db.close();

    return maps;
  }

  Future<void> dropDatabase2() async {
    await deleteDatabase(join(await getDatabasesPath(), 'estadodb5.db'));
  }
    Future<void> destroy(String table,int id) async {
    final db = await database;
    await db.delete(
      table,
       where: "id = ?",
      whereArgs: [id],
    );
  }
}
