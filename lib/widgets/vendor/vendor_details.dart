import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorDetailsScreen extends StatefulWidget {
  const VendorDetailsScreen(this.category, this.vendor);

  final VendorCategory category;
  final Vendor vendor;

  @override
  _VendorDetailsScreenState createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(localize('Vendor Details'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xff262b2b),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 80.0,
                  ),
                  child: widget.vendor.coverPhotoUrl?.isNotEmpty ?? false ? Image.network(widget.vendor.coverPhotoUrl) : const Icon(Icons.all_inclusive),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildRatingWidget(context, 4, 11),
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
                  "Service: ${widget.category.name}",
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
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined),
                        const SizedBox(width: 16.0),
                        SelectableText(
                          widget.vendor.contactPhone ?? "",
                          style: TextStyle(
                            color: Color(0xff10a2c7),
                            fontSize: 16.0,
                            letterSpacing: 0.7,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                        SelectableText(
                          widget.vendor.contactPhone ?? "",
                          style: TextStyle(
                            color: Color(0xff10a2c7),
                            fontSize: 16.0,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.mail),
                        const SizedBox(width: 16.0),
                        SelectableText(
                          widget.vendor.email ?? "",
                          textScaleFactor: (widget.vendor.email?.length ?? 0.0) > 30 ? 0.8 : 1.0,
                          style: TextStyle(
                            color: Color(0xff10a2c7),
                            fontSize: 16.0,
                            letterSpacing: 0.7,
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
            padding: const EdgeInsets.only(left: 24.0, top: 8.0, right: 24.0),
            child: Text(
              "About Us",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Text(
                  widget.vendor.about ?? "",
                  maxLines: null,
                ),
              ),
            ),
          ),
        ],
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
