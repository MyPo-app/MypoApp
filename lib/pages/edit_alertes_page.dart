import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbols.dart';
import 'package:mypo/model/colors.dart';
import 'package:mypo/model/alert.dart';
import 'package:mypo/widget/appbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mypo/model/alertkey.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'sms_auto_page.dart';

// ignore: must_be_immutable
class AlertScreen extends StatefulWidget {
  Alert alerte;
  AlertScreen({required this.alerte});

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  late var alertName = TextEditingController();
  late var alertContent = TextEditingController();
  bool hasChanged = false;
  bool titlechanged = false;
  bool contentchanged = false;
  int _value = 1;
  bool _value2 = true;
  final keyName = TextEditingController();
  List<bool> boolWeek = <bool>[];
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.:#_-éàô]+$');

  @override
  void initState() {
    super.initState();
    alertName = TextEditingController(text: widget.alerte.title);
    alertContent = TextEditingController(text: widget.alerte.content);
    alertName.addListener(() {
      changed;
    });
    alertContent.addListener(() {
      changed;
    });
    boolWeek = List<bool>.from(widget.alerte.days);
  }

  void changed() {
    this.hasChanged = true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    alertName.dispose();
    alertContent.dispose();
    keyName.dispose();
    super.dispose();
  }

  String getContient(AlertKey a) {
    List<String> contient = [
      "",
      "Contient",
      "Ne contient pas",
      "est au debut",
      "est à la fin",
    ];
    return contient[a.contient];
  }

  Color getColorDropDown(AlertKey a) {
    if (a.allow) {
      return d_green;
    } else {
      return Colors.grey.shade300;
    }
  }

