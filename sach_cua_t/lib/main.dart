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
import 'package:man_hinh_ung_dung/luong_man_hinh.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_truot.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_xep_lop.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_mo_dau.dart';
import 'package:sach_cua_t/models/database.dart';

void main() {
  CoSoDuLieu().khoiDau().then((value) => runApp(MainApp()));
}

class MainApp extends StatelessWidget {
  static final LuongManHinh luongMHGoc = LuongManHinh();

  MainApp({super.key}) {
    luongMHGoc.widgetCuaManHinh = WidgetLuongManHinhXepLop(dieuKhienManHinh: luongMHGoc);
    final LuongManHinh luongChinh = LuongManHinh();
    luongChinh.widgetCuaManHinh = WidgetLuongManHinhTruot(dieuKhienManHinh: luongChinh);
    final DieuKhienManHinhMoDau dkMhMoDau = DieuKhienManHinhMoDau();
    luongChinh.themManHinh(manHinh: dkMhMoDau);
    luongMHGoc.themManHinh(manHinh: luongChinh);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: luongMHGoc.xayDungGiaoDienNguoiDung(context, null),
    );
  }

}
