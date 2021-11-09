const String family = "family";
const String student = "student";
const String admin = "admin";
const String security = "security";
const String staff = "staff";
const String district = "district";
const String pdFireEms = "pd-fire-ems";

class PermissionMatrix {
  static const _talkAroundFamily = [staff, admin];
  static const _talkAroundStudents = [staff, admin];
  static const _talkAroundStaff = [staff, admin, security, student, family];
  static const _talkAroundAdmin = [staff, admin, security, student, family, district];
  static const _talkAroundSecurity = [staff, admin, security, district];
  static const _talkAroundDistrict = [staff, admin, security, student, family, district];
  static const _talkAroundPdFireEms = [admin, security, district];

  static List<String> getTalkAroundPermissions(String role) {
    switch (role) {
      case family:
        return _talkAroundFamily;
      case student:
        return _talkAroundStudents;
      case admin:
        return _talkAroundAdmin;
      case security:
        return _talkAroundSecurity;
      case staff:
        return _talkAroundStaff;
      case district:
        return _talkAroundDistrict;
      case pdFireEms:
        return _talkAroundPdFireEms;
      default:
        return [];
    }
  }
}