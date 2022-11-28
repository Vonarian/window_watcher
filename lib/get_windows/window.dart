import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../models/imports.dart';

/// Class containing information about a window and related functions.
class Window {
  ///Title of the window.
  final String title;

  ///If the window is the active window or not.
  final bool isActive;

  ///Window ID.
  final int hWnd;

  ///Full path the to executable of the window (Path to the exe file).
  final String? exePath;

  const Window({
    required this.title,
    required this.isActive,
    required this.hWnd,
    this.exePath,
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

  ///Receive path to executable file of a process using its Process ID.
  ///Returns null if process doesn't exist.
  String? _getProcessExePath(int processID) {
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

  ///Returns executable path of a window using its hWnd and updates current [Window] instance.
  ///Returns null if process does not exist.
  String? getExePath() {
    String? result;
    final Pointer<Uint32> pId = calloc<Uint32>();
    GetWindowThreadProcessId(hWnd, pId);
    final int processID = pId.value;
    free(pId);
    result = _getProcessExePath(processID);
    if (result != null) copyWith(exePath: result);
    return result;
  }

  @override
  String toString() {
    return 'Window ==> title: $title, isActive: $isActive, hWnd: $hWnd, exePath: $exePath';
  }

  Window copyWith({
    String? title,
    bool? isActive,
    int? hWnd,
    String? exePath,
  }) {
    return Window(
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      hWnd: hWnd ?? this.hWnd,
      exePath: exePath ?? this.exePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isActive': isActive,
      'hWnd': hWnd,
      'exePath': exePath,
    };
  }

  factory Window.fromMap(Map<String, dynamic> map) {
    return Window(
      title: map['title'] as String,
      isActive: map['isActive'] as bool,
      hWnd: map['hWnd'] as int,
      exePath: map['exePath'] as String,
    );
  }
}
