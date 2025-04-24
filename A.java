name: clarity_break
description: "Cannabis tolerance break tracker"
        # You can bump version/build number as needed
version: 1.0.0+1

environment:
sdk: ">=2.18.0 <4.0.0"

dependencies:
flutter:
sdk: flutter

  # state & storage
provider: ^6.0.5
shared_preferences: ^2.2.2
flutter_local_notifications: ^17.0.0

        # UI & theming
intl: ^0.18.1
google_fonts: ^6.1.0
flutter_markdown: ^0.7.7
another_flutter_splash_screen: ^1.2.1
confetti: ^0.7.0
smooth_page_indicator: ^1.0.0

        # charts
fl_chart: ^0.55.2

        # timezones for notifications
timezone: ^0.9.4

        # sharing & file I/O — switched to file_selector
share_plus: ^11.0.0
file_selector: ^0.9.2
path_provider: ^2.0.14

        # misc
uuid: ^3.0.6
collection: ^1.17.0

dev_dependencies:
flutter_test:
sdk: flutter
flutter_lints: ^5.0.0

        # --- Launcher Icon Configuration ---
flutter_icons:
android: true
ios: true
image_path: assets/images/logo.png

# --- Native Splash Screen Configuration ---
flutter_native_splash:
color: "#ffffff"           # background color of splash
image: assets/images/logo.png
android: true
ios: true
android_disable_fullscreen: true

flutter:
uses-material-design: true

assets:
        - assets/data/library_content.json
    - assets/images/logo.png
    - assets/images/empty_journal.png
    - assets/images/empty_history.png
    - assets/images/home_inactive_graphic.png

  # If you have other asset folders, list them here
  # - assets/images/...
