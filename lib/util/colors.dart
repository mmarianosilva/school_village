import 'dart:ui';

class SVColors {
  static const talkAroundAccent = const Color.fromRGBO(50, 51, 57, 1.0);
  static const talkAroundBlue = const Color.fromRGBO(0, 122, 255, 1.0);
  static const incidentReport = const Color.fromRGBO(89, 193, 234, 1.0);
  static const incidentReportRed = const Color.fromRGBO(234, 51, 54, 1);
  static final incidentReportGray = colorFromHex('#4a4a4a');

  static colorFromHex(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (!hex.startsWith('FF')) {
      hex = 'FF$hex';
    }
    return Color(hexToInt(hex));
  }

  static hexToInt(hex) {
    int val = 0;
    int len = hex.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = hex.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw FormatException("Invalid hexadecimal value");
      }
    }
    return val;
  }
}
