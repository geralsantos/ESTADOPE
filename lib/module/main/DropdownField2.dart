import 'package:flutter/material.dart';

class DropDownField extends FormField<dynamic> {


  DropDownField(
      {FormFieldSetter<dynamic> onSaved,
      FormFieldValidator<dynamic> validator,
      bool autovalidate = false,
      this.titleText = 'Título',
      this.hintText = 'Seleccione una opción',
      this.required = false,
      this.errorText = 'Por favor seleccione una opción',
      this.value,
      this.dataSource,
      this.textField,
      this.valueField,
      this.onChanged,
      this.filled = true,
      this.contentPadding = const EdgeInsets.fromLTRB(12, 16, 0, 0)})
      : super(
          onSaved: onSaved,
          validator: validator,
          autovalidate: autovalidate,
          initialValue: value == '' ? null : value,
          builder: (FormFieldState<dynamic> state) {
            return Container(
              padding: const EdgeInsets.all( 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InputDecorator(
                    decoration: InputDecoration(
                     border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),

                      contentPadding: contentPadding,
                      labelText: titleText,
                     
                     labelStyle: TextStyle(fontSize: 15)
                      
                      //filled: filled,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                             isDense: true,
                        hint: Text(
                          hintText,
                          style: TextStyle(color: Colors.grey),
                        ),
                        value: value == '' ? null : value,
                        onChanged: (dynamic newValue) {
                          state.didChange(newValue);
                          onChanged(newValue);
                        },
                        items: dataSource.map((item) {
                          return DropdownMenuItem<dynamic>(
                            value: item[valueField],
                            child: Text(item[textField]),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: state.hasError ? 5.0 : 0.0),
                  Text(
                    state.hasError ? state.errorText : '',
                    style: TextStyle(color: Colors.redAccent.shade700, fontSize: state.hasError ? 12.0 : 0.0),
                  ),
                ],
              ),
            );
          },
        );
          final String titleText;
  final String hintText;
  final bool required;
  final String errorText;
  final dynamic value;
  final List dataSource;
  final String textField;
  final String valueField;
  final Function onChanged;
  final bool filled;
  final EdgeInsets contentPadding;
}