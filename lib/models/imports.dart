// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:ffi';

import 'package:ffi/ffi.dart';

final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

int QueryFullProcessImageName(int hProcess, int dwFlags, Pointer<Utf16> lpExeName, Pointer<Uint32> lpdwSize) =>
    _QueryFullProcessImageName(hProcess, dwFlags, lpExeName, lpdwSize);
final int Function(int hProcess, int dwFlags, Pointer<Utf16> lpExeName, Pointer<Uint32> lpdwSize)
    _QueryFullProcessImageName = _kernel32.lookupFunction<
        Int32 Function(IntPtr hProcess, Uint32 dwFlags, Pointer<Utf16> lpExeName, Pointer<Uint32> lpdwSize),
        int Function(int hProcess, int dwFlags, Pointer<Utf16> lpExeName,
            Pointer<Uint32> lpdwSize)>('QueryFullProcessImageNameW');
