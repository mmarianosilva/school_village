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
  static const _talkAroundMaintenance = [admin, security, maintenance];
  static const _talkAroundVendors = [vendor, admin];
  static const _talkAroundBoaters = [boater,vendor, admin];
  static const _talkAroundStaff = [staff,  admin, security,  vendor, boater, maintenance];
  static const _talkAroundAdmin = [staff,  admin, security,  vendor, boater, maintenance, district, superadmin];
  static const _talkAroundSecurity = [  admin, security,  district, superadmin];
  static const _talkAroundPdFireEms = [admin, security,  district, superadmin];


  static List<String> getTalkAroundPermissions(String role) {
    switch (role) {
      case maintenance:
        return _talkAroundMaintenance;
      case vendor:
        return _talkAroundVendors;
      case boater:
        return _talkAroundBoaters;
      case security:
        return _talkAroundSecurity;
      case staff:
        return _talkAroundStaff;
      case district:
      case superadmin:
      case admin:
        return _talkAroundAdmin;
      case pdFireEms:
        return _talkAroundPdFireEms;
      default:
        return [];
    }
  }
  static List<String> getTalkAroundGroupPermissions(String role) {
    switch (role) {
      case maintenance:
        return[maintenance,admin];
      case vendor:
        return [];
      case boater:
        return [];
      case security:
        return[security,admin,district];
      case staff:
        return _talkAroundStaff;
      case district:
      case superadmin:
      case admin:
        return _talkAroundAdmin;
      case pdFireEms:
        return _talkAroundPdFireEms;
      default:
        return [];
    }
  }
}