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

import 'package:flutter/material.dart';

/// Hằng số
class HangSo {

  static const String urlLuuChieu = "https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu";
  static const Map<String, String> tiengVietKhongDau = {
    "a": "àáảãạâầấẩẫậăằắẳẵặ",
    "e": "èéẻẽẹêềếểễệ",
    "i": "ìíỉĩị",
    "o": "òóỏõọôồốổỗộơờớởỡợ",
    "u": "ùúủũụưừứửữự",
    "y": "ỳýỷỹỵ",
    "d": "đ"
  };

}

/// Tổng hợp các hàm lặt vặt
class LinhTinh {

  /// Dừng nhập văn bản
  static void dungNhapVanBan() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Kiểm tra xem mã có đúng chuẩn ISBN hay ko (13 chữ số, tiền tố, giá trị kiểm tra)
  static bool kiemTraISBN(String giaTri) {
    if (giaTri.length == 13) {
      String prefix = giaTri.substring(0, 3);
      if (prefix != "978" && prefix != "979") {
        return false;
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
          return false;
        }
        index += 1;
      }
      tong = 10 - (tong % 10);
      if (tong < 10) {
        if (lastDigit == tong) {
          return true;
        }
      } else {
        if (lastDigit == 0) {
          return true;
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
          return false;
        }
      }
      if (tong2 % 11 == 0) {
        return true;
      }
    }
    return false;
  }

  /// Chuẩn hoá mã số (chỉ giữ lại chữ số)
  static String chuanHoaMaSo(String dauVao) {
    String ketQua = "";
    for (final kyTu in dauVao.characters) {
      int? so = int.tryParse(kyTu);
      if (so != null && so >= 0 && so <= 9 && "$so" == kyTu) {
        ketQua += kyTu;
      }
    }
    return ketQua;
  }

  /// Chia text thành các đoạn dựa vào các ký tự có trong [dauPhanChia], bỏ qua các đoạn ngắn hơn [toiThieu]
  static List<String> phanChiaTextTheoKyTuDacBiet(String dauVao, {String dauPhanChia = ".,;-", int toiThieu = 5}) {
    List<String> ketQua = [];
    String tam = "";
    for (final kyTu in dauVao.characters) {
      if (dauPhanChia.contains(kyTu)) {
        tam = tam.trim();
        if (tam.length >= toiThieu) {
          ketQua.add(tam);
        }
        tam = "";
      } else {
        tam += kyTu;
      }
    }
    tam = tam.trim();
    if (tam.length >= toiThieu) {
      ketQua.add(tam);
    }
    return ketQua;
  }

  static String _boDauTiengViet(String chu) {
    for (final muc in HangSo.tiengVietKhongDau.entries) {
      if (muc.value.contains(chu)) {
        return muc.key;
      }
    }
    return chu;
  }

  /// Loại bỏ dấu tiếng Việt
  static String loaiBoDautiengViet(String vanBan) {
    String ketQua = "";
    for (final chu in vanBan.toLowerCase().characters) {
      ketQua += _boDauTiengViet(chu);
    }
    return ketQua;
  }

}

extension ViTriWidget on GlobalKey {

  /// Tìm vị trí của widget
  Rect? timViTriCuaWidget() {
    final RenderBox? renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      Offset pos = renderBox.localToGlobal(Offset.zero);
      Size size = renderBox.size;
      final RenderBox? parentBox = renderBox.parent as RenderBox?;
      if (parentBox != null) {
      }
      return Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);
    }
    return null;
  }

}
