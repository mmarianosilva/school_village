import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/sign_up/sign_up_text_field.dart';
import 'package:school_village/widgets/sign_up/sign_up_vendor_preview.dart';

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
  const SignUpVendor({Key key, this.userData}) : super(key: key);

  @override
  _SignUpVendorState createState() => _SignUpVendorState();

  final Map<String, dynamic> userData;
}

class _SignUpVendorState extends State<SignUpVendor> {
  File _selectedPhoto;
  PrimaryContact _primaryContact = PrimaryContact.mobile;
  String _error = "";
  bool _isLoading = false;

  final _categories = List<_SelectedCategory>();
  final _companyWebsiteController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _officePhoneController = TextEditingController();
  final _primaryContactNameController = TextEditingController();
  final _primaryContactPositionController = TextEditingController();
  final _aboutUsController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _verifyPhone() {
    if (_primaryContact == PrimaryContact.mobile) {
      return _mobilePhoneController.text
              .replaceAll("(", "")
              .replaceAll(")", "")
              .replaceAll(" ", "")
              .replaceAll("-", "")
              .length ==
          10;
    }
    return _officePhoneController.text
            .replaceAll("(", "")
            .replaceAll(")", "")
            .replaceAll(" ", "")
            .replaceAll("-", "")
            .length ==
        10;
  }
  @override
  void dispose() {
    _officePhoneController.dispose();
    _mobilePhoneController.dispose();
    super.dispose();
  }
  bool _verifyEmail() {
    return Constants.emailRegEx.hasMatch(_companyEmailController.text);
  }

  bool _verifyAboutUs() {
    return !_aboutUsController.text.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _primaryContactNameController.text =
        "${widget.userData["firstName"] ?? ""} ${widget.userData["lastName"] ?? ""}";
    _mobilePhoneController.text =
        "${_preMaskString(widget.userData["phone"]) ?? ""}";
    _companyEmailController.text = "${widget.userData["email"] ?? ""}";
    _getVendorCategories();
  }

  String _preMaskString(String text) {
    String formattedPhoneNumber = "(" +
        text.substring(0, 3) +
        ")" +
        text.substring(3, 6) +
        "-" +
        text.substring(6, text.length);
    return formattedPhoneNumber;
  }

  void _getVendorCategories() {
    FirebaseFirestore.instance
        .collection("services")
        .orderBy('name')
        .get()
        .then((snapshot) {
      _categories.clear();
      _categories.addAll(snapshot.docs.map((doc) =>
          _SelectedCategory(VendorCategory.fromDocument(document: doc))));
    });
  }

