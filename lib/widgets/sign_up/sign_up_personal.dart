import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_boat.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPersonal extends StatefulWidget {
  @override
  _SignUpPersonalState createState() => _SignUpPersonalState();
}

class _SignUpPersonalState extends State<SignUpPersonal> {
  bool _agreed = false;

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
              localize("User Sign-Up"),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Color(0xff023280),
                    height: 48.0,
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      hint: localize("Email"),
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      hint: localize("Password"),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      hint: localize("Confirm Password"),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      hint: localize("First Name"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      hint: localize("Last Name"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      hint: localize("Phone"),
                      textInputType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Color(0xff323339),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        height: 20.0 / 16.0,
                        letterSpacing: 0.62,
                      ),
                      children: [
                        TextSpan(
                          text: localize("By continuing you accept our "),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () async {
                              if (await canLaunch(
                                  Constants.termsOfServiceUrl)) {
                                launch(Constants.termsOfServiceUrl);
                              }
                            },
                            child: Text(
                              localize("Terms"),
                              style: TextStyle(
                                color: Color(0xff0a7aff),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                height: 20.0 / 16.0,
                                letterSpacing: 0.62,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: localize(" and "),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () async {
                              if (await canLaunch(Constants.privacyPolicyUrl)) {
                                launch(Constants.privacyPolicyUrl);
                              }
                            },
                            child: Text(
                              localize("Privacy Policy"),
                              style: TextStyle(
                                color: Color(0xff0a7aff),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                height: 20.0 / 16.0,
                                letterSpacing: 0.62,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    Checkbox(
                      value: _agreed,
                      onChanged: (value) {
                        setState(() {
                          _agreed = value;
                        });
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      localize("I Agree"),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      color: Colors.black,
                      child: FlatButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {},
                        child: Text(
                          localize("Cancel").toUpperCase(),
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
                        onPressed: () {},
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
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
