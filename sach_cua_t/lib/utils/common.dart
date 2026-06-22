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

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:sach_cua_t/models/dulieu.dart';

enum PhanLoaiDuongDan {
  file, assets;
}

/// Hằng số
class HangSo {

  static const String urlLuuChieu = "https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu";
  static const String urlDKXuatBan = "https://ppdvn.gov.vn/web/guest/ke-hoach-xuat-ban";
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

extension SafeWidgetState on State {

  /// Đặt trạng thái khi an toàn
  /// Chỉ gọi `setState` khi state đã được mount vào widget
  /// (dùng hàm này khi muốn đặt giá trị thuộc tính của các state nhưng chưa chắc chắn đã mount vào widget)
  /// (vd: VanBanHienThiWidget: nạp text trong initState, nạp xong text thì ko chắc đã mount chưa)
  /// Chú ý: [action] sẽ không chắc chắn sẽ được thực thi.
  void datTrangThaiKhiAnToan({void Function()? action}) {
    BuildContext? ctx;
    try {
      ctx = context;
    } catch (_) {
      ctx = null;
    }
    if (ctx != null && ctx.mounted) {
      // ignore_for_file: invalid_use_of_protected_member
      setState(action ?? (){});
    }
  }

}

/// Tổng hợp các hàm lặt vặt
class LinhTinh {

  /// Dừng nhập văn bản
  static void dungNhapVanBan() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Uri taoDuongDan({required PhanLoaiDuongDan phanLoai, required String duongDan}) => Uri(scheme: phanLoai.name, path: duongDan);

  static UiImage taoWidgetAnh(Uri duongDan) {
    if (duongDan.scheme == PhanLoaiDuongDan.assets.name) {
      return UiImage.asset(duongDan.path);
    }
    return UiImage.file(File(duongDan.path));
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

  /// Điền vào chỗ trống: thay thế cụm Ký tự tránh + Chỗ trống `[kyTuTranh][choTrong]` trong mẫu [mau] bằng tham số [thamSo].
  /// Tham số không đủ thì giữ nguyên văn bản trong mẫu.
  /// VD: ("###_ #_", ["A"]) -> "#A #_"
  static String dienVaoChoTrong(String mau, List<String> thamSo, {String choTrong = "_", String kyTuTranh = "#"}) {
    String ketQua = "";
    assert(choTrong.isNotEmpty, "Chuỗi `Chỗ trống` phải dài ít nhất 1 ký tự");
    assert(kyTuTranh.length == 1, "Chuỗi `Ký tự tránh` phải dài đúng 1 ký tự");
    assert(!choTrong.startsWith(kyTuTranh), "Chuỗi `Chỗ trống` không được bắt đầu bằng `Ký tự tránh`");
    String giuCho = kyTuTranh + choTrong;
    String tranh = kyTuTranh + kyTuTranh;
    String dem = "";
    int so = 0;
    for (final String kyTu in mau.characters) {
      if (so < 0) {
        ketQua += kyTu;
        continue;
      }
      if (dem.isNotEmpty) {
        dem += kyTu;
        if (dem == giuCho) {
          if (so < thamSo.length) {
            ketQua += thamSo[so];
            so += 1;
            dem = "";
          } else {
            so = -1;
            ketQua += dem;
            dem = "";
          }
        } else  if (dem == tranh) {
          ketQua += kyTuTranh;
          dem = "";
        } else if (!giuCho.startsWith(dem)) {
          ketQua += dem;
          dem = "";
        }
      } else if (kyTu == kyTuTranh) {
        dem += kyTu;
      } else {
        ketQua += kyTu;
      }
    }
    if (dem.isEmpty) {
      ketQua += dem;
    }
    return ketQua;
  }

  /// Điền vào chỗ trống: thay thế cụm Ký tự tránh + Chỉ số + Ký tự tránh `[kyTuTranh]n[kyTuTranh]` trong mẫu [mau] bằng tham số [thamSo][n].
  /// Tham số không đủ thì giữ nguyên văn bản trong mẫu.
  /// Hàm chủ yếu áp dụng cho mẫu thay đổi vị trí tham số trong các trường hợp khác nhau (vd ngôn ngữ) hoặc tham số lặp lại.
  /// Nếu không có thay đổi vị trí tham số thì sử dụng hàm `dienVaoChoTrong` thì hiệu quả hơn.
  /// Chú ý [kyTuTranh] được dùng trong RegEx nên tránh các ký tự đặc biệt của RegEx.
  /// VD: ("%%%0% %0% %1%", ["A"]) -> "%A A %1%"
  static String dienVaoChoTrongTheoChiSo(String mau, List<String> thamSo, {String kyTuTranh = "%"}) {
    assert(kyTuTranh.length == 1, "Chuỗi `Ký tự tránh` phải dài đúng 1 ký tự");
    String ketQua = "";
    String tranh = kyTuTranh + kyTuTranh;
    String dem = "";
    String kyTuTranhExp = kyTuTranh;
    const String kyTuRegExpDacBiet = "{}[]\\.*+?^\$-|";
    if (kyTuRegExpDacBiet.contains(kyTuTranhExp)) {
      kyTuTranhExp = "\\$kyTuTranhExp";
    }
    if (kyTuTranhExp == " ") {
      kyTuTranhExp = "\\s";
    }
    final RegExp expTiepTuc = RegExp("^$kyTuTranhExp\\d+\$");
    final RegExp expDayDu = RegExp("^$kyTuTranhExp\\d+$kyTuTranhExp\$");
    for (final String kyTu in mau.characters) {
      if (dem.isNotEmpty) {
        dem += kyTu;
        if (expDayDu.allMatches(dem).isNotEmpty) {
          try {
            final int so = int.parse(dem.substring(1, dem.length - 1));
            if (so < thamSo.length) {
              ketQua += thamSo[so];
            } else {
              ketQua += dem;
            }
          } catch (_) {
            ketQua += dem;
          }
          dem = "";
        } else if (dem == tranh) {
          ketQua += kyTuTranh;
          dem = "";
        } else if (expTiepTuc.allMatches(dem).isEmpty) {
          ketQua += dem;
          dem = "";
        }
      } else if (kyTu == kyTuTranh) {
        dem += kyTu;
      } else {
        ketQua += kyTu;
      }
    }
    if (dem.isEmpty) {
      ketQua += dem;
    }
    return ketQua;
  }

  static Future<String?> kiemTraMime(String duongDan) async {
    String? mime = lookupMimeType(duongDan);
    if (mime != null) {
      return mime;
    }
    final File tep = File(duongDan);
    final RandomAccessFile reader = await tep.open(mode: FileMode.read);
    try {
      await reader.setPosition(0);
      final Uint8List mau = await reader.read(20);
      reader.close();
      return lookupMimeType(tep.path, headerBytes: mau);
    } catch (_) {
      reader.close();
      return null;
    }
  }

  static Future<bool> kiemTraCoPhaiAnh(String duongDan) async {
    final List<String> cacKieuAnhPhuHop = [
      "image/webp",
      "image/jpeg",
      "image/png"
    ];
    final String? mime = await kiemTraMime(duongDan);
    return cacKieuAnhPhuHop.contains(mime ?? "");
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
