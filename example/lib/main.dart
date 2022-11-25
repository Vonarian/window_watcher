import 'package:window_watcher/window_watcher.dart';

Future<void> main() async {
  final List<Window> windows = await WindowWatcher.getWindows();
  print(windows);
}
