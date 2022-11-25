library window_watcher;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'get_windows/window.dart';

export 'get_windows/window.dart';

final List<Window> _list = [];

class WindowWatcher {
  static Future<List<Window>> getWindows() async {
    if (_list.isNotEmpty) {
      _list.removeRange(0, _list.length);
    }
    await _enumerateWindows();
    return _list;
  }
}

int _enumWindowsProc(int hWnd, int lParam) {
  if (IsWindowVisible(hWnd) == FALSE) return TRUE;

  final length = GetWindowTextLength(hWnd);
  if (length == 0) {
    return TRUE;
  }

  final buffer = wsalloc(length + 1);
  GetWindowText(hWnd, buffer, length + 1);
  bool isActive = GetForegroundWindow() == hWnd;
  _list.add(Window(title: buffer.toDartString(), isActive: isActive, hWnd: hWnd));
  free(buffer);
  return TRUE;
}

Future<void> _enumerateWindows() async {
  final wndProc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
  EnumWindows(wndProc, 0);
}
