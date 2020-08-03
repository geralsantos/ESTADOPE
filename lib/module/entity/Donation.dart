class Donation{
final int usuarioId;
final int ubigeoId;
final int tipoCapturaId;
final int tipoDocumentoId;
final String frNumeroDocumento;
final String frApellidoPaterno;
final String frApellidoMaterno;
final String frNombres;
final int frParentescoId;
final int estadoEntregaId;
final String numeroDocumento;
final String primerApellido;
final String segundoApellido;
final String nombre;
final String direccion;
final String centroPoblado;
final String composicion;
final String observaciones;
final String georeferencia;
final String documentoPath;
final String beneficiarioPath;
final String numeroTelefono;
final int tipoViviendaId;
final int zonaEntregaId;

 Donation(
   this.usuarioId,
   this.ubigeoId,
   this.tipoCapturaId,
   this.tipoDocumentoId,
   this.frNumeroDocumento,
   this.frApellidoPaterno,
   this.frApellidoMaterno,
   this.frNombres,
   this.frParentescoId,
   this.estadoEntregaId,
   this.numeroDocumento,
   this.primerApellido,
   this.segundoApellido,
   this.nombre,
   this.direccion,
   this.centroPoblado,
   this.composicion,
   this.observaciones,
   this.georeferencia,
   this.documentoPath,
   this.beneficiarioPath,this.numeroTelefono,this.tipoViviendaId,this.zonaEntregaId
   );
Map<String,dynamic> toMap(){
  return {
"usuario_id":usuarioId,
"ubigeo_id":ubigeoId,
"tipo_captura_id":tipoCapturaId,
"tipo_documento_id":tipoDocumentoId,
"fr_numero_documento":frNumeroDocumento,
"fr_apellido_paterno":frApellidoPaterno,
"fr_apellido_materno":frApellidoMaterno,
"fr_nombres":frNombres,
"fr_parentesco_id":frParentescoId,
"estado_entrega_id":estadoEntregaId,
"numero_documento":numeroDocumento,
"primer_apellido":primerApellido,
"segundo_apellido":segundoApellido,
"nombre":nombre,
"direccion":direccion,
"centro_poblado":centroPoblado,
"composicion":composicion,
"observaciones":observaciones,
"georeferencia":georeferencia,
"documento_path":documentoPath,
"beneficiario_path":beneficiarioPath,
"numero_telefono":numeroTelefono,
    "tipo_vivienda_id":tipoViviendaId,
    "zona_entrega_id":zonaEntregaId,

  };
}
}