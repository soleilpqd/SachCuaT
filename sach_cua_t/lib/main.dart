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
import 'package:flutter/material.dart';
import 'package:man_hinh_ung_dung/luong_man_hinh.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_truot.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_xep_lop.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_khoi_dong.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_mo_dau.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/du_lieu_tam.dart';
import 'package:sach_cua_t/models/xu_ly_nut_lui_android.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  static final LuongManHinh luongMHGoc = LuongManHinh();

  MainApp({super.key}) {
    luongMHGoc.widgetCuaManHinh = WidgetLuongManHinhXepLop(dieuKhienManHinh: luongMHGoc);
    luongMHGoc.themManHinh(manHinh: DieuKhienManHinhKhoiDong());
    _khoiTaoCacDichVu();
  }

  void _khoiTaoCacDichVu() async {
    await CoSoDuLieu().khoiDau();
    await DuLieuTam().khoiDau();
    _khoiTaoHeThongManHinh();
  }

  void _khoiTaoHeThongManHinh() {
    final LuongManHinh luongChinh = LuongManHinh();
    luongChinh.widgetCuaManHinh = WidgetLuongManHinhTruot(dieuKhienManHinh: luongChinh);
    final DieuKhienManHinhMoDau dkMhMoDau = DieuKhienManHinhMoDau();
    luongChinh.themManHinh(manHinh: dkMhMoDau);
    luongMHGoc.ganDanhSachManHinh(danhSachMoi: [luongChinh]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: Colors.transparent,
        child: luongMHGoc.xayDungGiaoDienNguoiDung(context, null)
      ),
    );
  }

  static bool? _xuLyNutLuiAndroidLuongManHinh(LuongManHinh luong) {
    final DieuKhienManHinh? manHinhCuoi = luong.manHinhHienTai;
    if (manHinhCuoi != null) {
      if (manHinhCuoi is XuLyNutLuiAndroid) {
        return (manHinhCuoi as XuLyNutLuiAndroid).khiNhanNutLuiAndroid();
      }
      if (manHinhCuoi is LuongManHinh) {
        return _xuLyNutLuiAndroidLuongManHinh(manHinhCuoi);
      }
    }
    return null;
  }

  static bool? xuLyNutLuiAndroid() => _xuLyNutLuiAndroidLuongManHinh(luongMHGoc);

  static void xuLyTepDuocChiaSe(Iterable<File> dsTep) {
    final DieuKhienManHinh? manHinhCuoi = luongMHGoc.manHinhHienTai;
    if (manHinhCuoi != null && manHinhCuoi == luongMHGoc.danhSachManHinh.first) {
      final LuongManHinh luongChinh = manHinhCuoi as LuongManHinh;
      final DieuKhienManHinh? manHinhChinhCuoi = luongChinh.manHinhHienTai;
      if (manHinhChinhCuoi != null && manHinhChinhCuoi is DieuKhienManHinhSach) {
        manHinhChinhCuoi.xuLyTepDuocChiaSe(dsTep);
      }
    }
  }

}
