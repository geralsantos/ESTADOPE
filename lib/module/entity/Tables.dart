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