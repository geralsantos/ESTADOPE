create table  if not exists tipodocumento(
id integer not null primary key autoincrement,
nombre varchar(200)
);
create table  if not exists tipocaptura(
id integer not null primary key autoincrement,
nombre varchar(200),
codigo varchar(15)
);
create table  if not exists estadoentrega(
id integer not null primary key autoincrement,
nombre varchar(200)
);
create table  if not exists tipovivienda(
id integer not null primary key autoincrement,
nombre varchar(200),
);
create table  if not exists donacion(
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
);

