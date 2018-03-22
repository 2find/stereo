# Stereo plugin for Flutter

A Flutter plugin for playing music on iOS and Android.

## Features

* Play/pause
* Stop
* Duration / seek to position
* Load track from path
* Load track from library

## Installation

First, add `stereo` as a dependency in your `pubspec.yaml` file.

### Android

Add the following permission to your `AndroidManifest.xml` file:
* `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>`

### iOS

Add the following key to your `Info.plist` file:
* `NSAppleMusicUsageDescription`

## Documentation

Since [pub.dartlang.org](pub.dartlang.org) doesn't support `dartdoc` 2.0 yet,
we hosted the [documentation](https://2find.github.io/stereo/) in the mean time.

## Example

See the [example documentation](example/README.md) for more information.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Contributing

Feel free to contribute by opening issues and/or pull requests. Your feedback is very welcome!

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for more information.
