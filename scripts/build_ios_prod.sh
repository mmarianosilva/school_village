#!/bin/bash

BUILD_NUM="$((${CIRCLE_BUILD_NUM}+1))"

echo ${BUILD_NUM}

cp ./scripts/dev/GoogleServices-Info.plist ./ios/Runner/GoogleServices-Info.plist


echo "Installing requirements"

curl https://storage.googleapis.com/flutter_infra/releases/beta/macos/flutter_macos_v0.5.1-beta.zip -o flutter_macos_v0.5.1-beta.zip
unzip flutter_macos_v0.5.1-beta.zip
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
brew install cocoapods
echo "Linking CocoaPods"
brew link --overwrite cocoapods
echo "Installing bundler"
sudo gem install bundler
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
cd ios && bundle install && bundle update
bundle exec fastlane beta