  void showSnackBar(BuildContext context, String s) {
    final snackBar = SnackBar(
      content: Text(s, style: TextStyle(fontSize: 20)),
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  bool verifieCle(String nom) {
    if (nom.length > 10) {
      showSnackBar(context, '10 characters maximum.');
      return false;
    }
    for (int i = 0; i < widget.alerte.keys.length; i++) {
      if (widget.alerte.keys[i].name == nom) {
        showSnackBar(context, 'Clé déjà existante.');
        return false;
      }
    }
    if (!alphanumeric.hasMatch(nom)) {
      showSnackBar(context, 'Characters invalides.');
      return false;
    }
    return true;
  }

  verifieCibles(List<dynamic> cibles) {
    for (int i = 0; i < cibles.length; i++) {
      if (cibles[0] == true && cibles[i] == false) {
        cibles[0] = false;
      }
    }
    if (cibles[1] == true &&
        cibles[2] == true &&
        cibles[3] == true &&
        cibles[4] == true &&
        cibles[5] == true) {
      cibles[0] = true;
    }
  }

  bool isCiblesSet(List<dynamic> cibles) {
    int cpt = 0;
    for (int i = 0; i < cibles.length; i++) {
      if (cibles[i] == false) {
        cpt++;
      }
    }
    if (cpt == 6) {
      return false;
    }
    return true;
  }

  bool isWeekSet(List<dynamic> week) {
    return !(week[0] == false &&
        week[1] == false &&
        week[2] == false &&
        week[3] == false &&
        week[4] == false &&
        week[5] == false &&
        week[6] == false);
  }

  Widget alertKeys(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: DropdownButton(
                  underline: SizedBox(),
                  value: _value,
                  items: [
                    DropdownMenuItem(
                      child: Text(
                        "Contient",
                      ),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text("Ne Contient pas"),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text("Est au debut"),
                      value: 3,
                    ),
                    DropdownMenuItem(
                      child: Text("Est à la fin"),
                      value: 4,
                    )
                  ],
                  onChanged: (int? value) {
                    setState(() {
                      _value = value!;
                    });
                  },
                  hint: Text("Select item")),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: DropdownButton(
                  underline: SizedBox(),
                  value: _value2,
                  items: [
                    DropdownMenuItem(
                      child: Text("Accepte"),
                      value: true,
                    ),
                    DropdownMenuItem(
                      child: Text("N'accepte pas"),
                      value: false,
                    )
                  ],
                  onChanged: (bool? value) {
                    setState(() {
                      _value2 = value!;
                    });
                  },
                  hint: Text("Select item")),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: TextField(
              onChanged: (String value) => {setState(() {})},
              maxLines: 1,
              onSubmitted: (String? txt) => {setState(() {})},
              controller: keyName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: Icon(
                      Icons.add_box_rounded,
                      size: 30,
                      color: d_green,
                    ),
                    onPressed: () {
                      if (keyName.text != '' && verifieCle(keyName.text)) {
                        setState(() {
                          widget.alerte.keys.add(new AlertKey(
                              name: keyName.text,
                              contient: _value,
                              allow: _value2));
                          keyName.text = "";
                          hasChanged = true;
                        });
                      }
                    }),
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent)),
                contentPadding: EdgeInsets.all(8),
                hintText: "Ajoutez une clé à l'alerte ",
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        //showing added keys
        widget.alerte.keys.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: widget.alerte.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 55,
                            child: InkWell(
                                onTap: () => {},
                                child: Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    decoration: BoxDecoration(
                                      color: getColorDropDown(
                                          widget.alerte.keys[index]),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: Text(
                                              widget.alerte.keys[index].name,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(getContient(
                                              widget.alerte.keys[index])),
                                          IconButton(
                                              alignment: Alignment.topLeft,
                                              onPressed: () => {
                                                    setState(() {
                                                      widget.alerte.keys.remove(
                                                          widget.alerte
                                                              .keys[index]);
                                                      hasChanged = true;
                                                    })
                                                  },
                                              icon: const Icon(Icons.delete))
                                        ]))))
                      ]);
                })
            : Text("Pas encore de clés pour cette alerte"),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateSymbols fr = dateTimeSymbolMap()['fr'];
    // print(widget.alerte.days);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: TopBarRedirection(
          title: 'Alerte : ${widget.alerte.title}', page: () => SmsAuto()),
      body: Scrollbar(
        thickness: 10,
        interactive: true,
        showTrackOnHover: true,
        child: Container(
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: ListView(
              children: <Widget>[
                buildTextField('Nom', '${widget.alerte.title}', alertName, 1),
                buildTextField(
                    'Message', '${widget.alerte.content}', alertContent, 1),
                Container(
                  margin: EdgeInsets.fromLTRB(12, 5, 5, 5),
                  child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Text(
                            "Cibles",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          )
                        ],
                      )),
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                    ),
                    margin: EdgeInsets.all(0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(children: [
                            Container(
                              child: Padding(
                                padding: EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          "Tous",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        activeColor: d_green,
                                        value: widget.alerte.cibles[0],
                                        onChanged: (bool? value) => {
                                              setState(() {
                                                hasChanged = true;
                                                for (int i = 0;
                                                    i <
                                                        widget.alerte.cibles
                                                            .length;
                                                    i++) {
                                                  widget.alerte.cibles[i] =
                                                      value!;
                                                }
                                              })
                                            }),
                                    CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          "Numéros non enregistrés",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        activeColor: d_green,
                                        value: widget.alerte.cibles[1],
                                        onChanged: (bool? value) => {
                                              setState(() {
                                                hasChanged = true;
                                                widget.alerte.cibles[1] =
                                                    value!;
                                                verifieCibles(
                                                    widget.alerte.cibles);
                                              })
                                            }),
                                    CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          "SMS reçu",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        activeColor: d_green,
                                        value: widget.alerte.cibles[2],
                                        onChanged: (bool? value) => {
                                              setState(() {
                                                hasChanged = true;
                                                widget.alerte.cibles[2] =
                                                    value!;
                                                verifieCibles(
                                                    widget.alerte.cibles);
                                              })
                                            }),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(children: [
                            Container(
                              child: Padding(
                                padding: EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          "Contacts uniquement",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        activeColor: d_green,
                                        value: widget.alerte.cibles[3],
                                        onChanged: (bool? value) => {
                                              setState(() {
                                                hasChanged = true;
                                                widget.alerte.cibles[3] =
                                                    value!;
                                                verifieCibles(
                                                    widget.alerte.cibles);
                                              })
                                            }),
                                    CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          "Groupe de contact",
                                          style: TextStyle(
                                              fontSize: 15, color: Colors.red),
                                        ),
                                        activeColor: d_green,
                                        value: widget.alerte.cibles[4],
                                        onChanged: (bool? value) => {
                                              setState(() {
                                                hasChanged = true;
                                                widget.alerte.cibles[4] =
                                                    value!;
                                                verifieCibles(
                                                    widget.alerte.cibles);
                                              })
                                            }),
                                    CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Text(
                                          "Appel manqué",
                                          style: TextStyle(
                                              fontSize: 15, color: Colors.red),
                                        ),
                                        activeColor: d_green,
                                        value: widget.alerte.cibles[5],
                                        onChanged: (bool? value) => {
                                              setState(() {
                                                hasChanged = true;
                                                widget.alerte.cibles[5] =
                                                    value!;
                                                verifieCibles(
                                                    widget.alerte.cibles);
                                              })
                                            }),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(12, 5, 5, 5),
                  child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Text(
                            "Jours",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          )
                        ],
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      WeekdaySelector(
                        weekdays: fr.STANDALONEWEEKDAYS,
                        // shortWeekdays: fr.STANDALONENARROWWEEKDAYS,
                        shortWeekdays: fr.STANDALONESHORTWEEKDAYS,
                        firstDayOfWeek: fr.FIRSTDAYOFWEEK + 1,
                        selectedFillColor: d_green,
                        fillColor: Colors.white,
                        onChanged: (v) {
                          setState(() {
                            widget.alerte.days[v % 7] =
                                !widget.alerte.days[v % 7];
                            hasChanged = true;
                          });
                        },
                        values: List<bool>.from(widget.alerte.days),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(12, 5, 5, 5),
                  child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Text(
                            "Contenu du message entrant",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          )
                        ],
                      )),
                ),
                alertKeys(context),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.79,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.timer_rounded),
                              Container(
                                  child: Text(
                                    "Notification après réponse",
                                  ),
                                  margin: EdgeInsets.all(5)),
                            ],
                          )),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Switch(
                                activeColor: d_green,
                                value: widget.alerte.notification,
                                onChanged: (bool val) => {
                                      setState(() {
                                        hasChanged = true;
                                        widget.alerte.notification = val;
                                      })
                                    }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.79,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.rule_outlined),
                              Container(
                                  child: Text("Règle de réponse"),
                                  margin: EdgeInsets.all(5)),
                            ],
                          )),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Switch(
                                activeColor: d_green,
                                value: false,
                                onChanged: (bool val) => {
                                      setState(() {
                                        // confirm = val;
                                      })
                                    }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.all(12),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  buildPopupDialogCancel())
                        },
                        child: Text(
                          "Annuler",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(12),
                      child: ElevatedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: d_green,
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          if (alertName.text == '') {
                            showSnackBar(
                                context, "Veuillez rentrer un nom à l'alerte.");
                          } else if (alertContent.text == '') {
                            showSnackBar(
                                context, "Veuillez écrire un message.");
                          } else if (!isCiblesSet(widget.alerte.cibles)) {
                            showSnackBar(
                                context, "Veuillez choisir une cible.");
                          } else if (!isWeekSet(widget.alerte.days)) {
                            showSnackBar(
                                context, "Veuillez choisir le(s) jour(s).");
                          } else if (!alphanumeric.hasMatch(alertName.text)) {
                            showSnackBar(context,
                                "Characters invalides pour le nom de l'alerte.");
                          } else if (widget.alerte.keys.isEmpty) {
                            showSnackBar(
                                context, 'Veuillez rentrer un mot-clé.');
                          } else if (alertName.text != '' &&
                              alertContent.text != '' &&
                              alphanumeric.hasMatch(alertName.text) &&
                              isCiblesSet(widget.alerte.cibles) &&
                              isWeekSet(widget.alerte.days)) {
                            save();
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new SmsAuto()));
                          } else {
                            showSnackBar(
                                context, 'Veuillez completer tous les champs.');
                          }
                        },
                        child: Text(
                          "Sauvegarder",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildPopupDialogCancel() {
    return new AlertDialog(
      title: Text("Voulez vous annuler ?"),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new SmsAuto()),
            );
          },
          child: const Text('Oui', style: TextStyle(color: Colors.black)),
        ),
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Non', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
  /*
  function that crates a text field

  */

  Container buildTextField(String labelText, String placeholder,
      TextEditingController controller, int nbLines) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: TextField(
          autofocus: false,
          controller: controller,
          onChanged: (String value) => {
            setState(() {
              this.contentchanged = true;
              this.titlechanged = true;
              this.hasChanged = true;
            })
          },
          maxLines: nbLines,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.transparent)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.transparent)),
            contentPadding: EdgeInsets.all(8),
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /*
    -Function that saves the modifications of alerts in shared preferences
  */
  void save() async {
    if (hasChanged) {
      final pref = await SharedPreferences.getInstance();
      final keys = pref.getKeys();
      Iterator<String> it = keys.iterator;

      //TODO: Not delete but just replace the data using the same index

      while (it.moveNext()) {
        if (it.current == widget.alerte.title) {
          pref.remove(it.current);
        }
      }

      String title = widget.alerte.title;
      if (titlechanged) {
        title = alertName.text;
      }
      String content = widget.alerte.content;
      if (contentchanged) {
        content = alertContent.text;
      }
      final days = widget.alerte.days;
      final cible = widget.alerte.cibles;
      final b = widget.alerte.active;
      String not = widget.alerte.notification.toString();
      List<AlertKey> a = widget.alerte.keys;
      List<String> aStr = <String>[];
      for (int i = 0; i < a.length; i++) {
        aStr.add(a[i].toString());
      }
      String str = json.encode(aStr);
      String tmp =
          '{"title":"$title","content":"$content","days":"$days","cibles":"$cible","active":$b,"notification":$not,"keys":$str}';
      pref.setString(title, tmp);
    }
  }
}
