import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class Storage {
  Future<Database> database;
  Future open() async {
    database= openDatabase(
      join(await getDatabasesPath(), 'estadodb.db'),
      onCreate: (db,vsersion){
         db.execute('''create table  if not exists 
         tipodocumento( id integer not null primary key autoincrement, nombre varchar(200));''');
         db.execute('''create table  if not exists tipocaptura( 
           id integer not null primary key autoincrement,nombre varchar(200),codigo varchar(15));''');
         db.execute('''create table  if not exists estadoentrega(
           id integer not null primary key autoincrement,nombre varchar(200));''');
        return db.execute('''create table  if not exists donacion(
id integer not null primary key autoincrement,
usuario_id integer,
ubigeo_id integer,
tipo_captura_id integer,
tipo_documento_id integer,
estado_entrega_id integer,
numero_documento varchar(45),
primer_apellido varchar(150),
segundo_apellido varchar(150),
nombre varchar(150),
direccion varchar(150),
centro_poblado varchar(150),
composicion text,
observaciones varchar(300),
georeferencia varchar(100),
documento_path text,
beneficiario_path text
);''');         
      },
     version:1
    );
  }
  Future<void> insert(String table,var obj) async{
   final Database db= await database;
   await db.insert(table, obj.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
   
  }
  Future<List<dynamic>> getAll(String table,Function callback) async {
    final Database db = await database;
    final maps = await db.query(table);
    /*return List.generate(maps.length, (i) {
      return callback(maps,i);
    });*/
    return maps;
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
