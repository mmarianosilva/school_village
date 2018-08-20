import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/user_helper.dart';

class Hotline extends StatefulWidget {
  @override
  _HotlineState createState() => new _HotlineState();
}

class _HotlineState extends State<Hotline> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _schoolId = '';
  String _schoolName = '';
  bool isLoaded = false;
  bool isEnglish = true;
  int numCharacters = 0;
  final customAlertController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String englishTitle = "Anonymous Safety Hotline";
  String spanishTitle = "Línea De Seguridad Anónima";
  String englishMessage = "Type Message ...";
  String spanishMessage = "Escribe mensaje ...";
  final _scrollController = ScrollController();
  final focusNode = FocusNode();

  getUserDetails() async {
    var schoolId = await UserHelper.getSelectedSchoolID();
    var schoolName = await UserHelper.getSchoolName();
    setState(() {
      _schoolId = schoolId;
      _schoolName = schoolName;
      isLoaded = true;
    });
  }

  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Timer(const Duration(milliseconds: 200), () {
          print("${_scrollController.position.maxScrollExtent}");
          _scrollController.animateTo(_scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 150), curve: Curves.ease);
        });
      }
    });

    super.initState();
  }

  _englishText() {
    return new Column(
      children: <Widget>[
        new RichText(
          text: new TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              new TextSpan(text: 'YOU', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(text: ' can make a difference in your school\'s safety. Here you can anonymously report:'),
            ],
          ),
        ),
        new RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              new TextSpan(
                  text: '\nBULLYING\nTHREATS\nASSAULT\nSEXUAL HARRASSMENT\nSAFETY ISSUES',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
        new RichText(
          text: new TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              new TextSpan(
                  text:
                      '\nAnonymously text a message below and tap SEND to make a report. This Hotline can also record voice messages and take photos.'),
              new TextSpan(text: '\n\nIF YOU', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(text: ' DO', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(
                  text: ' want someone  to contact  you  back,', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(text: ' just include your phone number or email address in your text.'),
              new TextSpan(text: ' — That is your choice.', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(
                  text:
                      '\n\nIf  you  or  someone  you  know  is  depressed  or  thinking  about suicide call 1-800-273-8255 now.\n\n'),
            ],
          ),
        )
      ],
    );
  }

  _spanishText() {
    return new Column(
      children: [
        new RichText(
          text: new TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              new TextSpan(text: 'USTED', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(
                  text: ' puede hacer una diferencia en la seguridad de su escuela. Aquí puede informar anónimamente:'),
            ],
          ),
        ),
        new RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              new TextSpan(
                  text: '\nACOSO\nAMENAZAS\nASALTO\nHARRASSMENT SEXUAL \nPROBLEMAS DE SEGURIDAD',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
        new RichText(
          text: new TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              new TextSpan(
                  text:
                      '\nAnónimamente envíe un mensaje de texto a continuación y toque ENVIAR para hacer un informe. Esta línea directa también puede grabar mensajes de voz y tomar fotos.'),
              new TextSpan(text: '\n\nSI', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(text: ' DESEA', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(
                  text: ' que alguien se ponga en contacto con usted,',
                  style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(
                  text: ' simplemente incluya su número de teléfono o dirección de correo electrónico en su texto'),
              new TextSpan(text: ' — Esa es su elección.', style: new TextStyle(fontWeight: FontWeight.bold)),
              new TextSpan(
                  text:
                      '\n\nSi usted o alguien que conoce está deprimido o está pensando en suicidarse, llame al 1-800-273-8255 ahora.\n\n'),
            ],
          ),
        )
      ],
    );
  }

  _buildText() {
    if (isEnglish) {
      return _englishText();
    } else {
      return _spanishText();
    }
  }

  _sendMessage() {
    var text = customAlertController.text;
    if (text.length < 1) return;
    _saveMessage(text);
  }

  _saveMessage(message) async {
    print('$_schoolId/hotline');
    CollectionReference collection = Firestore.instance.collection('$_schoolId/hotline');
    final DocumentReference document = collection.document();

    document.setData(<String, dynamic>{
      'body': message,
      'createdAt': new DateTime.now().millisecondsSinceEpoch,
      'createdBy': await UserHelper.getAnonymousRole()
    });
    print("Added hotline");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Sent'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[new Text('Your message has been sent')],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _buildInputBox() {
    return new Theme(
      data: new ThemeData(primaryColor: Colors.white, primaryColorDark: Colors.white, hintColor: Colors.white),
      child: new TextField(
        maxLines: 1,
        focusNode: focusNode,
        controller: customAlertController,
        style: TextStyle(color: Colors.white),
        onChanged: (String text) {
          setState(() {
            numCharacters = customAlertController.text.length;
          });
        },
        decoration: new InputDecoration(
            filled: true,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            fillColor: Colors.grey.shade800,
            border: const OutlineInputBorder(
                borderRadius: const BorderRadius.all(const Radius.circular(12.0)),
                borderSide: const BorderSide(color: Colors.white)),
            suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  _sendMessage();
                }),
            hintText: isEnglish ? englishMessage : spanishMessage),
      ),
    );
  }

  _buildContent() {
    return new SingleChildScrollView(
      controller: _scrollController,
      child: new Form(
        key: _formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new SizedBox(height: 12.0),
            new Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("English", style: TextStyle(color: Colors.white)),
                new Switch(
                    value: !isEnglish,
                    activeColor: Colors.grey.shade300,
                    activeTrackColor: Colors.grey.shade300,
                    inactiveTrackColor: Colors.grey.shade300,
                    onChanged: (bool value) {
                      setState(() {
                        isEnglish = !value;
                      });
                    }),
                Text("Español", style: TextStyle(color: Colors.white))
              ],
            ),
            _buildText(),
            _buildInputBox()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }

    return new Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: new AppBar(
          title: new Text(isEnglish ? englishTitle : spanishTitle,
              textAlign: TextAlign.center, style: new TextStyle(color: Colors.red.shade500)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(12.0),
          decoration: new BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            image: new DecorationImage(
                image: new AssetImage("assets/images/hotline_bg.png"),
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)),
          ),
          child: isLoaded ? _buildContent() : Text("Loading...") /* add child content content here */,
        ));
  }
}
