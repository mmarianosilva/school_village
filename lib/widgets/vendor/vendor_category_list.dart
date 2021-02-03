import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/vendor/vendor_list.dart';

class VendorCategoryList extends StatefulWidget {
  @override
  _VendorCategoryListState createState() => _VendorCategoryListState();
}

class _VendorCategoryListState extends State<VendorCategoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(localize('Marine Services'),
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
            builder: (context) => VendorList(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Image.network(
                "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Greater_coat_of_arms_of_the_United_States.svg/220px-Greater_coat_of_arms_of_the_United_States.svg.png",
                fit: BoxFit.contain,
                width: 48.0),
            const SizedBox(width: 16.0),
            Text("Service Provider $index"),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 24.0),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}
