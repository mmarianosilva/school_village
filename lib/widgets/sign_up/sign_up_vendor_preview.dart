import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/widgets/home/home.dart';
import 'package:school_village/widgets/sign_up/sign_up_vendor_billing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class SignUpVendorPreview extends StatefulWidget {
  const SignUpVendorPreview({
    Key key,
    this.vendor,
    this.categories,
    this.coverPhoto,
  }) : super(key: key);

  final Vendor vendor;
  final List<VendorCategory> categories;
  final File coverPhoto;

  @override
  _SignUpVendorPreviewState createState() => _SignUpVendorPreviewState();
}

class _SignUpVendorPreviewState extends State<SignUpVendorPreview> {
  void _onNextPressed() async {
    var photoUrl = "";
    if (widget.coverPhoto != null) {
      final id = Uuid().v4();
      final uploadTask = await FirebaseStorage.instance
          .ref()
          .child("vendors/$id")
          .putFile(widget.coverPhoto);
      photoUrl = await uploadTask.ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection("vendors")
        .doc()
        .set(<String, dynamic>{
      "name": widget.vendor.name,
      "url": widget.vendor.url,
      "email": widget.vendor.email,
      "contact_name": widget.vendor.contactName,
      "contact_phone": widget.vendor.contactPhone,
      "contact_title": widget.vendor.contactTitle,
      "business_phone": widget.vendor.businessPhone,
      "address": widget.vendor.address,
      "about": widget.vendor.about,
      "categories": widget.categories.map((item) => item.id).toList(),
      "cover_url": photoUrl,
      "owners": [
        FirebaseFirestore.instance
            .doc("users/${(await FirebaseAuth.instance.currentUser()).uid}")
      ],
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpVendorBilling(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(
          localize('Vendor Details'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, letterSpacing: 1.29),
        ),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Color(0xff262b2b),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          constraints: BoxConstraints(
                            maxHeight: 80.0,
                          ),
                          child: widget.coverPhoto != null
                              ? Image.file(widget.coverPhoto)
                              : const Icon(Icons.all_inclusive),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              _buildRatingWidget(
                                context,
                                0.0,
                                0,
                              ),
                              const Spacer(),
                              Text(
                                "Write a review",
                                style: TextStyle(color: Colors.lightBlue),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Color(0xffd8d8d8),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.vendor.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Image.asset("assets/images/website_www_2.png",
                                height: 24.0),
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () async {
                                if (await canLaunch(widget.vendor.url)) {
                                  await launch(widget.vendor.url);
                                }
                              },
                              child: Text(
                                "website",
                                style: TextStyle(color: Colors.lightBlue),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Service: ${widget.categories.map((item) => item.name).reduce((current, next) => "$current, $next")}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      final uri =
                                          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(widget.vendor.address)}";
                                      launch(uri);
                                    },
                                    child: Text(
                                      widget.vendor.address ?? "",
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Color(0xff10a2c7),
                                        fontSize: 16.0,
                                        letterSpacing: 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const Icon(Icons.business_outlined),
                                const SizedBox(width: 16.0),
                                GestureDetector(
                                  onTap: () {
                                    if (widget
                                            .vendor.businessPhone?.isNotEmpty ??
                                        false) {
                                      showContactDialog(
                                          context,
                                          widget.vendor.name,
                                          widget.vendor.businessPhone);
                                    }
                                  },
                                  child: Text(
                                    widget.vendor.businessPhone ?? "",
                                    style: TextStyle(
                                      color: Color(0xff10a2c7),
                                      fontSize: 16.0,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.perm_contact_cal),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.vendor.contactName ?? "",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Color(0xff323339),
                                          fontSize: 16.0,
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                      Text(
                                        widget.vendor.contactTitle ?? "",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Color(0xff323339),
                                          fontSize: 16.0,
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const Icon(Icons.phone_android),
                                const SizedBox(width: 16.0),
                                GestureDetector(
                                  onTap: () {
                                    if (widget
                                            .vendor.contactPhone?.isNotEmpty ??
                                        false) {
                                      showContactDialog(
                                          context,
                                          widget.vendor.contactName,
                                          widget.vendor.contactPhone);
                                    }
                                  },
                                  child: Text(
                                    widget.vendor.contactPhone ?? "",
                                    style: TextStyle(
                                      color: Color(0xff10a2c7),
                                      fontSize: 16.0,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const Icon(Icons.mail),
                                const SizedBox(width: 16.0),
                                GestureDetector(
                                  onTap: () {
                                    launch("mailto:${widget.vendor.email}");
                                  },
                                  child: Text(
                                    widget.vendor.email ?? "",
                                    textScaleFactor:
                                        (widget.vendor.email?.length ?? 0.0) >
                                                30
                                            ? 0.8
                                            : 1.0,
                                    style: TextStyle(
                                      color: Color(0xff10a2c7),
                                      fontSize: 16.0,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, top: 8.0, right: 24.0),
                    child: Text(
                      "About Us",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.vendor.about ?? "",
                      maxLines: null,
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
                    onPressed: () {},
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

  Widget _buildRatingWidget(BuildContext context, double average, int total) {
    if (average == null || total == null) {
      return const SizedBox();
    }
    final List<Widget> full = [];
    final List<Widget> outlined = [];
    for (int i = 0; i < 5; i++) {
      if (i < average) {
        full.add(Image.asset(
          "assets/images/star_4_selected.png",
          height: 24.0,
          color: Color(0xfffbdf68),
          colorBlendMode: BlendMode.srcATop,
        ));
      } else {
        outlined.add(Image.asset(
          "assets/images/star_4_unselected.png",
          height: 24.0,
        ));
      }
    }
    return Row(
      children: [
        ...full,
        ...outlined,
        Text(
          "$total ratings",
          style: TextStyle(
            color: Color(0xfff8f8f8),
            fontSize: 11.0,
            letterSpacing: 0.43,
          ),
        ),
      ],
    );
  }
}
