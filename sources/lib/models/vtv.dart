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

/// Khuôn mẫu quản lý màn hình
mixin KhuonMauQuanLyManHinh {
  /// Tên (mã) màn hình
  String get tenManHinh;
  /// Context
  BuildContext get context;

  /// Chuyển sang màn hình tiếp
  void push(String tenManHinhTiep, Widget manHinhTiep) {
    DaiTruyenHinh.duyNhat._themManHinh(tenManHinhTiep);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => manHinhTiep));
  }

  /// Quay về màn hình trước
  void pop() {
    DaiTruyenHinh.duyNhat._loaiManHinh(tenManHinh);
    Navigator.of(context).pop();
  }

}

/// Cơ quan quản lý, theo dõi luồng di chuyển màn hình.
/// Các màn hình phải triển khai theo KhuonMauManHinh (di chuyển màn hình dùng push và pop của mixin này).
/// Các đối tượng có thể theo dõi `DaiTruyenHinh` để bắt sự kiện thay đổi màn hình,
/// sử dụng các thuộc tính `manHinhHienTai` và `manHinhTruoc` để xác định việc di chuyển màn hình.
class DaiTruyenHinh extends ChangeNotifier {

  DaiTruyenHinh._internal();
  /// Singleton
  static final DaiTruyenHinh duyNhat = DaiTruyenHinh._internal();

  final List<String> _dsManHinh = [];
  String _manHinhTruoc = "";

  /// Tên màn hình hiện tại
  String get manHinhHienTai => _dsManHinh.isNotEmpty ? _dsManHinh.last : "";
  /// Tên màn hình trước khi chuyển sang màn hình hiện tại
  /// (bao gồm cả trường hợp chuyển mới hay chuyển về)
  String get manHinhTruoc => _manHinhTruoc;

  /// Thêm màn hình
  void _themManHinh(String ten) {
    _manHinhTruoc = _dsManHinh.isNotEmpty ? _dsManHinh.last : "";
    _dsManHinh.add(ten);
    notifyListeners();
  }

  /// Loại màn hình
  void _loaiManHinh(String ten) {
    if (_dsManHinh.isNotEmpty) {
      if (_dsManHinh.last == ten) {
        _manHinhTruoc = _dsManHinh.removeLast();
        notifyListeners();
      } else {
        throw Exception("Màn hình `$ten` không phải là MH hiện tại. DS: $_dsManHinh.");
      }
    } else {
      throw Exception("Danh sách màn hình rỗng. Không thể loại bỏ `$ten`.");
    }
  }

  /// Đặt màn hình đầu tiên
  void datManHinhDauTien(String ten) {
    _manHinhTruoc = "";
    _dsManHinh.clear();
    _dsManHinh.add(ten);
  }

  /// Đổi màn hình
  void doiManHinh(String mhTruoc, String mhSau) {
    _loaiManHinh(mhTruoc);
    _themManHinh(mhSau);
  }

}