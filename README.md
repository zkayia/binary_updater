
# binary_updater

A library to auto-update a compiled binary from github releases.

## Installation

Add it to your pubspec.yaml:
```yaml
dependencies:
  binary_updater:
    git: https://github.com/zkayia/binary_updater
```

Run pub get:
```
dart pub get
```


## Usage

Create an updater with your settings:
```dart
final updater = BinaryUpdater(
  repo: "coolguy/awersome_cli",
  exec: "awersomecli",
  execScheme: "{exec}_{platform}_{arch}{ext}",
);
```

Fetch the latest update:
```dart
final latest = await updater.getLatest();
```

Update and print the download progress:
```dart
// To make an update, the current process must be killed.
// Make sure nothing importants occurs after calling update().
final update = updater.update(
  CURRENT_VERSION,
  latest, // Omitting this will update to the latest
);

await for (final download in update) {

  print("\r${download.percentage}%");

  if (download.isDone) {

    print("Download finished, installing...");
    print(download.message);
    updater.dispose();
    break;
  }
}
```
`CURRENT_VERSION` must be a `Version` object from the
[version](https://pub.dev/packages/version)
package.