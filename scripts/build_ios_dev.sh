#!/bin/bash

BUILD_NUM="$((${CIRCLE_BUILD_NUM}+1))"

echo ${BUILD_NUM}

cp ./scripts/dev/GoogleServices-Info.plist ./ios/Runner/GoogleServices-Info.plist

curl https://storage.googleapis.com/flutter_infra/releases/beta/macos/flutter_macos_v0.5.1-beta.zip -o flutter_macos_v0.5.1-beta.zip
unzip flutter_macos_v0.5.1-beta.zip
export PATH=`pwd`/flutter/bin:$PATH

flutter upgrade
flutter doctor

cd ios && pod install
cd ..
flutter build ios --release --no-codesign --build-number="${BUILD_NUM}"
cd ios && fastlane beta