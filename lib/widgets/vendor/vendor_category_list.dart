import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/vendor/vendor_list.dart';

class VendorCategoryList extends StatefulWidget {
  @override
  _VendorCategoryListState createState() => _VendorCategoryListState();
}

class _VendorCategoryListState extends State<VendorCategoryList> {
  final List<VendorCategory> categories = <VendorCategory>[];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('services')
        .where('enabled', isEqualTo: true)
        .get()
        .then((list) {
      categories.addAll(
          list.docs.map((doc) => VendorCategory.fromDocument(document: doc)));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: BackButton(color: Colors.grey.shade800),
        title: Text(
          localize('Services'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, letterSpacing: 1.29),
        ),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
      ),
      body: ListView.builder(
        itemBuilder: _buildVendorListItem,
        itemCount: categories.length,
      ),
    );
  }

  Widget _buildVendorListItem(BuildContext context, int index) {
    final item = categories[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VendorList(item),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Image.network(
              item.icon,
              fit: BoxFit.contain,
              width: 48.0,
            ),
            const SizedBox(width: 16.0),
            Text("${item.name}"),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 24.0),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}
