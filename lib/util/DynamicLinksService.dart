import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:package_info/package_info.dart';
import 'package:school_village/util/constants.dart';

class DynamicLinksService {
  static Future<String> createDynamicLink(String parameter,String domain) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(packageInfo.packageName);

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: domain,
      link: Uri.parse('$parameter'),
    );

    // final Uri dynamicUrl = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    print("${shortUrl.toString()}");
    return shortUrl.toString();
  }

}