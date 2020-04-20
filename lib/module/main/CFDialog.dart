import 'dart:convert';

import 'package:estado/module/sotorage/FormBackup.dart';
import 'package:estado/service/Composition.dart';
import 'package:flutter/material.dart';

class CFDialog extends StatefulWidget {
  final Function callback;

  CFDialog(this.callback);
  @override
  CFDialogState createState() {
    return CFDialogState();
  }
}

class CFDialogState extends State<CFDialog> {
  var chipValues = <Composition>[];
  var chipsArgs;
  FormBackup backup=new FormBackup();
  @override
  void initState() { 
    super.initState();
  
    init();
  }
  
  void init() async {
    await backup.open();
    var args = await backup.read("compositions", null);
   if(args!=null){
     updateChips(json.decode(args));
   }

  }
  List<Widget> buildItems() {
    var items = <Widget>[];
    if (chipValues.length > 0) {
      for (var c in chipValues) {
        items.add(InputChip(
          elevation: 2,
          label: Text(
            c.nombre.toString() + ":" + c.cantidad.toString(),
            style: TextStyle(color: Colors.black),
          ),
        ));
      }
    } else {
      items.add(Text("Composición por edad"));
    }
    return items;
  }

  Widget buildChips() {
    return Container(
        margin: const EdgeInsets.all(2.0),
        width: MediaQuery.of(context).size.width - 100,
        padding: EdgeInsets.fromLTRB(chipValues.length == 0 ? 15 : 5, 5, 5, 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //         <--- border radius here
              ),
          border: Border.all(color: Colors.grey),
        ), //       <--- BoxDecoration here

        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: 48,
                    minWidth: MediaQuery.of(context).size.width + 50),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: chipValues.length == 0
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.spaceEvenly,
                  children: buildItems(),
                ))));
  }

  void updateChips(args) {
    var chips = <Composition>[];
    chips.add(new Composition("0-11", args['cf011'], 1));
    chips.add(new Composition("12-17", args['cf1217'], 2));
    chips.add(new Composition("18-29", args['cf1829'], 3));
    chips.add(new Composition("30-59", args['cf3059'], 4));
    chips.add(new Composition("60+", args['cf60'], 5));
    setState(() {
      chipsArgs = args;
      chipValues = chips;
    });
    widget.callback(chips,args);
  }

  void show() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(child: CFDialogContent(updateChips, chipsArgs));
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: show, child: buildChips());
  }
}

class CFDialogContent extends StatefulWidget {
  final Function callback;
  final args;
  CFDialogContent(this.callback, this.args);
  @override
  CFDialogContentState createState() {
    return CFDialogContentState();
  }
}

class CFDialogContentState extends State<CFDialogContent> {
  String cf011 = "0", cf1217 = "0", cf1829 = "0", cf3059 = "0", cf60 = "0";
  var options = [];

  @override
  void initState() {
    super.initState();
    if (widget.args != null) {
      cf011 = widget.args['cf011'];
      cf1217 = widget.args['cf1217'];
      cf1829 = widget.args['cf1829'];
      cf3059 = widget.args['cf3059'];
      cf60 = widget.args['cf60'];
    }
    List<String> opts = [];
    for (var i = 0; i <= 70; i++) {
      opts.add(i.toString());
    }
    options = opts.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            height: 330,
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Composición por edad",
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Row(children: <Widget>[
                      Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(width: 50),
                            Text(
                              '  0-11:',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(width: 50),
                            SizedBox(
                                width: 50,
                                child: DropdownButton<String>(
                                  value: cf011,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      cf011 = newValue;
                                    });
                                  },
                                  items: options,
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(width: 50),
                            Text(
                              '12-17:',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(width: 50),
                            SizedBox(
                                width: 50,
                                child: DropdownButton<String>(
                                  value: cf1217,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      cf1217 = newValue;
                                    });
                                  },
                                  items: options,
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(width: 50),
                            Text(
                              '18-29:',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(width: 50),
                            SizedBox(
                                width: 50,
                                child: DropdownButton<String>(
                                  value: cf1829,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      cf1829 = newValue;
                                    });
                                  },
                                  items: options,
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(width: 50),
                            Text(
                              '30-59:',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(width: 50),
                            SizedBox(
                                width: 50,
                                child: DropdownButton<String>(
                                  value: cf3059,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      cf3059 = newValue;
                                    });
                                  },
                                  items: options,
                                ))
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(width: 50),
                              Text(
                                '60+1:',
                                style: TextStyle(fontSize: 20),
                              ),
                              Container(width: 50),
                              SizedBox(
                                  width: 50,
                                  child: DropdownButton<String>(
                                    value: cf60,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 16,
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        cf60 = newValue;
                                      });
                                    },
                                    items: options,
                                  ))
                            ])
                      ])
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            cf011 = "0";
                            cf1217 = "0";
                            cf1829 = "0";
                            cf3059 = "0";
                            cf60 = "0";
                          });
                        },
                        child: Text("Limpiar"),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (widget.callback != null) {
                            widget.callback({
                              "cf011": cf011,
                              "cf1217": cf1217,
                              "cf1829": cf1829,
                              "cf3059": cf3059,
                              "cf60": cf60
                            });
                          }
                          Navigator.of(context).pop();
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text("Aceptar"),
                      )
                    ],
                  )
                ])));
  }
}
