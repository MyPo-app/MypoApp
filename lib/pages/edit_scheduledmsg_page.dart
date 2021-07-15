import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mypo/model/scheduledmsg_hive.dart';
import 'package:mypo/pages/sms_prog_page.dart';
import 'package:mypo/widget/appbar_widget.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class ScheduledmsgDetailPage extends StatefulWidget {
  late Scheduledmsg_hive message;
  ScheduledmsgDetailPage({
    Key? key,
    required this.message,
  }) : super(key: key);
  @override
  _ScheduledmsgDetailPageState createState() => _ScheduledmsgDetailPageState();
}

class _ScheduledmsgDetailPageState extends State<ScheduledmsgDetailPage> {
  late final alertName;
  late final alertContact;
  late final alertContent;
  late final alertTime;
  bool countdown = false;
  bool confirm = false;
  bool notification = false;
  bool hasChanged = false;

  List<Contact> contacts = [];
  final repeatOptions = [
    'Toutes les heures',
    'Tous les jours',
    'Toutes les semaines',
    'Tous les mois',
    'Tous les ans'
  ];
  int index = 0;

  @override
  void initState() {
    super.initState();
    getAllContacts();
    alertName = TextEditingController(text: widget.message.name);
    alertContact = TextEditingController(text: widget.message.phoneNumber);
    alertContent = TextEditingController(text: widget.message.message);
    countdown = widget.message.countdown;
    confirm = widget.message.confirm;
    notification = widget.message.notification;

    alertName.addListener(() {
      changed;
    });
    alertContact.addListener(() {
      changed;
    });
    alertContent.addListener(() {
      changed;
    });
    print(widget.message.repeat);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    alertName.dispose();
    alertContent.dispose();
    alertContact.dispose();
    super.dispose();
  }

  getAllContacts() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
    }

    if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
    }

    if (await Permission.contacts.request().isGranted) {
      // Get all contacts without thumbnail (faster)
      List<Contact> _contacts =
          (await ContactsService.getContacts(withThumbnails: false)).toList();
      setState(() {
        contacts = _contacts;
      });
    }
  }

  void changed() {
    this.hasChanged = true;
  }

  void saveChanges() {
    widget.message.name = alertName.text;
    widget.message.phoneNumber = alertContact.text;
    widget.message.message = alertContent.text;
    widget.message.countdown = countdown;
    widget.message.confirm = confirm;
    widget.message.notification = notification;
    widget.message.status = MessageStatus.PENDING;
    widget.message.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: TopBar(title: 'Alerte : ${widget.message.name}'),
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
                buildTextField('Nom', '${widget.message.name}', alertName, 1),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: TextField(
                      minLines: 1,
                      maxLines: 1,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: TextInputType.phone,
                      controller: alertContact,
                      decoration: InputDecoration(
                        labelText: 'Numero du contact',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.person_add,
                                size: 35, color: Colors.blue),
                            onPressed: () =>
                                _buildContactSelection(context, contacts)),
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
                        hintText: "Ajoutez un numero de telephone",
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
                buildTextField(
                    'Message', '${widget.message.message}', alertContent, 3),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                            "\ndate: ${DateFormat('dd/MM/yyyy').format(widget.message.date)} \nheure: ${DateFormat('HH:mm').format(widget.message.date)} ",
                            style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: OutlinedButton(
                            // onPressed: null,
                            onPressed: () => showSheet(context,
                                child: buildDatePicker(), onClicked: () {
                              // final value =
                              //     DateFormat('dd/MM/yyyy HH:mm').format(alertDate);
                              Navigator.pop(context);
                            }),

                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: d_green, width: 2),
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Changer la date ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Text("récurrence: ${widget.message.repeat} ",
                            style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: OutlinedButton(
                            // onPressed: null,
                            onPressed: () => showSheet(context,
                                child: buildRepeatOptions(), onClicked: () {
                              Navigator.pop(context);
                              print(widget.message.date);
                              print(widget.message.repeat);
                              // print(confirm);
                              // print(notif);
                            }),

                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: d_green, width: 2),
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Changer la récurrence",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text("Compte à rebours"),
                        margin: EdgeInsets.fromLTRB(
                            5,
                            0,
                            MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width * 0.51,
                            0),
                      ),
                      Switch(
                          activeColor: d_green,
                          value: countdown,
                          onChanged: (bool val) => {
                                setState(() {
                                  countdown = val;
                                })
                              }),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text("Confirmer avant envoi"),
                        margin: EdgeInsets.fromLTRB(
                            5,
                            0,
                            MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width * 0.57,
                            0),
                      ),
                      Switch(
                          activeColor: d_green,
                          value: confirm,
                          onChanged: (bool val) => {
                                setState(() {
                                  confirm = val;
                                })
                              }),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text("Notification"),
                        margin: EdgeInsets.fromLTRB(
                            5,
                            0,
                            MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width * 0.41,
                            0),
                      ),
                      Switch(
                          activeColor: d_green,
                          value: notification,
                          onChanged: (bool val) => {
                                setState(() {
                                  notification = val;
                                })
                              }),
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
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => {
                          Navigator.pop(context),
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new SmsProg()),
                          ),
                        },
                        child: Text(
                          "CANCEL",
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
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // print('dont forget to save');
                          saveChanges();
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new SmsProg()));
                        },
                        child: Text(
                          "SAVE",
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
          controller: controller,
          onChanged: (String value) => {
            setState(() {
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

  _buildContactSelection(BuildContext context, var contacts) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Contacts'),
              content: SingleChildScrollView(
                  child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          Contact contact = contacts[index];
                          return ListTile(
                            title: Text(contact.displayName ?? ' '),
                            subtitle:
                                Text(contact.phones?.elementAt(0).value! ?? ''),
                            leading: (contact.avatar != null &&
                                    contact.avatar!.length > 0)
                                ? CircleAvatar(
                                    backgroundImage:
                                        MemoryImage(contact.avatar!))
                                : CircleAvatar(
                                    foregroundColor: Colors.white,
                                    backgroundColor: d_green,
                                    child: Text(contact.initials())),
                            onTap: () {
                              // selected contact
                              // print('contact ' + index.toString());
                              Navigator.of(context).pop();
                              // we set the text of the controller to the number of the contact chosen
                              alertContact.text =
                                  contact.phones?.elementAt(0).value! ?? '';
                            },
                          );
                        })
                  ],
                ),
              )));
        });
  }

  Widget buildDatePicker() => SizedBox(
        height: 150,
        child: CupertinoDatePicker(
            minimumYear: widget.message.date.year,
            maximumYear: DateTime.now().year + 3,
            initialDateTime: widget.message.date,
            mode: CupertinoDatePickerMode.dateAndTime,
            use24hFormat: true,
            onDateTimeChanged: (dateTime) =>
                setState(() => widget.message.date = dateTime)),
      );

  showSheet(BuildContext context,
          {required Widget child, required VoidCallback onClicked}) =>
      showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
                actions: [
                  child,
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Valider', style: TextStyle(color: d_green)),
                  onPressed: onClicked,
                ),
              ));
  Widget buildRepeatOptions() => SizedBox(
        height: 200,
        child: CupertinoPicker(
            diameterRatio: 0.8,
            itemExtent: 50,
            looping: true,
            onSelectedItemChanged: (index) => setState(() {
                  widget.message.repeat = repeatOptions[index];
                }),
            children: modelBuilder<String>(repeatOptions, (index, option) {
              return Center(child: Text(option));
            })),
      );
  List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();
}
