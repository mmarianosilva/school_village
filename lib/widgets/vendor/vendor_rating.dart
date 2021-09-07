import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/rating.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/util/localizations/localization.dart';

class VendorRating extends StatefulWidget {
  const VendorRating(this.vendor, {Key key}) : super(key: key);

  final Vendor vendor;

  @override
  _VendorRatingState createState() => _VendorRatingState();
}

class _VendorRatingState extends State<VendorRating> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Rating _selectedRating;
  File _ratingPhoto;
  File _userPhoto;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((value) async{
      final userId = value.uid;
      final ratingDocument = await FirebaseFirestore.instance
          .doc("vendors/${widget.vendor.id}/ratings/${userId}")
          .get();
      if (ratingDocument.exists) {
        _selectedRating = Rating.fromDocument(ratingDocument);
        _displayNameController.text = _selectedRating.userDisplayName ?? "";
        _titleController.text = _selectedRating.title ?? "";
        _descriptionController.text = _selectedRating.description ?? "";
      } else {
        _selectedRating = Rating(id: userId);
      }
      setState(() {
        _isLoading = false;
      });
    });

  }

  Future<void> _onSubmitPressed() async {
    if (_selectedRating.stars == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final userId = (await FirebaseAuth.instance.currentUser).uid;
    if (_ratingPhoto != null) {
      final id = "$userId-${DateTime.now().millisecondsSinceEpoch}";
      final storageRef = FirebaseStorage.instance.ref("vendors/ratings/$id");
      await storageRef.putFile(_ratingPhoto);
      _selectedRating = _selectedRating.copyWith(
          ratingPhoto: await storageRef.getDownloadURL());
    }
    if (_userPhoto != null) {
      final id = "$userId-${DateTime.now().millisecondsSinceEpoch}";
      final storageRef = FirebaseStorage.instance.ref("vendors/ratings/$id");
      await storageRef.putFile(_userPhoto);
      _selectedRating = _selectedRating.copyWith(
          userPhoto: await storageRef.getDownloadURL());
    }
    _selectedRating = _selectedRating.copyWith(title: _titleController.text);
    _selectedRating =
        _selectedRating.copyWith(description: _descriptionController.text);
    _selectedRating =
        _selectedRating.copyWith(userDisplayName: _displayNameController.text);
    final document = FirebaseFirestore.instance
        .doc("vendors/${widget.vendor.id}/ratings/${userId}");
    await document.set(_selectedRating.map, SetOptions(merge: true));
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(localize('Create Review'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Color(0xff262b2b),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        localize("Vendor: ${widget.vendor.name}"),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        localize("Overall Satisfaction"),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          letterSpacing: 0.89,
                        ),
                      ),
                      _buildTappableRatingWidget(),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 32.0),
                    Text(
                      localize("Add a title: "),
                      style: TextStyle(
                        color: Color(0xff323339),
                        fontSize: 16.0,
                        letterSpacing: 0.27,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: localize("What\'s important to know?"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32.0),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Color(0xff323339),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.27,
                      ),
                      text: localize(
                          "Share your experience with other customers and write a review"),
                      children: [
                        TextSpan(
                          style: TextStyle(
                            color: Color(0xff323339),
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.27,
                          ),
                          text: localize(" (optional) "),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                        hintText: localize(
                            "What stood out to you? Share your likes and dislikes... (300 character max)")),
                    minLines: 4,
                    maxLines: 4,
                    maxLength: 300,
                  ),
                ),
                Divider(
                  color: Color(0xff14c3ef),
                ),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Color(0xff323339),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.27,
                    ),
                    text: localize("Add a photo or video"),
                    children: [
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xff323339),
                          fontSize: 16.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.27,
                        ),
                        text: localize(" (optional) "),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    localize(
                        "Customers find images and videos more helpful than text alone"),
                    style: TextStyle(
                      color: Color(0xff323339),
                      fontSize: 14.0,
                      letterSpacing: 0.27,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    final selectedFile = await _imagePicker.getImage(source: ImageSource.gallery);
                    if (selectedFile.path != null) {
                      setState(() {
                        _ratingPhoto = File(selectedFile.path);
                      });
                    }
                  },
                  child: _ratingPhoto != null
                      ? Image.file(_ratingPhoto)
                      : const Icon(Icons.add_a_photo_outlined),
                ),
                Divider(
                  color: Color(0xff14c3ef),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text.rich(
                    TextSpan(
                      text: localize(
                          "Choose your public name and/or photo for your review"),
                      style: TextStyle(
                        color: Color(0xff323339),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.27,
                      ),
                      children: [
                        TextSpan(
                          style: TextStyle(
                            color: Color(0xff323339),
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.27,
                          ),
                          text: localize(" (optional) "),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 32.0),
                    FlatButton(
                      onPressed: () async {
                        final selectedFile = await _imagePicker.getImage(source: ImageSource.gallery);
                        if (selectedFile.path != null) {
                          setState(() {
                            _userPhoto = File(selectedFile.path);
                          });
                        }
                      },
                      child: _userPhoto != null
                          ? Image.file(_userPhoto)
                          : Icon(Icons.person_pin_rounded),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          hintText: localize("Display name"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32.0),
                  ],
                ),
                FlatButton(
                  onPressed: _onSubmitPressed,
                  child: Text(
                    localize("Submit"),
                    style: TextStyle(
                      color: Color(0xff14c3ef),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? Container(
                  color: Colors.black38,
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _buildTappableRatingWidget() {
    int rating = _selectedRating?.stars ?? 0;
    final List<Widget> full = [];
    final List<Widget> outlined = [];
    for (int i = 0; i < 5; i++) {
      if (i + 1 <= rating) {
        full.add(GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = _selectedRating.copyWith(stars: i + 1);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/images/star_4_selected.png",
              height: 24.0,
              color: Color(0xfffbdf68),
              colorBlendMode: BlendMode.srcATop,
            ),
          ),
        ));
      } else {
        outlined.add(GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = _selectedRating.copyWith(stars: i + 1);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/images/star_4_unselected.png",
              height: 24.0,
            ),
          ),
        ));
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Spacer(),
        ...full,
        ...outlined,
        const Spacer(),
      ],
    );
  }
}
