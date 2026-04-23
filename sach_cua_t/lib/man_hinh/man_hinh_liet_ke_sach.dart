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
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/truong_sach.dart';

/// Điều khiển màn hình liệt kê sách
class DieuKhienManHinhLietKeSach extends DieuKhienManHinh {

  /// Bộ đệm Văn bản hiển thị
  final BoDemVbht demVbht = BoDemVbht();
  final ScrollController _dkCuon = ScrollController();

  final List<Sach> dsSach;

  DieuKhienManHinhLietKeSach({required this.dsSach}) {
    widgetCuaManHinh = _ManHinhLietKeSach(dieuKhienManHinh: this);
  }

  /// Khi nhấn Tiêu đề của màn hình
  void _khiNhanTieuDeMh() {
    _dkCuon.animateTo(0, duration: const Duration(milliseconds: 100), curve: Curves.bounceOut);
  }

  /// Khi nhấn Nút quay lại (<)
  void _khiNhanQuayLai() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  /// Khi nhấn vào 1 dòng Sách
  void _khiNhanSach(Sach sach) {
    final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach(maSach: sach.maSo, chiDoc: true);
    luongManHinh?.themManHinh(manHinh: mhSach);
  }

}

class _ManHinhLietKeSach extends WidgetTinhCuaDieuKhienManHinh<DieuKhienManHinhLietKeSach> {

  _ManHinhLietKeSach({required super.dieuKhienManHinh});

  @override
  Widget build(BuildContext context) => ManHinhCoSo(
    tieuDe: Vbht.tuKhoa(TK.thongKe, dem: dieuKhienManHinh.demVbht),
    khiNhanQuayLai: dieuKhienManHinh._khiNhanQuayLai,
    khiNhanTieuDe: dieuKhienManHinh._khiNhanTieuDeMh,
    noiDung: ListView(
      controller: dieuKhienManHinh._dkCuon,
      padding: const EdgeInsets.all(5),
      children: _xayDungCacWidgetCon()
    )
  );

  List<Widget> _xayDungCacWidgetCon() {
    return dieuKhienManHinh.dsSach.map((muc) => _xayDungDongKetQuaSach(muc)).toList();
  }

  Widget _xayDungDongKetQuaSach(Sach sach) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    child: TruongSach(
      sach: sach,
      thongTinCanHienThi: TruongSach.thongTinMacDinh(),
    ), onTap: () => dieuKhienManHinh._khiNhanSach(sach)
  );

}
