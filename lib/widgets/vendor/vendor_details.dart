import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';

class VendorDetailsScreen extends StatefulWidget {
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
                  child: Image.network(
                      "https://www.lipsum.com/images/banners/grey_234x60.gif"),
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
                      "Parker's Lighthouse",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.link),
                    const SizedBox(width: 8.0),
                    Text(
                      "website",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  ],
                ),
                Text(
                  "Service: Restaurant",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
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
                            "435 Shoreline Village Drive, Long Beach, CA 90802",
                            maxLines: 2,
                            style: TextStyle(
                              color: Color(0xff10a2c7),
                              fontSize: 18.0,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined),
                        const SizedBox(width: 16.0),
                        Text(
                          "+1 (562) 432-6500",
                          style: TextStyle(
                            color: Color(0xff10a2c7),
                            fontSize: 18.0,
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
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.perm_contact_cal),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Perry Parker",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Color(0xff323339),
                                  fontSize: 18.0,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              Text(
                                "Owner Operator",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Color(0xff323339),
                                  fontSize: 18.0,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone_android),
                        const SizedBox(width: 16.0),
                        Text(
                          "+1 (222) 222-2222",
                          style: TextStyle(
                            color: Color(0xff10a2c7),
                            fontSize: 18.0,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.mail),
                        const SizedBox(width: 16.0),
                        Text(
                          "pjp@parkerslighthouse.com",
                          style: TextStyle(
                            color: Color(0xff10a2c7),
                            fontSize: 18.0,
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "About Us",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Text(
                  "We outfit, educate, and inspire boaters! West Marine opened the biggest boating store in the U.S. in Fort Lauderdale, Florida in 2011. This 50,000 sq. ft. store, not only had an expanded selection of core boating products, but it offered a large selection of footwear, casual and technical apparel for those who enjoy being out and on the water.",
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
        full.add(
          Icon(Icons.auto_awesome, color: Colors.amber),
        );
      } else {
        outlined.add(Icon(Icons.auto_awesome, color: Colors.white10));
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
