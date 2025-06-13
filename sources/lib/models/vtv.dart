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

mixin KhuonMauQuanLyManHinh {
  String get tenManHinh;
  BuildContext get context;

  void push(String tenManHinhTiep, Widget manHinhTiep) {
    DaiTruyenHinh.duyNhat._themManHinh(tenManHinhTiep);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => manHinhTiep));
  }

  void pop() {
    DaiTruyenHinh.duyNhat._loaiManHinh(tenManHinh);
    Navigator.of(context).pop();
  }

}

/// Cơ quan quản lý, theo dõi luồng di chuyển màn hình
class DaiTruyenHinh extends ChangeNotifier {

  DaiTruyenHinh._internal();

  static final DaiTruyenHinh duyNhat = DaiTruyenHinh._internal();

  final List<String> _dsManHinh = [];
  String _manHinhTruoc = "";

  String get manHinhHienTai => _dsManHinh.isNotEmpty ? _dsManHinh.last : "";
  String get manHinhTruoc => _manHinhTruoc;

  void _themManHinh(String ten) {
    _manHinhTruoc = _dsManHinh.isNotEmpty ? _dsManHinh.last : "";
    _dsManHinh.add(ten);
    notifyListeners();
  }

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

  void datManHinhDauTien(String ten) {
    _manHinhTruoc = "";
    _dsManHinh.clear();
    _dsManHinh.add(ten);
  }

  void doiManHinh(String mhTruoc, String mhSau) {
    _loaiManHinh(mhTruoc);
    _themManHinh(mhSau);
  }

}