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

## Example

See the [example documentation](example/README.md) for more information.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Contributing

Feel free to contribute by opening issues and/or pull requests. Your feedback is very welcome!

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for more information.

## Credits

Stereo has been developed and is maintained by **faku99**, **ludelafo** and **Daxidz**.

In no particular order, we credit the following people for their invaluable contributions:

* **joelfaul** for fixing an interference with the [audio_recorder](https://pub.dartlang.org/packages/audio_recorder) library
