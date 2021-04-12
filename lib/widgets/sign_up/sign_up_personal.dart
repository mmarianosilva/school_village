import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_boat.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPersonal extends StatefulWidget {
  @override
  _SignUpPersonalState createState() => _SignUpPersonalState();
}

class _SignUpPersonalState extends State<SignUpPersonal> {
  bool _agreed = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _validateEmail() {
    return Constants.emailRegEx.hasMatch(_emailController.text);
  }

  bool _validatePassword() {
    return _passwordController.text.length > 8 && _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _onNextPressed() async {
    if (!_validateEmail()) {
      return;
    }
    if (!_validatePassword()) {
      return;
    }
    if (!_agreed) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    if (auth.user != null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("email", email.trim().toLowerCase());
      sharedPreferences.setString("password", password);
    }
    await FirebaseFirestore.instance.collection("users").doc(auth.user.uid).set({
      "email": email,
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "phone": _phoneController.text,
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpBoat()));
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
                      controller: _emailController,
                      hint: localize("Email"),
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      controller: _passwordController,
                      hint: localize("Password"),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      controller: _confirmPasswordController,
                      hint: localize("Confirm Password"),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      controller: _firstNameController,
                      hint: localize("First Name"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      controller: _lastNameController,
                      hint: localize("Last Name"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SignUpTextField(
                      controller: _phoneController,
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
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
