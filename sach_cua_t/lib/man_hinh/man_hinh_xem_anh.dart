/*
  Sách của T - Quản lý sách cá nhân
  Copyright © 2026 SoleilPQD

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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_xep_lop.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/xu_ly_nut_lui_android.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/views/khung_anh.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';

class DieuKhienManHinhXemAnh extends DieuKhienManHinh with XuLyNutLuiAndroid {

  final Uri duongDanAnh;
  late ImageProvider _image;
  final DieuKhienKhungAnh _dkKhungAnh = DieuKhienKhungAnh();

  DieuKhienManHinhXemAnh({required this.duongDanAnh}) {
    thamSoDieuKhienWidgetLuong[WidgetLuongManHinhXepLop.kKeyThamSoChoPhepHoatHinh] = false;
    widgetCuaManHinh = _ManHinhXemAnh(dkMh: this);
    if (duongDanAnh.scheme == PhanLoaiDuongDan.assets.name) {
      _image = AssetImage(duongDanAnh.path);
    } else {
      _image = FileImage(File(duongDanAnh.path));
    }
    _datCauHinhKhungAnh();
  }

  @override
  bool khiNhanNutLuiAndroid() {
    _khiNhanDong();
    return false;
  }

  void _khiNhanDong() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  void _datCauHinhKhungAnh() {
    final TiLeKhungAnh tiLeNho = TiLeKhungAnh(
      tiLe: 1,
      kieu: KieuTiLeKhungAnh.khit,
      coSo: CoSoTiLeKhungAnh.theoKhungHienThi,
      uuTienGoc: true // Cho phép nhỏ hơn khung nếu ảnh nhỏ hơn
    );
    final TiLeKhungAnh tiLeLon = TiLeKhungAnh(
      tiLe: 4,
      kieu: KieuTiLeKhungAnh.khit,
      coSo: CoSoTiLeKhungAnh.theoKhungHienThi,
      uuTienGoc: true
    );
    final TiLeKhungAnh tiLeKhit = TiLeKhungAnh(
      tiLe: 1,
      kieu: KieuTiLeKhungAnh.khit,
      coSo: CoSoTiLeKhungAnh.theoKhungHienThi,
      uuTienGoc: false // bắt buộc khít khung hiển thị
    );
    final TiLeKhungAnh tiLeLap = TiLeKhungAnh(
      tiLe: 1,
      kieu: KieuTiLeKhungAnh.lapDay,
      coSo: CoSoTiLeKhungAnh.theoKhungHienThi,
      uuTienGoc: false
    );
    final TiLeKhungAnh tiLeGoc = TiLeKhungAnh(
      tiLe: 1,
      kieu: KieuTiLeKhungAnh.khit,
      coSo: CoSoTiLeKhungAnh.theoKichThuocGoc,
      uuTienGoc: true
    );
    _dkKhungAnh.datCauHinh(CauHinhCoSoKhungAnh(
      ngang: null, // Tự động
      doc: null, // Tự động
      tiLeThayDoi: [tiLeNho, tiLeLon, tiLeGoc],
      tiLeMoc: [tiLeNho, tiLeKhit, tiLeLap, tiLeLon, tiLeGoc]
    ));
  }

}

class _ManHinhXemAnh extends StatelessWidget {

  final DieuKhienManHinhXemAnh dkMh;

  const _ManHinhXemAnh({required this.dkMh});

  @override
  Widget build(BuildContext context) {
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    return Stack(
      fit: StackFit.expand,
      children: [
        KhungAnh(
          noiDung: UiImage(image: dkMh._image, fit: BoxFit.fill),
          dieuKhien: dkMh._dkKhungAnh
        ),
        Padding(
          padding: EdgeInsetsGeometry.directional(top: 32, end: 20),
          child: Align(
            alignment: AlignmentGeometry.topRight,
            child: NutBamBieuTuong(
              bieuTuong: Icons.fullscreen_exit,
              thuocThanhDieuHuong: false,
              doBongBieuTuong: [
                Shadow(color: phongCach.mauNen, offset: Offset.fromDirection(pi / 4, 3), blurRadius: 20)
              ],
              khiNhan: dkMh._khiNhanDong,
            ),
          )
        )
      ],
    );
  }

}
