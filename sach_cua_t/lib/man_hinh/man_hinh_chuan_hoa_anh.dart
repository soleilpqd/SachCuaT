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
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/nut_bam_tieu_de.dart';

class DieuKhienManHinhChuanHoaAnh extends DieuKhienManHinh {

  DieuKhienManHinhChuanHoaAnh() {
    widgetCuaManHinh = _ManHinhChuanHoa(dkMh: this);
  }

  @override
  void manHinhDuocThemVaoLuong() {
    super.manHinhDuocThemVaoLuong();
    HeThongMay.duyNhat.theoDoiTienTrinhChuanHoaAnh.addListener(_khiCoCapNhatTienTrinh);
  }

  @override
  void manHinhBiLoaiBoKhoiLuong() {
    super.manHinhBiLoaiBoKhoiLuong();
    HeThongMay.duyNhat.theoDoiTienTrinhChuanHoaAnh.removeListener(_khiCoCapNhatTienTrinh);
  }

  void _khiNhanQuayLai() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  void _khiCoCapNhatTienTrinh() {
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  void _khiNhanBatDau() {
    HeThongMay.duyNhat.chuanHoaAnh();
  }

}

class _ManHinhChuanHoa extends StatelessWidget {

  final DieuKhienManHinhChuanHoaAnh dkMh;

  const _ManHinhChuanHoa({required this.dkMh});

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: Vbht.trucTiep("Chuẩn hoá ảnh"),
      khiNhanQuayLai: dkMh._khiNhanQuayLai,
      noiDung: _NoiDungManHinhChuanHoaAnh(dieuKhienManHinh: dkMh)
    );
  }

}

class _NoiDungManHinhChuanHoaAnh extends WidgetCuaDieuKhienManHinh<DieuKhienManHinhChuanHoaAnh> {

  _NoiDungManHinhChuanHoaAnh({required super.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhChuanHoaAnh();

}

class _TrangThaiManHinhChuanHoaAnh extends TrangThaiWidgetCuaDieuKhien<_NoiDungManHinhChuanHoaAnh> {

  @override
  void capNhatGiaoDienCuaManHinh({required DieuKhienManHinh dieuKhienManHinh, ThamSoDieuKhienWidgetManHinh? duLieuDinhKem}) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> thongTin = HeThongMay.duyNhat.theoDoiTienTrinhChuanHoaAnh.thongTinChuanHoaAnh;
    if (thongTin.isEmpty) {
      return Center(child: NutBamTieuDe(
        khaDung: true,
        tieuDe: Vbht.trucTiep("Bắt đầu"),
        khiNhan: widget.dieuKhienManHinh._khiNhanBatDau,
      ));
    }
    return Center(child: Text("${thongTin["stt"]}/${thongTin["tong"]}"));
  }

}
