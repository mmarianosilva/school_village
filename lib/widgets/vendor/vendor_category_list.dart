import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/vendor_category.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/vendor/vendor_list.dart';

class VendorCategoryList extends StatefulWidget {
  @override
  _VendorCategoryListState createState() => _VendorCategoryListState();
}

class _VendorCategoryListState extends State<VendorCategoryList> {
  final List<VendorCategory> categories = <VendorCategory>[];
  bool isLoading = true;

  Future<DocumentReference> fetchMarinaDistrict() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    final schoolDocument = await FirebaseFirestore.instance.doc(schoolId).get();
    final district = schoolDocument.data()["district"] as DocumentReference;
    fetchVendorsInDistrict(district);
    return district;
  }

  void fetchVendorsInDistrict(DocumentReference localDistrict) async {
    // So here's the logic
    // First we find vendors that are listed in this district
    //Then we add thir listed categories in a set
    //Now we filter those categories to remove categories without vendorCount or if they're deleted
    var uniqueCategories = <dynamic>{};
    final vendorsList = (await FirebaseFirestore.instance
            .collection('vendors')
            .where('districts', arrayContainsAny: [localDistrict]).get())
        .docs;
    if (vendorsList.isNotEmpty) {
      vendorsList
          .removeWhere((element) => (element.data()['deleted'] ?? false));
      vendorsList.forEach((element) {
        uniqueCategories.addAll(element.data()['categories'] as List<dynamic>);
      });
      for (final categoryId in uniqueCategories) {
        final vendorCat = await FirebaseFirestore.instance
            .collection('services')
            .doc(categoryId)
            .get();
        categories.add(VendorCategory.fromDocument(document: vendorCat));
      }
      categories.removeWhere((category) {
        return (category.deleted ?? false) || (category.vendorsCount == 0);
      });
      categories.sort((item1, item2) => item1.name.compareTo(item2.name));
      final indexOfSpecialOffers =
          categories.indexWhere((item) => item.name == "SPECIAL OFFERS");
      if (indexOfSpecialOffers != -1) {
        final specialOffer = categories[indexOfSpecialOffers];
        categories.removeAt(indexOfSpecialOffers);
        categories.insert(0, specialOffer);
      }
      setState(() {
        isLoading = false;
      });

      //print("Length 2 ${vendorsList.length}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMarinaDistrict();
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
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
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                child: Center(
                  child: Image.network(
                    item.icon,
                    fit: BoxFit.contain,
                    width: 48.0,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  localize('${item.name}'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 14.0, color: SVColors.dashboardItemFontColor),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          )
        ],
      ),
      // child: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      //   child: Row(
      //     children: [
      //       Image.network(
      //         item.icon,
      //         fit: BoxFit.contain,
      //         width: 48.0,
      //       ),
      //       const SizedBox(width: 16.0),
      //       Text("${item.name}"),
      //       const Spacer(),
      //       const Icon(Icons.arrow_forward_ios, size: 24.0),
      //       const SizedBox(width: 8.0),
      //     ],
      //   ),
      // ),
    );
  }
}
