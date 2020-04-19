class Composition {
  final String nombre;
  final String cantidad;
  final int id;

 // const Composition(this.nombre, this.cantidad, this.id);
const Composition(this.nombre, this.cantidad, this.id);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Composition &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre;

  @override
  int get hashCode => nombre.hashCode;

  @override
  String toString() {
    return nombre;
  }
  Map<String,dynamic> toMap(){
    return {
     'nombre':nombre,
     'cantidad':cantidad,
     'id':id
    };
  }
}