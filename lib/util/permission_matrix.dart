const String maintenance = "maintenance";
const String vendor = "vendor";
const String boater = "boater";
const String admin = "admin";
const String security = "security";

const String staff = "staff";
const String district = "district";
const String superadmin = "superadmin";
const String pdFireEms = "pd_fire_ems";

class PermissionMatrix {

  static const _talkAroundStudents = [staff, admin];
  static const _talkAroundStaff = [staff,  admin, security,  vendor, boater, maintenance];
  static const _talkAroundAdmin = [staff,  admin, security,  vendor, boater, maintenance, district, superadmin];
  static const _talkAroundSecurity = [staff,  admin, security,  district, superadmin];
  static const _talkAroundDistrict = [staff,  admin, security,  vendor, boater, maintenance, district, superadmin];
  static const _talkAroundPdFireEms = [admin, security,  district, superadmin];

  static List<String> getTalkAroundPermissions(String role) {
    switch (role) {
      case maintenance:
      case vendor:
      case boater:
        return _talkAroundStudents;
      case admin:
        return _talkAroundAdmin;
      case security:
        return _talkAroundSecurity;
      case staff:
        return _talkAroundStaff;
      case district:
      case superadmin:
        return _talkAroundDistrict;
      case pdFireEms:
        return _talkAroundPdFireEms;
      default:
        return [];
    }
  }
}