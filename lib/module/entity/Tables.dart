class TipoDocumento{
  final int id;
  final String nombre;
  TipoDocumento(this.id,this.nombre);
    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}

class TipoCaptura{
  final int id;
  final String nombre,codigo;
  TipoCaptura(this.id,this.nombre,this.codigo);
    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo':codigo
    };
  }
}

class EstadoEntrega{
  final int id;
  final String nombre;
  EstadoEntrega(this.id,this.nombre);
    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
   @override
  String toString() {
    return 'EstadoEntrega{id: $id, nombre: $nombre}';
  }
}
class TipoVivienda{
  final int id;
  final String nombre;
  TipoVivienda(this.id,this.nombre);
    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
class ZonaEntrega{
  final int id;
  final String nombre;
  ZonaEntrega(this.id,this.nombre);
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
class Parentesco{
  final int id;
  final String nombre;
  Parentesco(this.id,this.nombre);
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
class FamiliaReceptora{
  final int id;
  final String nombre;
  final String apellido_paterno;
  final String apellido_materno;
  final String dni;
  FamiliaReceptora
(this.id,this.nombre,this.apellido_paterno,this.apellido_materno,this.dni);
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido_paterno': apellido_paterno,
      'apellido_materno': apellido_materno,
      'dni': dni,
    };
  }
}