  void _onNextPressed() async {
    setState(() {
      _isLoading = true;
    });
    if (!_verifyPhone()) {
      setState(() {
        _error = "Primary phone number must have 10 digits";
        _isLoading = false;
      });
      return;
    }
    if (!_verifyEmail()) {
      setState(() {
        _error = "Email must be in the correct format";
        _isLoading = false;
      });
      return;
    }
    if (!_verifyAboutUs()) {
      setState(() {
        _error = "Please fill the information about your company services";
        _isLoading = false;
      });
      return;
    }
    if (_categories.where((item) => item.selected).isEmpty) {
      setState(() {
        _error = "Please select at least one service category";
        _isLoading = false;
      });
      return;
    }
    final vendor = Vendor(
      name: _companyNameController.text,
      url: _companyWebsiteController.text,
      email: _companyEmailController.text,
      contactName: _primaryContactNameController.text,
      contactPhone: _mobilePhoneController.text,
      contactTitle: _primaryContactPositionController.text,
      businessPhone: _officePhoneController.text,
      address:
          "${_addressController.text}, ${_cityController.text}, ${_stateController.text}, ${_zipCodeController.text}",
      about: _aboutUsController.text,
    );
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpVendorPreview(
          vendor: vendor,
          categories: _categories
              .where((item) => item.selected)
              .map((item) => item.category)
              .toList(),
          coverPhoto: _selectedPhoto,
        ),
      ),
    );
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: Color(0xff023280),
                        padding: const EdgeInsets.all(8.0),
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
                      Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              localize(
                                  "Input and submit the info below to preview your listing"),
                              style: TextStyle(
                                color: Color(0xff323339),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                height: 23.0 / 16.0,
                                letterSpacing: 1.16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              localize("Fields marked * or RED are Required"),
                              style: TextStyle(
                                color: Color(0xff810317),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 80.0,
                              child: _selectedPhoto != null
                                  ? Image.file(_selectedPhoto)
                                  : GestureDetector(
                                      onTap: () async {
                                        final file =
                                            await _imagePicker.getImage(
                                                source: ImageSource.gallery);
                                        if (file != null) {
                                          setState(() {
                                            _selectedPhoto = File(file.path);
                                          });
                                        }
                                      },
                                      child: Container(
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
                            ),
                            const SizedBox(width: 24.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    localize("* Service Type"),
                                    style: TextStyle(
                                        color: Color(0xff810317),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0),
                                  ),
                                  MaterialButton(
                                    color: Color(0xffcbc9c9),
                                    onPressed: () async {
                                      await showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder:
                                                  (context, stateBuilder) =>
                                                      Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Material(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            localize(
                                                                "- Select Your Services -"),
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff023280),
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing:
                                                                  0.62,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          color:
                                                              Color(0xfff7f7f9),
                                                          constraints:
                                                              BoxConstraints(
                                                            maxHeight: 256.0,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                child: ListView
                                                                    .builder(
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    final item =
                                                                        _categories[
                                                                            index];
                                                                    return CheckboxListTile(
                                                                      value: _categories[
                                                                              index]
                                                                          .selected,
                                                                      onChanged:
                                                                          (value) {
                                                                        stateBuilder(
                                                                            () {
                                                                          _categories[index].selected =
                                                                              value;
                                                                        });
                                                                      },
                                                                      title: Text(
                                                                          item.category.name ??
                                                                              ""),
                                                                    );
                                                                  },
                                                                  itemCount:
                                                                      _categories
                                                                          .length,
                                                                ),
                                                              ),
                                                              MaterialButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  localize(
                                                                          "Confirm")
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
                                          : localize("Select All That Apply ▼"),
                                      style: TextStyle(
                                        color: Color(0xff810317),
                                        fontSize: 14.0,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SignUpTextField(
                          controller: _companyWebsiteController,
                          hint: localize("Company Website"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SignUpTextField(
                          controller: _companyNameController,
                          hint: localize("Company Name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SignUpTextField(
                          controller: _companyEmailController,
                          hint: localize("Company Email *"),
                        ),
                      ),
                      Container(
                        color: Color(0xffd7d3d3),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              localize("Optional"),
                            ),
                            SignUpTextField(
                              controller: _addressController,
                              hint: localize("Address"),
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
                                      maxLength: 5,
                                      textInputType: TextInputType.number,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8.0),
                        child: Text(
                          localize(
                              "You must input and select the primary phone number"),
                          maxLines: 2,
                          style: TextStyle(
                            color: Color(0xff810317),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.43,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SignUpTextField(
                                    controller: _mobilePhoneController,
                                    hint: localize("Phone-Mobile"),
                                    textInputType: TextInputType.phone,
                                    inputFormatter:
                                        MaskedInputFormatter("(###)###-####"),
                                  ),
                                  const SizedBox(height: 8.0),
                                  SignUpTextField(
                                    controller: _officePhoneController,
                                    hint: localize("Phone-Office"),
                                    textInputType: TextInputType.phone,
                                    inputFormatter:
                                        MaskedInputFormatter("(###)###-####"),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SignUpTextField(
                          controller: _primaryContactNameController,
                          hint: localize("First & Last Name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SignUpTextField(
                          controller: _primaryContactPositionController,
                          hint: localize("Position"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          localize("About Us *"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SignUpTextField(
                          controller: _aboutUsController,
                          hint: localize(
                              "Description of services and what makes your company exceptional (maximum 300 characters)"),
                          minLines: 4,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error ?? "",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      color: Color(0xff48484a),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                          localize("Preview").toUpperCase(),
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
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : const SizedBox(),
        ],
      ),
    );
  }
}
