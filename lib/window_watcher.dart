///A Dart/Flutter package for working with visible windows developed for Windows machines.
// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
library window_watcher;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'get_windows/window.dart';

export 'get_windows/window.dart';

final List<Window> _list = [];

///Main class containing function(s) for working with windows.
class WindowWatcher {
  ///Get list of visible windows.
  static Future<List<Window>> getWindows({bool? getExe}) async {
    if (_list.isNotEmpty) {
      _list.removeRange(0, _list.length);
    }
    await _enumerateWindows();
    if (getExe ?? false) {
      for (int i = 0; i < _list.length; i++) {
        final e = _list[i];

        _list[i] = e.copyWith(exePath: getWindowExePath(e.hWnd));
      }
    }
    return _list;
  }

  ///Bring window to the front with an optional [forced] flag.
  void show(int hWnd, {bool forced = false}) {
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

  ///Receive path to executable file of a process using its Process ID.
  ///Returns null if process doesn't exist.
  static String? getProcessExePath(int processID) {
    String? exePath;
    final int hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);
    if (hProcess == 0) {
      CloseHandle(hProcess);
      return null;
    }
    final LPWSTR imgName = wsalloc(MAX_PATH);
    final Pointer<Uint32> buff = calloc<Uint32>()..value = MAX_PATH;
    if (QueryFullProcessImageName(hProcess, 0, imgName, buff) != 0) {
      final LPWSTR szModName = wsalloc(MAX_PATH);
      GetModuleFileNameEx(hProcess, 0, szModName, MAX_PATH);
      exePath = szModName.toDartString();
      free(szModName);
    } else {
      exePath = null;
    }
    free(imgName);
    free(buff);
    CloseHandle(hProcess);
    return exePath;
  }

  ///Returns executable path of a window using its hWnd.
  ///Returns null if process does not exist.
  static String? getWindowExePath(int hWnd) {
    String? result;
    final Pointer<Uint32> pId = calloc<Uint32>();
    GetWindowThreadProcessId(hWnd, pId);
    final int processID = pId.value;
    free(pId);

    result = getProcessExePath(processID);
    return result;
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
