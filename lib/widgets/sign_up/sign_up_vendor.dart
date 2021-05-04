import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';

enum PrimaryContact {
  mobile,
  office,
}

class _SelectedCategory {
  _SelectedCategory(this.category, {this.selected = false});

  final VendorCategory category;
  bool selected;
}

class SignUpVendor extends StatefulWidget {
  @override
  _SignUpVendorState createState() => _SignUpVendorState();
}

class _SignUpVendorState extends State<SignUpVendor> {
  File _selectedPhoto;
  PrimaryContact _primaryContact = PrimaryContact.mobile;
  String _error = "";
  final _categories = List<_SelectedCategory>();
  final _companyWebsiteController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _mobilePhoneController = MaskedTextController(mask: "(000) 000-0000");
  final _officePhoneController = MaskedTextController(mask: "(000) 000-0000");

  bool _verifyPhone() {
    if (_primaryContact == PrimaryContact.mobile) {
      return _mobilePhoneController.text.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").length == 10;
    }
    return _officePhoneController.text.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").length == 10;
  }

  bool _validateEmail() {
    return Constants.emailRegEx.hasMatch(_companyEmailController.text);
  }

  @override
  void initState() {
    super.initState();
    _getVendorCategories();
  }

  void _getVendorCategories() {
    FirebaseFirestore.instance.collection("services").get().then((snapshot) {
      _categories.clear();
      _categories.addAll(snapshot.docs.map((doc) =>
          _SelectedCategory(VendorCategory.fromDocument(document: doc))));
    });
  }

  void _onNextPressed() {
    if (!_verifyPhone()) {
      setState(() {
        _error = "Primary phone number must have 10 digits";
      });
      return;
    }
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: Color(0xff023280),
                    height: 48.0,
                    child: Text(
                      localize("FREE TRIAL - 30 DAYS\nCANCEL AT ANY TIME"),
                      style: TextStyle(
                          color: Color(0xfffafaf8),
                          fontSize: 16.0,
                          letterSpacing: -0.38,
                          height: 27.0 / 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    localize(
                        "Input and submit the info below to preview your listing"),
                    style: TextStyle(
                      color: Color(0xff323339),
                      fontSize: 16.0,
                      height: 23.0 / 16.0,
                      letterSpacing: 1.16,
                    ),
                  ),
                  Text(
                    localize("Fields marked * or RED are Required"),
                    style: TextStyle(
                      color: Color(0xff610317),
                      fontSize: 16.0,
                      letterSpacing: 1.16,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 80.0,
                        child: _selectedPhoto != null
                            ? Image.file(_selectedPhoto)
                            : Container(
                                width: 80.0,
                                color: Color(0xff979797),
                                child: Center(
                                  child: Text(
                                    localize("LOGO\nclick to\nupload"),
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              localize("* Service Type"),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                await showDialog(
                                    barrierDismissible: false,
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    localize(
                                                        "- Select Your Marina -"),
                                                    style: TextStyle(
                                                      color: Color(0xff023280),
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.62,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Color(0xfff7f7f9),
                                                  constraints: BoxConstraints(
                                                    maxHeight: 256.0,
                                                  ),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemBuilder:
                                                              (context, index) {
                                                            final item =
                                                                _categories[
                                                                    index];
                                                            return CheckboxListTile(
                                                              value:
                                                                  _categories[
                                                                          index]
                                                                      .selected,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _categories[
                                                                          index]
                                                                      .selected = value;
                                                                });
                                                              },
                                                              title: Text(item
                                                                      .category
                                                                      .name ??
                                                                  ""),
                                                            );
                                                          },
                                                          itemCount: _categories
                                                              .length,
                                                        ),
                                                      ),
                                                      MaterialButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
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
                                      );
                                    });
                                setState(() {});
                              },
                              child: Text(
                                _categories.indexWhere(
                                            (item) => item.selected) !=
                                        -1
                                    ? _categories
                                        .where((item) => item.selected)
                                        .map((item) => item.category.name)
                                        .reduce((current, next) =>
                                            "$current, $next")
                                    : localize("Select All That Apply"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SignUpTextField(
                    controller: _companyWebsiteController,
                    hint: localize("Company Website"),
                  ),
                  SignUpTextField(
                    controller: _companyNameController,
                    hint: localize("Company Name"),
                  ),
                  SignUpTextField(
                    controller: _companyEmailController,
                    hint: localize("Company Email *"),
                  ),
                  Container(
                    color: Color(0xffd7d3d3),
                    child: Column(
                      children: [
                        Text(
                          localize("Optional"),
                        ),
                        SignUpTextField(
                          controller: _addressController,
                          hint: localize("Address"),
                        ),
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
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    localize(
                        "You must input and select the primary phone number"),
                    maxLines: 2,
                    style: TextStyle(
                      color: Color(0xff810317),
                      fontSize: 14.0,
                      letterSpacing: 0.43,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SignUpTextField(
                              hint: localize("Phone-Mobile"),
                            ),
                            SignUpTextField(
                              hint: localize("Phone-Office"),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  groupValue: _primaryContact,
                                  onChanged: (value) {
                                    setState(() {
                                      _primaryContact = value;
                                    });
                                  },
                                  value: PrimaryContact.mobile,
                                ),
                                Text(
                                  localize("primary"),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  groupValue: _primaryContact,
                                  onChanged: (value) {
                                    setState(() {
                                      _primaryContact = value;
                                    });
                                  },
                                  value: PrimaryContact.office,
                                ),
                                Text(
                                  localize("primary"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SignUpTextField(
                    hint: localize("First & Last Name"),
                  ),
                  SignUpTextField(
                    hint: localize("Position"),
                  ),
                  Text(
                    localize("About Us *"),
                  ),
                  SignUpTextField(
                    hint: localize(
                        "Description of services and what makes your company exceptional (maximum 300 characters)"),
                    minLines: 4,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                FlatButton(
                  onPressed: () {},
                  child: Text(
                    localize("Back").toUpperCase(),
                  ),
                ),
                const SizedBox(width: 16.0),
                FlatButton(
                  onPressed: _onNextPressed,
                  child: Text(
                    localize("Preview").toUpperCase(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
