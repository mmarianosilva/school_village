import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/rating.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/vendor/vendor_rating.dart';

class VendorReviews extends StatefulWidget {
  const VendorReviews({Key key, this.vendor}) : super(key: key);

  final Vendor vendor;

  @override
  _VendorReviewsState createState() => _VendorReviewsState();
}

class _VendorReviewsState extends State<VendorReviews> {
  int _numberOfReviews;
  double _calculatedRating;
  List<Rating> _reviews;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("vendors/${widget.vendor.id}/ratings")
        .get()
        .then((value) {
      final ratings = value.docs;
      _reviews = value.docs.map((doc) => Rating.fromDocument(doc)).toList();
      _numberOfReviews = ratings.length;
      var totalRating = 0.0;
      for (final rating in ratings) {
        totalRating = totalRating + rating.data()["stars"];
      }
      setState(() {
        _calculatedRating = totalRating / _numberOfReviews;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(localize('Vendor Reviews'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xff262b2b),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8.0),
                Text(
                  localize("Vendor: ${widget.vendor.name}"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  localize("Average Rating by Customers"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    letterSpacing: 0.89,
                  ),
                ),
                const SizedBox(height: 8.0),
                _buildAverageRatingWidget(),
                const SizedBox(height: 14.0),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VendorRating(widget.vendor)));
                  },
                  child: Text(
                    localize('Write a review'),
                    style: TextStyle(
                      color: Color(0xff14c3ef),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.98,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
          Text(
            localize("Customer Reviews"),
            style: TextStyle(
              color: Color(0xff323339),
              fontSize: 16.0,
              letterSpacing: 0.89,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: _buildReview,
              itemCount: _reviews?.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(BuildContext context, int index) {
    final item = _reviews[index];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            color: Color(0xff979797),
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                if (item.userPhoto?.isNotEmpty ?? false)
                  Image.network(
                    item.userPhoto,
                    width: 60.0,
                  )
                else
                  Image.asset(
                    "assets/images/avatar_blank.png",
                    width: 60.0,
                  ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(item.userDisplayName ?? 'Customer'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildRatingWidget(item),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    item.title ?? '',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                if (item.ratingPhoto?.isNotEmpty ?? false) ...{
                  Image.network(
                    item.ratingPhoto,
                    width: 60.0,
                  ),
                  const SizedBox(width: 8.0),
                }
                else
                  const SizedBox(),
                Expanded(
                  child: Text(
                    item.description,
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Color(0xff979797),
            height: 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildAverageRatingWidget() {
    if (_calculatedRating == null || _numberOfReviews == null) {
      return const SizedBox();
    }
    final List<Widget> full = [];
    final List<Widget> outlined = [];
    for (int i = 0; i < 5; i++) {
      if (i < _calculatedRating) {
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
        const Spacer(),
        ...full,
        ...outlined,
        const Spacer(),
      ],
    );
  }

  Widget _buildRatingWidget(Rating rating) {
    final List<Widget> full = [];
    final List<Widget> outlined = [];
    for (int i = 0; i < 5; i++) {
      if (i < rating.stars) {
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
      ],
    );
  }
}
