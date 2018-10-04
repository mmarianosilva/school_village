#!/bin/bash

BUILD_NUM="$((${CIRCLE_BUILD_NUM}+1))"

cd ios
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUM}" "./Runner/Info.plist"
cd ..

echo ${BUILD_NUM}

#cp ./scripts/dev/GoogleServices-Info.plist ./ios/Runner/GoogleServices-Info.plist


echo "Installing requirements"

curl https://storage.googleapis.com/flutter_infra/releases/beta/macos/flutter_macos_v0.8.2-beta.zip -o flutter.zip
unzip flutter.zip
export PATH=`pwd`/flutter/bin:$PATH

pip install six
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "ruby-2.4" > ~/.ruby-version
cd ios
brew install --HEAD libimobiledevice
brew install ideviceinstaller
brew upgrade cocoapods
brew install ios-deploy
echo "Installing CocoaPods"
sudo gem install cocoapods
yes | sudo gem update fastlane
pod setup
cd ..

echo "Running flutter upgrade"
flutter upgrade

echo "flutter doctor"
flutter doctor

cd ios && pod install
cd ..
echo "Running: flutter build ios --release --no-codesign --build-number=\"${BUILD_NUM}\""
flutter build ios --release --no-codesign --build-number="${BUILD_NUM}"

echo "flutter bundle exec fastlane beta"
cd ios && bundle update
bundle exec fastlane beta


#Build Andriod

#cp ./scripts/dev/google-services.json ./android/app/google-services.json
flutter build apk --release --build-number="${BUILD_NUM}"
cd android && sudo fastlane add_plugin appcenter
fastlane deploy_beta