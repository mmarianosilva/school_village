import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/widgets/vendor/vendor_details.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorList extends StatefulWidget {
  const VendorList(this.category);

  final VendorCategory category;

  @override
  _VendorListState createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
  final List<Vendor> list = <Vendor>[];

  @override
  void initState() {
    super.initState();
    UserHelper.getSelectedSchoolID().then((schoolId) {
      FirebaseFirestore.instance
          .collection('vendors')
          .where('categories', arrayContains: widget.category.id)
          .where('school', isEqualTo: FirebaseFirestore.instance.doc(schoolId))
          .get()
          .then((snapshot) {
        list.addAll(
            snapshot.docs.map((document) => Vendor.fromDocument(document)).where((vendor) => !(vendor.deleted ?? false)));
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(
          localize('${widget.category.name}'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.29,
          ),
        ),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemBuilder: _buildVendorListItem,
        itemCount: list.length,
      ),
    );
  }

  Widget _buildVendorListItem(BuildContext context, int index) {
    final item = list[index];
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VendorDetailsScreen(widget.category, item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0x979797)),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Color(0x88999999),
              blurRadius: 2.0,
              offset: const Offset(0.0, 1.0),
            ),
          ],
        ),
        margin: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const SizedBox(width: 8.0),
                  item.coverPhotoUrl?.isNotEmpty ?? false
                      ? Image.network(
                          item.coverPhotoUrl,
                          fit: BoxFit.cover,
                          height: 64.0,
                          width: 128.0,
                        )
                      : const Icon(Icons.all_inclusive),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item.name}"),
                        _buildRatingWidget(context, 4, 11),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 8.0),
                  Image.network(
                    widget.category.icon,
                    fit: BoxFit.contain,
                    width: 32.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text("${widget.category.name}"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.about,
                  maxLines: 2,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MaterialButton(
                      onPressed: () {
                        showContactDialog(context, item.name, item.contactPhone ?? item.businessPhone);
                      },
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          const Icon(Icons.call, color: Colors.lightBlue),
                          const SizedBox(width: 4.0),
                          Text(
                            "Call",
                            style: TextStyle(
                              fontSize: 14.0,
                              letterSpacing: 0.44,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MaterialButton(
                      onPressed: () async {
                        final uri = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(item.address)}";
                        // if (await canLaunch(uri)) {
                          launch(uri);
                        // }
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.subdirectory_arrow_right,
                              color: Colors.lightBlue),
                          const SizedBox(width: 4.0),
                          Text(
                            "Directions",
                            style: TextStyle(
                              fontSize: 14.0,
                              letterSpacing: 0.44,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                VendorDetailsScreen(widget.category, item),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          const Icon(Icons.more_vert, color: Colors.lightBlue),
                          const SizedBox(width: 4.0),
                          Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 14.0,
                              letterSpacing: 0.44,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingWidget(BuildContext context, double average, int total) {
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
