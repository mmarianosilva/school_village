const String family = "school_family";
const String student = "school_student";
const String schoolAdmin = "school_admin";
const String admin = "admin";
const String schoolSecurity = "school_security";
const String security = "security";
const String schoolStaff = "school_staff";
const String staff = "staff";
const String district = "district";
const String superadmin = "superadmin";
const String pdFireEms = "pd-fire-ems";

class PermissionMatrix {
  static const _talkAroundFamily = [staff, admin, schoolStaff, schoolAdmin];
  static const _talkAroundStudents = [staff, admin, schoolStaff, schoolAdmin];
  static const _talkAroundStaff = [staff, schoolStaff, admin, schoolAdmin, security, schoolSecurity, student, family];
  static const _talkAroundAdmin = [staff, schoolStaff, admin, schoolAdmin, security, schoolSecurity, student, family, district, superadmin];
  static const _talkAroundSecurity = [staff, schoolStaff, admin, schoolAdmin, security, schoolSecurity, district, superadmin];
  static const _talkAroundDistrict = [staff, schoolStaff, admin, schoolAdmin, security, schoolSecurity, student, family, district, superadmin];
  static const _talkAroundPdFireEms = [admin, schoolAdmin, security, schoolSecurity, district, superadmin];

  static List<String> getTalkAroundPermissions(String role) {
    switch (role) {
      case family:
        return _talkAroundFamily;
      case student:
        return _talkAroundStudents;
      case admin:
      case schoolAdmin:
        return _talkAroundAdmin;
      case security:
      case schoolSecurity:
        return _talkAroundSecurity;
      case staff:
      case schoolStaff:
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