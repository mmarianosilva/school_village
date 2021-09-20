import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/widgets/home/home.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';

class SelectedHarbor {
  SelectedHarbor(
    this.ref,
    this.name, {
    this.selected = false,
    this.slipCount = 0,
  });

  final DocumentReference ref;
  final String name;
  bool selected;
  int slipCount;

  void resetSlipCount() {
    slipCount = 0;
  }

  void addToSlipCount(int count) {
    slipCount = slipCount + count;
  }
}

class SignUpVendorBilling extends StatefulWidget {
  const SignUpVendorBilling({Key key, this.vendor}) : super(key: key);

  final Vendor vendor;

  @override
  _SignUpVendorBillingState createState() => _SignUpVendorBillingState();
}

class _SignUpVendorBillingState extends State<SignUpVendorBilling> {
  final List<SelectedHarbor> _availableHarbors = <SelectedHarbor>[];

  List<SelectedHarbor> get _selectedHarbors =>
      _availableHarbors.where((item) => item.selected).toList();
  int _slipCount = 0;

  double get _computedPrice => _slipCount * 0.02;

  Future<void> _onNextPressed() async {
    print("post signup#1");
    await FirebaseFirestore.instance.doc(widget.vendor.id).set(
      <String, dynamic>{
        "districts": _selectedHarbors.map((item) => item.ref).toList(),
      },
      SetOptions(merge: true),
    );
    print("post signup#2");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Home()),
      (route) => false,
    );
    print("post signup#3");
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("districts").get().then((snapshot) {
      _availableHarbors.clear();
      _availableHarbors.addAll(snapshot.docs.map((snapshot) =>
          SelectedHarbor(snapshot.reference, snapshot.data()["name"])));
      setState(() {});
    });
  }

  Future<void> _calculateSlipsForSelectedHarbors() async {
    if (_selectedHarbors.isEmpty) {
      setState(() {});
      return;
    }
    final matchingSchools = await FirebaseFirestore.instance
        .collection("schools")
        .where("district",
            whereIn: _selectedHarbors.map((snapshot) => snapshot.ref).toList())
        .get();
    _selectedHarbors.forEach((item) {
      item.resetSlipCount();
    });
    matchingSchools.docs.forEach((snapshot) {
      if (snapshot.data().containsKey("slipsCount")) {
        final district = snapshot.data()["district"] as DocumentReference;
        _selectedHarbors
            .firstWhere((item) => item.ref == district)
            .addToSlipCount((((snapshot.data()["slipsCount"] ?? null) != null))&&(((snapshot.data()["slipsCount"] ?? null) != ''))
                ? (snapshot.data()["slipsCount"])
                : 0);
      }
    });
    //TODO Fix The parse issues here
    _slipCount = _selectedHarbors
        .map((item) => item.slipCount)
        .reduce((total, current) => total = total + current);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(
          localize('MarinaVillage'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, letterSpacing: 1.29),
        ),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xff023280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Color(0xfffafaf8),
                        fontSize: 16.0,
                        height: 21.0 / 16.0,
                      ),
                      text:
                          "Please Choose your Marina Group. Listing charges are based on the number of slips in the Marina group and are calculated below. Charges apply after ",
                      children: [
                        TextSpan(
                          text: "30-day Free Trial",
                          style: TextStyle(
                            color: Color(0xff14c3ef),
                          ),
                        ),
                        TextSpan(
                          text:
                              ". You may select multiple groups. Selections can be changed at any time. Tap on selected Group name for list of marinas in that group.",
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, stateBuilder) => Padding(
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
                                          localize("Marina Groups:"),
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
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  final item =
                                                      _availableHarbors[index];
                                                  return CheckboxListTile(
                                                    value: item.selected,
                                                    onChanged: (value) {
                                                      stateBuilder(() {
                                                        item.selected = value;
                                                      });
                                                    },
                                                    title:
                                                        Text(item.name ?? ""),
                                                  );
                                                },
                                                itemCount:
                                                    _availableHarbors.length,
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                localize("Confirm")
                                                    .toUpperCase(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                    _calculateSlipsForSelectedHarbors();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      enabled: false,
                      hint: localize("click to Select Your Marina Group(s)"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 8.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Selected Groups",
                  style: TextStyle(
                    color: Color(0xff023280),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.62,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Slips",
                  style: TextStyle(
                    color: Color(0xff023280),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.62,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: _buildHarborListItem,
              itemCount: _selectedHarbors.length,
            ),
          ),
          Container(
            color: Color(0xffe8e8eb),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Slip Count",
                          style: TextStyle(
                            color: Color(0xff023280),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Color(0xff023280),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        width: 64.0,
                        child: Text(
                          "$_slipCount",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 0.12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24.0),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          maxLines: 2,
                          text: TextSpan(
                            style: TextStyle(
                              color: Color(0xff023280),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.12,
                            ),
                            children: [
                              TextSpan(text: "Monthly listing charge after "),
                              TextSpan(
                                text: "30-day Free Trial",
                                style: TextStyle(
                                  color: Color(0xff0f97b9),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Color(0xff023280),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        width: 64.0,
                        child: Text(
                          "\$${NumberFormat("##0.0#", "en_US").format(_computedPrice)}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 0.12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24.0),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  color: Color(0xff48484a),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      localize("Back").toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Container(
                  color: Color(0xff0a7aff),
                  child: FlatButton(
                    onPressed: _onNextPressed,
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
        ],
      ),
    );
  }

  Widget _buildHarborListItem(BuildContext context, int index) {
    final item = _selectedHarbors[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "•".toUpperCase(),
                style: TextStyle(
                  color: Color(0xff023280),
                  fontSize: 32.0,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 4.0),
            ],
          ),
          const SizedBox(width: 8.0),
          Text(
            item.name,
            style: TextStyle(
              color: Color(0xff023280),
              fontSize: 15.0,
              letterSpacing: -0.7,
            ),
          ),
          const Spacer(),
          Text(
            "${item.slipCount}",
            style: TextStyle(
              color: Color(0xff023280),
              fontSize: 15.0,
              letterSpacing: -0.7,
            ),
          ),
          const Icon(
            Icons.delete_outline,
            color: Color(0xff023280),
          ),
        ],
      ),
    );
  }
}
