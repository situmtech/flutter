## Unreleased

- Migrate the Android plugin to Built-in Kotlin, following the Flutter guides. This removes the Flutter warning "Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): situm_flutter" and allows apps to build with `android.builtInKotlin=true`. The minimum supported Flutter version does not change (3.44). Tested with Flutter 3.44, 3.47 and 3.50, on Android Gradle Plugin 8 and 9. No compatibility breaks are expected.
- Update the Android example app to Gradle 9.5.0, Android Gradle Plugin 9.3.1 and Kotlin 2.4.20.
