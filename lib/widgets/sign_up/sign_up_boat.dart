import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/home/home.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';
import 'package:school_village/widgets/sign_up/sign_up_vendor.dart';

enum BoatLocation {
  dockSlip,
  mooring,
  address,
  description,
}

class SignUpBoat extends StatefulWidget {
  const SignUpBoat({Key key, this.userData}) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  _SignUpBoatState createState() => _SignUpBoatState();
}

class _SignUpBoatState extends State<SignUpBoat> {
  BoatLocation _boatLocation = BoatLocation.dockSlip;
  final List<Map<String, dynamic>> marinas = <Map<String, dynamic>>[];
  final Map<String, dynamic> selectedMarina = <String, dynamic>{};

  final TextEditingController _marinaController = TextEditingController();
  final TextEditingController _boatNameController = TextEditingController();
  final TextEditingController _dockNumberController = TextEditingController();
  final TextEditingController _slipNumberController = TextEditingController();
  final TextEditingController _mooringNumberController =
      TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _onNextPressed() async {
    if (selectedMarina == null) {
      return;
    }
    final boatLocation = <String, dynamic>{};
    switch (_boatLocation) {
      case BoatLocation.dockSlip:
        boatLocation["dockNumber"] = _dockNumberController.text;
        boatLocation["slipNumber"] = _slipNumberController.text;
        break;
      case BoatLocation.mooring:
        boatLocation["mooring"] = _mooringNumberController.text;
        break;
      case BoatLocation.address:
        boatLocation["address"] = _streetAddressController.text;
        boatLocation["city"] = _cityController.text;
        boatLocation["state"] = _stateController.text;
        boatLocation["zip"] = _zipCodeController.text;
        break;
      case BoatLocation.description:
        boatLocation["description"] = _descriptionController.text;
        break;
    }
    final user = await FirebaseAuth.instance.currentUser();
    final document = FirebaseFirestore.instance.doc("users/${user.uid}");
    await document.set(
      {
        "associatedSchools": {
          selectedMarina["id"]: {
            "alerts": {
              "allowed": true,
            },
            "allowed": true,
            "groups": <String, bool>{},
            "role": "enduser",
          }
        },
        "boatName": _boatNameController.text,
        "boatLocationType": _boatLocation.toString().split(".").last,
        "boatLocation": boatLocation,
      },
      SetOptions(merge: true),
    );
    if (widget.userData["vendor"] ?? false) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => SignUpVendor(userData: widget.userData)),
        (route) => route.isFirst,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home()),
        (route) => false,
      );
    }
  }

  void _getMarinaList() {
    FirebaseFirestore.instance.collection("schools").get().then((docs) {
      marinas.clear();
      marinas.addAll(docs.docs
          .map((snapshot) => snapshot.data()..addAll({"id": snapshot.id})));
    });
  }

  @override
  void initState() {
    super.initState();
    _getMarinaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        backgroundColor: Color(0xffefedea),
        title: Column(
          children: [
            Text(
              localize("MarinaVillage"),
              style: TextStyle(
                color: Color(0xff323339),
                fontSize: 20.0,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              localize("Dock and Slip Info"),
              style: TextStyle(
                color: Color(0xff323339),
                fontSize: 16.0,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xffe5e5ea),
      body: Column(
        children: [
          Container(
            color: Color(0xff023280),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Material(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        localize("- Select Your Marina -"),
                                        style: TextStyle(
                                          color: Color(0xff023280),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.62,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Color(0xfff7f7f9),
                                      constraints: BoxConstraints(
                                        maxHeight: 256.0,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ListView.builder(
                                        itemBuilder: (context, index) {
                                          final item = marinas[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop(item);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4.0,
                                                vertical: 8.0,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.circle,
                                                    color: Color(0xff023280),
                                                    size: 8.0,
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Text(
                                                    item["name"],
                                                    style: TextStyle(
                                                      color: Color(0xff023280),
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.91,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: marinas.length,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                    selectedMarina.clear();
                    if (result != null) {
                      selectedMarina.addAll(result);
                      _marinaController.text = selectedMarina["name"];
                    }
                  },
                  child: SignUpTextField(
                    controller: _marinaController,
                    enabled: false,
                    hint: localize("click to Select Your Marina"),
                  ),
                ),
                const SizedBox(height: 8.0),
                SignUpTextField(
                  controller: _boatNameController,
                  hint: localize("Your Boat Name"),
                ),
                const SizedBox(height: 8.0),
                Text(
                  localize(
                      "Select (ONE) format and enter the location of your Boat"),
                  style: TextStyle(
                    color: Color(0xfffafaf8),
                    fontSize: 16.0,
                    height: 23.0 / 16.0,
                    letterSpacing: 0.49,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio(
                          value: BoatLocation.dockSlip,
                          groupValue: _boatLocation,
                          onChanged: (_) {
                            setState(() {
                              _boatLocation = BoatLocation.dockSlip;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    localize("Dock #"),
                                    style: TextStyle(
                                      color: Color(0xff023280),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.62,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 40.0,
                                      ),
                                      child: SignUpTextField(
                                        controller: _dockNumberController,
                                        enabled: _boatLocation ==
                                            BoatLocation.dockSlip,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                ],
                              ),
                              Text(
                                localize("sample: Dock C"),
                                style: TextStyle(
                                  color: Color(0xa6233339),
                                  fontSize: 16.0,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.49,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    localize("Slip #"),
                                    style: TextStyle(
                                      color: Color(0xff023280),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.62,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 40.0,
                                      ),
                                      child: SignUpTextField(
                                        controller: _slipNumberController,
                                        enabled: _boatLocation ==
                                            BoatLocation.dockSlip,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                ],
                              ),
                              Text(
                                localize("sample: Slip 27"),
                                style: TextStyle(
                                  color: Color(0xa6233339),
                                  fontSize: 16.0,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.49,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    indent: 8.0,
                    endIndent: 8.0,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio(
                        value: BoatLocation.mooring,
                        groupValue: _boatLocation,
                        onChanged: (_) {
                          setState(() {
                            _boatLocation = BoatLocation.mooring;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Text(
                                  localize("Mooring #"),
                                  style: TextStyle(
                                    color: Color(0xff023280),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.62,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 40.0,
                                    ),
                                    child: SignUpTextField(
                                      controller: _mooringNumberController,
                                      enabled:
                                          _boatLocation == BoatLocation.mooring,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                              ],
                            ),
                            Text(
                              localize("sample: Mooring #G23"),
                              style: TextStyle(
                                color: Color(0xa6233339),
                                fontSize: 16.0,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.49,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    indent: 8.0,
                    endIndent: 8.0,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio(
                        value: BoatLocation.address,
                        groupValue: _boatLocation,
                        onChanged: (_) {
                          setState(() {
                            _boatLocation = BoatLocation.address;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12.0),
                            Text(
                              localize("Address (private dock)"),
                              style: TextStyle(
                                color: Color(0xff023280),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.62,
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 40.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SignUpTextField(
                                  controller: _streetAddressController,
                                  enabled:
                                      _boatLocation == BoatLocation.address,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 40.0,
                                    ),
                                    child: SignUpTextField(
                                      controller: _cityController,
                                      hint: localize("Your City"),
                                      enabled:
                                          _boatLocation == BoatLocation.address,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 40.0,
                                    ),
                                    child: SignUpTextField(
                                      controller: _stateController,
                                      hint: localize("State"),
                                      enabled:
                                          _boatLocation == BoatLocation.address,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 40.0,
                                    ),
                                    child: SignUpTextField(
                                      controller: _zipCodeController,
                                      hint: localize("Zip"),
                                      enabled:
                                          _boatLocation == BoatLocation.address,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    indent: 8.0,
                    endIndent: 8.0,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio(
                        value: BoatLocation.description,
                        groupValue: _boatLocation,
                        onChanged: (_) {
                          setState(() {
                            _boatLocation = BoatLocation.description;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12.0),
                            Text(
                              localize("Other - Description"),
                              style: TextStyle(
                                color: Color(0xff023280),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.62,
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SignUpTextField(
                                  controller: _descriptionController,
                                  hint: localize(
                                      "provide a description if none of the above formats apply"),
                                  minLines: 3,
                                  maxLines: 3,
                                  enabled:
                                      _boatLocation == BoatLocation.description,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
          Container(
            height: 64.0,
            color: Colors.white,
            child: Center(
              child: Row(
                children: [
                  const Spacer(),
                  Container(
                    color: Colors.black,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      child: Text(
                        localize("Back").toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    color: Colors.blueAccent,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        _onNextPressed();
                      },
                      child: Text(
                        localize("Next").toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
