import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_village/widgets/home/home.dart';
import 'package:school_village/util/localizations/localization.dart';

class SignUpVendorBilling extends StatefulWidget {
  const SignUpVendorBilling({Key key}) : super(key: key);

  @override
  _SignUpVendorBillingState createState() => _SignUpVendorBillingState();
}

class _SignUpVendorBillingState extends State<SignUpVendorBilling> {
  final List<Map<String, dynamic>> _selectedHarbors = <Map<String, dynamic>>[];
  final int _slipCount = 0;

  double get _computedPrice => _slipCount * 0.02;

  Future<void> _onNextPressed() async {
    await FirebaseFirestore.instance.doc("").set(
      <String, dynamic>{
        "districts": _selectedHarbors.map((item) =>
            FirebaseFirestore.instance.doc("districts/${item["id"]}")),
      },
      SetOptions(merge: true),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Home()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color(0xff023280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            ),
          ),
          Row(
            children: [
              Text("Selected Groups"),
              const Spacer(),
              Text("Slips"),
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
                Row(
                  children: [
                    Text("Slip Count"),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Color(0xff023280),
                      ),
                      width: 128.0,
                      child: Text(
                        "$_slipCount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "Monthly listing charge after "),
                          TextSpan(text: "30-day Free Trial"),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Color(0xff023280),
                      ),
                      width: 128.0,
                      child: Text(
                        "\$${NumberFormat("###.0#", "en_US").format(_computedPrice)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
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
    return const SizedBox();
  }
}
