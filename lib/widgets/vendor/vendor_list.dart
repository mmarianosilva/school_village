import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/vendor/vendor_details.dart';

class VendorList extends StatefulWidget {
  @override
  _VendorListState createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(localize('Marine Services - Painting'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: ListView.builder(
        itemBuilder: _buildVendorListItem,
        itemCount: 2,
      ),
    );
  }

  Widget _buildVendorListItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VendorDetailsScreen(),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 192.0,
        ),
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
                  Image.network(
                      "https://www.lipsum.com/images/banners/grey_234x60.gif",
                      fit: BoxFit.fitWidth,
                      width: 128.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Louisiana Charlie's"),
                        _buildRatingWidget(context, 4, 11),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 8.0),
                  const Icon(Icons.anchor),
                  Text("Painting"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  maxLines: 2,
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MaterialButton(
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
        full.add(
          Icon(Icons.auto_awesome, color: Colors.amber),
        );
      } else {
        outlined.add(Icon(Icons.auto_awesome, color: Colors.black12));
      }
    }
    return Row(
      children: [
        ...full,
        ...outlined,
        Text(
          "$total ratings",
          style: TextStyle(
            color: Color(0xff323339),
            fontSize: 11.0,
            letterSpacing: 0.43,
          ),
        ),
      ],
    );
  }
}
