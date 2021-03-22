import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';

class RequestMoreInformation extends StatefulWidget {
  @override
  _RequestMoreInformationState createState() => _RequestMoreInformationState();
}

class _RequestMoreInformationState extends State<RequestMoreInformation> {
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
              localize("Request Info"),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Color(0xff023280),
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                    color: Color(0xfffafaf8),
                    fontSize: 17.0,
                    height: 23.0 / 17.0,
                    letterSpacing: 0.09,
                  ),
                  children: [
                    TextSpan(text: localize("Request a ")),
                    TextSpan(
                        text: localize("Marina"),
                        style: TextStyle(color: Color(0xffff0028))),
                    TextSpan(
                        text: localize("Village"),
                        style: TextStyle(color: Color(0xff14c3ef))),
                    TextSpan(
                        text: localize(
                            "Trial, Demonstration, or Additional Information. Please provide your contact information and a representative will contact you.")),
                  ]),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SignUpTextField(
              hint: localize("First Name"),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SignUpTextField(
              hint: localize("Last Name"),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SignUpTextField(
              hint: localize("Email"),
              textInputType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SignUpTextField(
              hint: localize("Phone"),
              textInputType: TextInputType.phone,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SignUpTextField(
              hint: localize("Comments"),
              minLines: 4,
              maxLines: 4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: Colors.white,
            child: Center(
              child: FlatButton(
                onPressed: () {},
                child: Text("Slide right to submit"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
