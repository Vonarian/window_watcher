# Window Watcher

Flutter/Dart Windows package using [win32 functions](https://pub.dev/packages/win32) to get information about windows and manipulating them.

## Features

Fast and easy access to window titles, their hWnds and whether a window is the active window or not.
Activate(show) a window by calling `show()` on any of the listed windows.

## Installation

In the `dependecies` section of your `pubspec.yaml`, add the following line:
```yaml
    dependencies:
      window_watcher: <latest_version>
```

## Usage

Get list of all (non-hidden) windows using the following code:

```dart
import 'package:window_watcher/window_watcher.dart';

Future<void> main() async {
  final List<Window> windows = await WindowWatcher.getWindows(); //Get list of visible windows
  for (Window window in windows){ //Show visible windows one by one with 1 second delay
    window.show(); //With additional forced flag
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

## Additional Information

This package is using [win32](https://pub.dev/packages/win32) and inspiring (most of) its functionalities from [Tabame by Far-Se](https://github.com/Far-Se/tabame/)