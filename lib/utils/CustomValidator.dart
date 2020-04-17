class CustomValidator {
  static Function req(String msj) {
    return (var value) {
      if (value == null ||
          value == false ||
          ((value is Iterable || value is String || value is Map) &&
              value.length == 0)) {
        return msj;
      }
      return null;
    };
  }

  static Function equal(String msj, int n) {
    return (var value) {
      if (value == null ||
          value == false ||
          ((value is Iterable || value is String || value is Map) &&
              value.length != n)) {
        return msj;
      }
      return null;
    };
  }
}
