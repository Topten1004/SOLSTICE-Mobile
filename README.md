# solstice

System requirements
To install and run Flutter, your development environment must meet these minimum requirements:

Operating Systems: macOS (64-bit)
Disk Space: 2.8 GB (does not include disk space for IDE/tools).
Tools: Flutter uses git for installation and upgrade. We recommend installing Xcode, which includes git, but you can also install git separately

**1.Get the Flutter SDK
**
https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_2.2.2-stable.zip


**2.Extract the file in the desired location, for example:
**
cd ~/development
unzip ~/Downloads/flutter_macos_2.2.2-stable.zip


**3. Add the flutter tool to your path:
**

export PATH="$PATH:`pwd`/flutter/bin"

This command sets your PATH variable for the current terminal window only. To permanently add Flutter to your path, see Update your path.

**You are now ready to run Flutter commands!
**
Run flutter doctor

Run the following command to see if there are any dependencies you need to install to complete the setup (for verbose output, add the -v flag):

flutter doctor


This command checks your environment and displays a report to the terminal window. The Dart SDK is bundled with Flutter; it is not necessary to install Dart separately. Check the output carefully for other software you might need to install or further tasks to perform (shown in bold text).

[-] Android toolchain - develop for Android devices
    • Android SDK at /Users/obiwan/Library/Android/sdk
    ✗ Android SDK is missing command line tools; download from https://goo.gl/XxQghQ
    • Try re-installing or updating your Android SDK,
      visit https://flutter.dev/setup/#android-setup for detailed instructions.
      
**Platform setup**

macOS supports developing Flutter apps in iOS, Android. Complete at least one of the platform setup steps now, to be able to build and run your first Flutter app.


**iOS setup
****
Install Xcode
To develop Flutter apps for iOS, you need a Mac with Xcode installed.**

1.Install the latest stable version of Xcode (using web download or the Mac App Store).
2.Configure the Xcode command-line tools to use the newly-installed version of Xcode by running the following from the command line:

sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch


This is the correct path for most cases, when you want to use the latest version of Xcode. If you need to use a different version, specify that path instead.

3. Make sure the Xcode license agreement is signed by either opening Xcode once and confirming or running sudo xcodebuild -license from the command line.


Versions older than the latest stable version may still work, but are not recommended for Flutter development. Using old versions of Xcode to target bitcode is not supported, and is likely not to work.

With Xcode, you’ll be able to run Flutter apps on an iOS device or on the simulator.

**Set up the iOS simulator
**To prepare to run and test your Flutter app on the iOS simulator, follow these steps:

1.On your Mac, find the Simulator via Spotlight or by using the following command:

open -a Simulator

2.Make sure your simulator is using a 64-bit device (iPhone 5s or later) by checking the settings in the simulator’s Hardware > Device menu.
3.Depending on your development machine’s screen size, simulated high-screen-density iOS devices might overflow your screen. Grab the corner of the simulator and drag it to change the scale. You can also use the Window > Physical Size or Window > Pixel Accurate options if your computer’s resolution is high enough.
If you are using a version of Xcode older than 9.1, you should instead set the device scale in the Window > Scale menu.

To launch the app in the Simulator, ensure that the Simulator is running and enter:

flutter run

**Deploy to iOS devices
**


To deploy your Flutter app to a physical iOS device you’ll need to set up physical device deployment in Xcode and an Apple Developer account. If your app is using Flutter plugins, you will also need the third-party CocoaPods dependency manager.

You can skip this step if your apps do not depend on Flutter plugins with native iOS code. Install and set up CocoaPods by running the following commands:

sudo gem install cocoapods


 Note: The default version of Ruby requires sudo to install the CocoaPods gem. If you are using a Ruby Version manager, you may need to run without sudo.


Follow the Xcode signing flow to provision your project:

Open the default Xcode workspace in your project by running open ios/Runner.xcworkspace in a terminal window from your Flutter project directory.
Select the device you intend to deploy to in the device drop-down menu next to the run button.
Select the Runner project in the left navigation panel.
In the Runner target settings page, make sure your Development Team is selected under Signing & Capabilities > Team.

When you select a team, Xcode creates and downloads a Development Certificate, registers your device with your account, and creates and downloads a provisioning profile (if needed).

To start your first iOS development project, you might need to sign into Xcode with your Apple ID.

Development and testing is supported for any Apple ID. Enrolling in the Apple Developer Program is required to distribute your app to the App Store. For details about membership types, see Choosing a Membership.

The first time you use an attached physical device for iOS development, you need to trust both your Mac and the Development Certificate on that device. Select Trust in the dialog prompt when first connecting the iOS device to your Mac.


Then, go to the Settings app on the iOS device, select General > Device Management and trust your Certificate. For first time users, you may need to select General > Profiles > Device Management instead.

If automatic signing fails in Xcode, verify that the project’s General > Identity > Bundle Identifier value is unique.

