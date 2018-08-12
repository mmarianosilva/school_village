#!/bin/bash

BUILD_NUM="$((${CIRCLE_BUILD_NUM}+1))"

echo ${BUILD_NUM}

cp ./scripts/dev/google-services.json ./android/app/google-services.json

sudo gem install fastlane -NV
flutter upgrade
flutter doctor
flutter build apk --release --build-number=${BUILD_NUM}
cd android && sudo fastlane add_plugin appcenter
fastlane deploy_beta