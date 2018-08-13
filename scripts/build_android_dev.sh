#!/bin/bash

#TODO Env Add Configs and Set Build Number

flutter doctor
flutter build apk --release
cd android && fastlane add_plugin appcenter
fastlane deploy_beta