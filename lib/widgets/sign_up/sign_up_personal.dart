import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_boat.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';
import 'package:school_village/widgets/sign_up/sign_up_vendor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPersonal extends StatefulWidget {
  @override
  _SignUpPersonalState createState() => _SignUpPersonalState();
}

class _SignUpPersonalState extends State<SignUpPersonal> {
  bool _agreed = false;
  bool _isBoater = true;
  bool _isVendor = false;
  String _error;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _validateEmail() {
    return Constants.emailRegEx.hasMatch(_emailController.text);
  }

  bool _validatePassword() {
    return _passwordController.text.length > 8;
  }

  bool _validatePasswordsMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  bool _validateFirstName() {
    return _firstNameController.text.isNotEmpty;
  }

  bool _validateLastName() {
    return _lastNameController.text.isNotEmpty;
  }

  bool _validatePhoneNumber() {
    return _phoneController.text
            .replaceAll("(", "")
            .replaceAll(")", "")
            .replaceAll(" ", "")
            .replaceAll("-", "")
            .length ==
        10;
  }

  Future<void> _onNextPressed() async {
    setState(() {
      _error = null;
    });
    if (!_validateEmail()) {
      setState(() {
        _error = localize("Please enter a valid email address");
      });
      return;
    }
    if (!_validatePassword()) {
      setState(() {
        _error = localize("Password must be longer than 8 characters");
      });
      return;
    }
    if (!_validatePasswordsMatch()) {
      setState(() {
        _error = localize("Passwords do not match");
      });
      return;
    }
    if (!_validateFirstName()) {
      setState(() {
        _error = localize("First name must not be empty");
      });
    }
    if (!_validateLastName()) {
      setState(() {
        _error = localize("Last name must not be empty");
      });
    }
    if (!_validatePhoneNumber()) {
      setState(() {
        _error = localize("Phone number must have 10 digits");
      });
      return;
    }
    if (!_isBoater && !_isVendor) {
      setState(() {
        _error = localize("Please select at least one user type");
      });
      return;
    }
    if (!_agreed) {
      setState(() {
        _error = localize(
            "You must agree to Terms and Privacy Policy in order to sign up");
      });
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    try {
      final auth = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (auth.user != null) {
        try {
          await auth.user.sendEmailVerification();
        } catch (e) {
          print("An error occured while trying to send email verification");
          print(e.message);
        }
        final sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString("email", email.trim().toLowerCase());
        sharedPreferences.setString("password", password);
      }
      final data = <String, dynamic>{
        "email": email,
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "phone": _phoneController.text
            .replaceAll("(", "")
            .replaceAll(")", "")
            .replaceAll(" ", "")
            .replaceAll("-", ""),
      };
      data["vendor"] = _isVendor ?? false;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.user.uid)
          .set(data);

      if (_isBoater) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SignUpBoat(userData: data)));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SignUpVendor(userData: data)));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _error = "Password does not meet the security criteria";
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _error = "This email has already been registered";
        });
      }
    }
  }



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          hint: localize("Password (at least 9 characters)"),
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
                          capitalisation: TextCapitalization.sentences,
                          controller: _firstNameController,
                          hint: localize("First Name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: SignUpTextField(
                          capitalisation: TextCapitalization.sentences,
                          controller: _lastNameController,
                          hint: localize("Last Name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: SignUpTextField(
                         // inputFormatter: MaskedInputFormatter('(###) ###-####'),

                          controller: _phoneController,
                          hint: localize("Phone"),
                          textInputType:
                              TextInputType.phone,
                          inputFormatter: MaskedInputFormatter("(###)###-####"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          localize("User Type:"),
                          style: TextStyle(
                            color: Color(0xff023280),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.43,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Spacer(),
                            Checkbox(
                              value: _isBoater,
                              onChanged: (val) {
                                setState(() {
                                  _isBoater = val;
                                });
                              },
                            ),
                            Text(
                              localize("Boater"),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xff023280),
                              ),
                            ),
                            const Spacer(),
                            Checkbox(
                              value: _isVendor,
                              onChanged: (val) {
                                setState(() {
                                  _isVendor = val;
                                });
                              },
                            ),
                            Text(
                              localize("Vendor"),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xff023280),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      SizedBox(
                          height:
                              MediaQuery.of(context).viewInsets.bottom + 24.0),
                    ],
                  ),
                ),
              ),
              MediaQuery.of(context).viewInsets.bottom != 0.0
                  ? const SizedBox()
                  : Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 48.0),
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
                                    text: localize(
                                        "By continuing you accept our "),
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
                                        if (await canLaunch(
                                            Constants.privacyPolicyUrl)) {
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
                          SizedBox(
                            height: 40.0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                _error ?? '',
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Spacer(),
                              Container(
                                color: Colors.black,
                                child: FlatButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
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
          resizeToAvoidBottomInset: false,
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
