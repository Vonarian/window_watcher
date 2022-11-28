import 'package:window_watcher/window_watcher.dart';

Future<void> main() async {
  final List<Window> windows = await WindowWatcher.getWindows(getExe: true); //Get list of visible windows
  for (Window window in windows) {
    if ((window.exePath ?? '').contains('C:\\')) {
      print(window); // Print each window with the process executable inside drive C.
    }
    if (window.exePath == null) window.getExePath(); // Update executable path if it's null
    //Show visible windows one by one with 1 second delay
    window.show(forced: true); //With additional forced flag
    await Future.delayed(const Duration(seconds: 1));
  }
}
