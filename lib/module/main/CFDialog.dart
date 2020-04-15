import 'package:estado/service/Composition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class CFDialog extends StatefulWidget {
  @override
  CFDialogState createState() {
    return CFDialogState();
  }
}

class CFDialogState extends State<CFDialog> {
  final mockResults = <Composition>[
    Composition('John Doe', 'jdoe@flutter.io',
        'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'), 
  ];

  void show()  {
     showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(child: CFDialogContent());
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap:show,
      child: ChipsInput(
        initialValue: [],
        keyboardAppearance: Brightness.dark,
        textCapitalization: TextCapitalization.words,
        enabled: true,
        maxChips: 5,
        textStyle: TextStyle(height: 1.5, fontFamily: "Roboto", fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.chevron_right),
          labelText: "Composición familiar",
        ),
        findSuggestions: (String query) {
          if (query.length != 0) {
            var lowercaseQuery = query.toLowerCase();
            return mockResults.where((profile) {
              return profile.name.toLowerCase().contains(query.toLowerCase()) ||
                  profile.email.toLowerCase().contains(query.toLowerCase());
            }).toList(growable: false)
              ..sort((a, b) => a.name
                  .toLowerCase()
                  .indexOf(lowercaseQuery)
                  .compareTo(b.name.toLowerCase().indexOf(lowercaseQuery)));
          }
          return <Composition>[];
        },
        onChanged: (data) {
          print(data);
        },
        chipBuilder: (context, state, profile) {
          return InputChip(
            key: ObjectKey(profile),
            label: Text(profile.name),
            avatar: CircleAvatar(
              backgroundImage: NetworkImage(profile.imageUrl),
            ),
            onDeleted: () => state.deleteChip(profile),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
        suggestionBuilder: (context, state, profile) {
          return ListTile(
            key: ObjectKey(profile),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(profile.imageUrl),
            ),
            title: Text(profile.name),
            subtitle: Text(profile.email),
            onTap: () => state.selectSuggestion(profile),
          );
        },
      ),
    );
  }
}

class CFDialogContent extends StatefulWidget {
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
      child:Container(
        height: 330,
        padding: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text(
                      "Composición familiar",
                      style: TextStyle(fontSize: 17),
                    ),],),
                    SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                      child: Row(children: <Widget>[
                Column(
                  children: [
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
                      ]
                    )
                  ]
                )
              ]),
                    ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                     setState(() {
                       cf011="0";
                       cf1217="0";
                       cf1829="0";
                       cf3059="0";
                       cf60="0";
                     });
                    },
                    child: Text("Limpiar"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color:Colors.red,
                    textColor: Colors.white,
                    child: Text("Aceptar"),
                  )
                ],
              )
            ])
            )
            );
  }
}
