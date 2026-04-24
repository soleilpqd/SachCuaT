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
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/utils/common.dart';

class DieuKhienManHinhKhoiDong extends DieuKhienManHinh {

  DieuKhienManHinhKhoiDong() {
    widgetCuaManHinh = _ManHinhKhoiDong();
  }

}

class _ManHinhKhoiDong extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final Widget anh = LinhTinh.taoWidgetAnh(LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.assets, duongDan: "assets/book.jpg"));
    return Container(
      color: Colors.white,
      child: Center(child: anh)
    );
  }

}
