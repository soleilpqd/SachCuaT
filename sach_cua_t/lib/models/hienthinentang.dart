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

/// Chiều màn hình
enum ChieuManHinh {
  /// dọc
  doc,
  /// ngang
  ngang;
}

/// Thông tin vị trí
class ThongTinViTri {
  /// Trên (Khoảng cách từ viền trên view chứa đến viền trên view hiện tại)
  int? tren;
  /// Trái (Khoảng cách từ viền trái view chứa đến viền trái view hiện tại)
  int? trai;
  /// Cao (dọc) (Khoảng cách từ viền trên view hiện tại đến viền dưới view hiện tại)
  int? cao;
  /// Rộng (ngang) (Khoảng cách từ viền trái view hiện tại đến viền phải view hiện tại)
  int? rong;
}

/// Thông tin Lề
class ThongTinLe {
  /// Trên (Khoảng cách từ viền trên view chứa đến viền trên view hiện tại)
  int? tren;
  /// Dưới (Khoảng cách từ viền dưới view chứa đến viền dưới view hiện tại)
  int? duoi;
  /// Trái (Khoảng cách từ viền trái view chứa đến viền trái view hiện tại)
  int? trai;
  /// Phải (Khoảng cách từ viền phải view chứa đến viền phải view hiện tại)
  int? phai;
}

/*
VẤN ĐỀ 1:

Layout màn hình của 1 app Flutter:
- Màn hình phần cứng
  - Window (cửa sổ): hiển thị toàn màn hình
    - View gốc: UIView thuộc root UIViewController (iOS) hoặc Activity gốc (Android). Flutter sẽ render màn hình App Flutter lên view này.

Trên iOS: view gốc hiển thị khớp với window.

Trên Android: view gốc có 1 khoảng lề so với window. Chú ý: khoảng lề này không phải là Safe Area Insets.
Safe Area Insets là khoảng lề áp dụng cho View gốc, app vẫn có thể hiển thị vào vùng lề Safe Area.

Kích thước màn hình từ hàm MediaQuery là kích thước của View gốc.

Khoảng lề này ảnh hưởng đến việc đổi toạ độ từ Native sang Flutter.
- Nếu lấy trục toạ độ là Window thì phải tích đến khoảng lề của View gốc khi chuyển toạ độ sang Flutter.
- Nếu lấy trục toạ độ là View gốc thì khi chuyển đổi không vấn đề gì.

VẤN ĐỀ 2:

Đơn vị đo điểm ảnh của toạ độ/kích thước và tỉ số (ratio) giữa các đơn vị.
- Flutter dùng đơn vị Logic.
- iOS cũng dùng đơn vị Logic.
- Android dùng đơn vị Physic.

VD màn hình phần cứng là 3, Flutter dùng tỉ số Ratio là 3, thì kích thước trong app là 1 (1 điểm ảnh app tương ứng với 3 điểm ảnh hiển thị trên màn hình phần cứng).
iOS cũng có tỉ số là 3 (scale cho màn hình Retina), nên kích thước/toạ độ tương ứng với Flutter.
Android không có tỉ số mà dùng thẳng kích thước/toạ độ của màn hình phần cứng, khi chuyển sang cần tính tới ratio.

 */

/// Hiển thị nền tảng
/// Chứa các thông tin hiển thị của module native
class HienThiNenTang {

  /// Chiều màn hình
  var chieuManHinh = ChieuManHinh.doc;
  /// Tỉ số đơn vị vật lý/logic
  double heSoDonVi = 1.0;
  /// Bàn phím.
  /// Tuỳ OS mà có thông tin khác nhau:
  /// - Android: cao.
  /// - iOS: trên, trái, cao, rộng.
  final banPhim = ThongTinViTri();
  /// Thông tin Window. Gồm: cao, rộng.
  final cuaSo = ThongTinViTri();
  /// Thông tin UIView/Activity gốc của Flutter. Gồm: trên, trái, cao, rộng.
  final viewGoc = ThongTinViTri();
  /// Thông tin lề an toàn (Safe Area Insets). Gồm: trên, trái, phải, dưới.
  final leAnToan = ThongTinLe();

  T? _trichXuatMuc<T>(Map<Object?, Object?> thongTin, String khoa) {
    final ketQua = thongTin[khoa];
    return (ketQua is T?) ? ketQua : null;
  }

  int? _trichXuatToaDo(Map<Object?, Object?> thongTin, String khoa) {
    final ketQua = thongTin[khoa];
    if (ketQua != null && ketQua is int) {
      return _chuyenDoiToaDo(ketQua);
    }
    return null;
  }

  /// Chuyển đổi số toạ độ từ Native sang Flutter
  int _chuyenDoiToaDo(int so) {
    double soVatLy = so.toDouble() * heSoDonVi;
    return soVatLy ~/ WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  }

  /// Trích xuất thông tin
  void trichXuat(Map<Object?, Object?> thongTin) {
    final String? ch = _trichXuatMuc(thongTin, "o");
    if (ch != null) {
      chieuManHinh = (ch == "l") ? ChieuManHinh.ngang : ChieuManHinh.doc;
    }
    heSoDonVi = _trichXuatMuc(thongTin, "hs") ?? 1.0;
    cuaSo.cao = _trichXuatToaDo(thongTin, "scr_h");
    cuaSo.rong = _trichXuatToaDo(thongTin, "scr_w");
    banPhim.cao = _trichXuatToaDo(thongTin, "kb_h");
    banPhim.rong = _trichXuatToaDo(thongTin, "kb_w");
    banPhim.tren = _trichXuatToaDo(thongTin, "kb_t");
    banPhim.trai = _trichXuatToaDo(thongTin, "kb_l");
    viewGoc.cao = _trichXuatToaDo(thongTin, "h");
    viewGoc.rong = _trichXuatToaDo(thongTin, "w");
    viewGoc.tren = _trichXuatToaDo(thongTin, "t");
    viewGoc.trai = _trichXuatToaDo(thongTin, "l");
    leAnToan.tren = _trichXuatToaDo(thongTin, "st");
    leAnToan.duoi = _trichXuatToaDo(thongTin, "sb");
    leAnToan.trai = _trichXuatToaDo(thongTin, "sl");
    leAnToan.phai = _trichXuatToaDo(thongTin, "sr");
  }

}
