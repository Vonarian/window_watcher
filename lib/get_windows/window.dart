import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Class containing information about a window and related functions.
class Window {
  ///Title of the window.
  final String title;

  ///If the window is the active window or not.
  final bool isActive;

  ///Window ID.
  final int hWnd;

  const Window({
    required this.title,
    required this.isActive,
    required this.hWnd,
  });

  ///Bring window to the front with an optional [forced] flag.
  void show({bool forced = false}) {
    AttachThreadInput(GetCurrentThreadId(), GetWindowThreadProcessId(hWnd, nullptr), TRUE);

    final Pointer<WINDOWPLACEMENT> place = calloc<WINDOWPLACEMENT>();
    GetWindowPlacement(hWnd, place);

    switch (place.ref.showCmd) {
      case SW_SHOWMAXIMIZED:
        ShowWindow(hWnd, SW_SHOWMAXIMIZED);
        break;
      case SW_SHOWMINIMIZED:
        ShowWindow(hWnd, SW_RESTORE);
        break;
      default:
        ShowWindow(hWnd, SW_NORMAL);
        break;
    }
    free(place);
    if (forced) {
      ShowWindow(hWnd, SW_RESTORE);
      SetForegroundWindow(hWnd);
      BringWindowToTop(hWnd);
      SetFocus(hWnd);
      SetActiveWindow(hWnd);
      UpdateWindow(hWnd);
    }
    SetForegroundWindow(hWnd);
    if (GetForegroundWindow() != hWnd) {
      SwitchToThisWindow(hWnd, TRUE);
      SetForegroundWindow(hWnd);
    }

    AttachThreadInput(GetCurrentThreadId(), GetWindowThreadProcessId(hWnd, nullptr), FALSE);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isActive': isActive,
      'hWnd': hWnd,
    };
  }

  factory Window.fromMap(Map<String, dynamic> map) {
    return Window(
      title: map['title'] as String,
      isActive: map['isActive'] as bool,
      hWnd: map['hWnd'] as int,
    );
  }

  @override
  String toString() {
    return 'Window ==> title: $title, isActive: $isActive, hWnd: $hWnd';
  }
}
