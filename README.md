# school_village

School Village

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## iOS Release Build
Run `flutter build ios --release` and then archive from xCode

## Android Release Build
Run `flutter build apk --release --target-platform=android-arm64`

Use NDK 16c to Build Android


## Roles
 - school_admin
 - school_security
 - school_staff
 - school_student
 
## Build and distribute
 
### Increment Build Number
Version format = `x.y.z` where `x` = major version number, `y` = minor version number, `z` = build number.
- Increment version number displayed in app by incrementing number the `version` variable in `lib/util/constants.dart`
- Increment `versionCode` and `versionName` in `android/app/build.gradle`
- Increment `CFBundleShortVersionString` and `CFBundleSignature` in `ios/Runner/Info.plist` or from Xcode

### Build & Distribute Android 
- Run `flutter build apk --release` to create release apk
- Log into https://appcenter.ms using schoolvillageowner@gmail.com and upload the generated apk (new release) from the Distribute section of the SchoolVillage Android App

### Build & Distribute iOS
- Run `flutter build ios --release` to build iOS app
- Open Xcode and Archive the package `Product->Archive`
- From the Archives window, upload the recently created Archive by clicking on `Upload to App Store`
- Choose Automatic Signing when prompted and upload
- Log into iTunes Connect once the app is processed. Provide required Export Compliance details and distribute build to the test users.
