import 'package:window_watcher/window_watcher.dart';

Future<void> main() async {
  final List<Window> windows = await WindowWatcher.getWindows(); //Get list of visible windows
  for (Window window in windows) {
    //Show visible windows one by one with 1 second delay
    window.show(forced: true); //With additional forced flag
    await Future.delayed(const Duration(seconds: 1));
  }
}
