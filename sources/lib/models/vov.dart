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

enum KieuThongBao {
  themMoiSach,
  capNhatSach,
  xoaSach,
  themViTri,
  capNhatViTri,
  xoaViTri,
  lichSuTruyCap;
}

/// Cơ quan theo dõi thay đổi dữ liệu
class DaiPhatThanh with ChangeNotifier {

  KieuThongBao? _kieu;
  int? _maDL;

  DaiPhatThanh._internal();

  static final DaiPhatThanh duyNhat = DaiPhatThanh._internal();

  KieuThongBao? get thongBao => _kieu;
  int? get maDuLieu => _maDL;

  void phatThongBao(KieuThongBao kieu, int? maDL) {
    _kieu = kieu;
    _maDL = maDL;
    notifyListeners();
  }

}