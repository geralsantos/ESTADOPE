class Composition {
  /*final String nombre;
  final String cantidad;
  final int id;*/
  final String name;
  final String email;
  final String imageUrl;
 // const Composition(this.nombre, this.cantidad, this.id);
const Composition(this.name, this.email, this.imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Composition &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}