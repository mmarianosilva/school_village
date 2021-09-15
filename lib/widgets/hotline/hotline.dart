import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/usecase/select_image_usecase.dart';
import 'package:school_village/usecase/upload_file_usecase.dart';
import 'package:school_village/util/video_helper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class Hotline extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HotlineState createState() => _HotlineState();
}

class _HotlineState extends State<Hotline> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _schoolId = '';
  String _schoolName = '';
  bool isLoaded = false;
  bool isEnglish = true;
  int numCharacters = 0;
  File _selectedMedia;
  bool _isVideo = false;
  final customAlertController = TextEditingController();
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
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 150),
              curve: Curves.ease);
        });
      }
    });
    getUserDetails();
    super.initState();
  }

  _englishText() {
    return Column(
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                  text: 'YOU', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' can make a difference in your school\'s safety. Here you can anonymously report:'),
            ],
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                  text:
                      '\nBULLYING\nTHREATS\nASSAULT\nSEXUAL HARRASSMENT\nSAFETY ISSUES',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                  text:
                      '\nAnonymously text a message below and tap SEND to make a report. This Hotline can also send photos.'),
              TextSpan(
                  text: '\n\nIF YOU',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: ' DO', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: ' want someone  to contact  you  back,',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' just include your phone number or email address in your text.'),
              TextSpan(
                  text: ' — That is your choice.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '\n\nIf  you  or  someone  you  know  is  depressed  or  thinking  about suicide call 1-800-273-8255 now.\n\n'),
            ],
          ),
        )
      ],
    );
  }

  _spanishText() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                  text: 'USTED', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' puede hacer una diferencia en la seguridad de su escuela. Aquí puede informar anónimamente:'),
            ],
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                  text:
                      '\nACOSO\nAMENAZAS\nASALTO\nHARRASSMENT SEXUAL \nPROBLEMAS DE SEGURIDAD',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text: '',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                  text:
                      '\nAnónimamente envíe un mensaje de texto a continuación y toque ENVIAR para hacer un informe. Esta línea directa también puede enviar fotos.'),
              TextSpan(
                  text: '\n\nSI',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: ' DESEA',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: ' que alguien se ponga en contacto con usted,',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' simplemente incluya su número de teléfono o dirección de correo electrónico en su texto'),
              TextSpan(
                  text: ' — Esa es su elección.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
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
    if (text.length < 1 && _selectedMedia == null) return;
    _saveMessage(text);
  }

  Future<String> _getUserId()async {
    FirebaseUser user = await UserHelper.getUser();
    final _user = FirebaseFirestore.instance.doc('users/${user.uid}');
    final _userId = (await _user.get()).id;
    return _userId;
  }

  _saveMessage(message) async {
    final String hotlinePath = '$_schoolId/hotline';
    CollectionReference collection =
        FirebaseFirestore.instance.collection(hotlinePath);
    final DocumentReference document = collection.doc();
    final String role = await UserHelper.getSelectedSchoolRole();
    final String schoolId = await UserHelper.getSelectedSchoolID();
    final String userId = await _getUserId();

    if (_selectedMedia != null) {
      setState(() {
        isLoaded = false;
      });
      final File uploadFile = _isVideo
          ? File(await VideoHelper.convertedVideoPath(_selectedMedia))
          : _selectedMedia;
      final UploadFileUsecase uploadFileUsecase = UploadFileUsecase();
      uploadFileUsecase.uploadFile(
          '$hotlinePath/${DateTime.now().millisecondsSinceEpoch.toString()}/${uploadFile.path.substring(uploadFile.parent.path.length + 1)}',
          uploadFile, onComplete: (String url) {
        document.set({
          'body': message,
          'createdById': userId,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'createdBy': role,
          'schoolId': schoolId,
          'isVideo': _isVideo,
          'media': url,
        });
      });
      widget._scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'Your file is being uploaded in the background. This can take a long time'),
      ));
      setState(() {
        isLoaded = true;
      });
    } else {
      document.set({
        'body': message,
        'createdById': userId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'createdBy': await UserHelper.getSelectedSchoolRole(),
        'schoolId': await UserHelper.getSelectedSchoolID(),
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localize('Sent')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(localize('Your message has been sent'))
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(localize('Okay')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  _buildPreviewBox() {
    if (_selectedMedia == null) {
      return SizedBox();
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: _isVideo
                  ? VideoHelper.thumbnailPath(_selectedMedia)
                      .then((path) => File(path))
                  : Future.value(_selectedMedia),
              builder: (BuildContext _, AsyncSnapshot<File> snapshot) {
                if (snapshot.hasData) {
                  return Image.file(snapshot.data);
                }
                return SizedBox();
              },
            ),
          ),
          FlatButton(
            child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  'x',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                )),
            onPressed: () {
              setState(() {
                _selectedMedia = null;
              });
            },
          )
        ],
      ),
    );
  }

  _buildInputBox() {
    return Theme(
      data: ThemeData(
          primaryColor: Colors.white,
          primaryColorDark: Colors.white,
          hintColor: Colors.white),
      child: TextField(
        maxLines: 1,
        focusNode: focusNode,
        controller: customAlertController,
        style: TextStyle(color: Colors.white),
        onChanged: (String text) {
          setState(() {
            numCharacters = customAlertController.text.length;
          });
        },
        decoration: InputDecoration(
            filled: true,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            fillColor: Colors.grey.shade800,
            border: const OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(const Radius.circular(12.0)),
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

  _buildMediaInputRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              icon: Icon(Icons.photo_camera, color: Colors.black54, size: 32.0),
              onPressed: () async {
                final SelectImageUsecase selectImageUsecase =
                    SelectImageUsecase();
                File image = await selectImageUsecase.takeImage();
                if (image != null) {
                  setState(() {
                    _selectedMedia = image;
                    _isVideo = false;
                  });
                }
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              icon: Icon(Icons.videocam, color: Colors.black54, size: 32.0),
              onPressed: () async {
                final SelectImageUsecase selectImageUsecase =
                    SelectImageUsecase();
                File video = await selectImageUsecase.selectVideo();
                if (video != null) {
                  setState(() {
                    isLoaded = false;
                  });
                  await VideoHelper.buildThumbnail(video);
                  await VideoHelper.processVideoForUpload(video);
                  setState(() {
                    isLoaded = true;
                    _selectedMedia = video;
                    _isVideo = true;
                  });
                }
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              icon: Icon(Icons.photo, color: Colors.black54, size: 32.0),
              onPressed: () async {
                final SelectImageUsecase selectImageUsecase =
                    SelectImageUsecase();
                File image = await selectImageUsecase.selectImage();
                if (image != null) {
                  setState(() {
                    _selectedMedia = image;
                    _isVideo = false;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 12.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(localize("English"),
                    style: TextStyle(color: Colors.white)),
                Switch(
                    value: !isEnglish,
                    activeColor: Colors.grey.shade300,
                    activeTrackColor: Colors.grey.shade300,
                    inactiveTrackColor: Colors.grey.shade300,
                    onChanged: (bool value) {
                      setState(() {
                        isEnglish = !value;
                      });
                    }),
                Text(localize("Español"), style: TextStyle(color: Colors.white))
              ],
            ),
            _buildText(),
            _buildPreviewBox(),
            _buildInputBox(),
            _buildMediaInputRow(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget._scaffoldKey,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(isEnglish ? englishTitle : spanishTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade500)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            image: DecorationImage(
                image: AssetImage("assets/images/hotline_bg.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.darken)),
          ),
          child: isLoaded
              ? _buildContent()
              : Center(
                  child: CircularProgressIndicator(),
                ) /* add child content content here */,
        ));
  }
}
