/*
  Sách của T - Quản lý sách cá nhân
  Copyright © 2025 SoleilPQD

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


import 'package:flutter/services.dart';

enum _MethodFromNative {
  kiemTraISBN;

  static _MethodFromNative? init(String raw) {
    return switch (raw) {
      "kiemTraISBN" => _MethodFromNative.kiemTraISBN,
      _ => null
    };
  }
}

enum _MethodToNative {
  quetMaISBN;

  String get value {
    return switch (this) {
      _MethodToNative.quetMaISBN => "quetMaISBN"
    };
  }
}

class HeThongMay {

  final MethodChannel _kenhKetNoi = MethodChannel("sach.cua.T");

  HeThongMay._internal() {
    _kenhKetNoi.setMethodCallHandler((call) {
      final method = _MethodFromNative.init(call.method);
      if (method != null) {
        switch (method) {
        case _MethodFromNative.kiemTraISBN:
          return _kiemTraISBN(call.arguments);
        }
      }
      return Future(() => null);
    });
  }
  static final HeThongMay duyNhat = HeThongMay._internal();

  Future<String?> quetMaISBN() async {
    return _kenhKetNoi.invokeMethod<String>(_MethodToNative.quetMaISBN.value);
  }

  Future<bool> _kiemTraISBN(String giaTri) {
    if (giaTri.length == 13) {
      String prefix = giaTri.substring(0, 3);
      if (prefix != "978" && prefix != "979") {
        return Future.value(false);
      }
      int index = 0;
      int tong = 0;
      int lastDigit = 0;
      for (final element in giaTri.runes) {
        int digit = element - 48;
        if (digit >= 0 && digit <= 9) {
          if (index < 12) {
            if (index % 2 == 0) {
              tong += digit;
            } else {
              tong += 3 * digit;
            }
          } else {
            lastDigit = digit;
          }
        } else {
          return Future.value(false);
        }
        index += 1;
      }
      tong = 10 - (tong % 10);
      if (tong < 10) {
        if (lastDigit == tong) {
          return Future.value(true);
        }
      } else {
        if (lastDigit == 0) {
          return Future.value(true);
        }
      }
    } else if (giaTri.length == 10) {
      int tong1 = 0;
      int tong2 = 0;
      for (final element in giaTri.runes) {
        int digit = element - 48;
        if (digit >= 0 && digit <= 9) {
          tong1 += digit;
          tong2 += tong1;
        } else {
          return Future.value(false);
        }
      }
      if (tong2 % 11 == 0) {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

}