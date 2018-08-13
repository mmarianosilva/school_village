#!/bin/bash

#TODO Env Add Configs and Set Build Number

curl https://storage.googleapis.com/flutter_infra/releases/beta/macos/flutter_macos_v0.5.1-beta.zip -o flutter_macos_v0.5.1-beta.zip
unzip flutter_macos_v0.5.1-beta.zip
export PATH=`pwd`/flutter/bin:$PATH
cd ios && pod install
cd .. && flutter doctor
flutter build ios --release
cd ios && fastlane beta