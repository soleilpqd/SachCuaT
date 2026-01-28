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
import 'package:sach_cua_t/views/truong_tieu_de.dart';

/// Điều khiển danh sách hiển thị
class DieuKhienDanhSachHienThi {

  /// Số lượng phân đoạn
  final int Function() soLuongPhanDoan;
  /// Số mục của phân đoạn [doan]
  final int Function(int doan) soMucCuaPhanDoan;
  /// TruongTieuDe tiêu đề cho đoạn [doan]
  final TruongTieuDe? Function(int doan) tieuDeChoDoan;
  /// Các widget cho phân đoạn [doan]. Nếu kết quả khác null thì bỏ qua `soMucCuaPhanDoan`, `widgetCuaMuc`, `khoangCachPhiaTren`, `khoangCachPhiaDuoi`
  final List<Widget>? Function(int doan) widgetsCuaCaDoan;
  /// Widget cho mục ở đoạn [doan] dòng [dong]
  final Widget? Function(int doan, int dong) widgetCuaMuc;
  /// Khoảng trống phía trên cho mục ở đoạn [doan] dòng [dong]
  final double? Function(int doan, int dong) khoangCachPhiaTren;
  /// Khoảng trống phái dưới cho mục ở đoạn [doan] dòng [dong]
  final double? Function(int doan, int dong) khoangCachPhiaDuoi;

  _TrangThaiDanhSachHienThi? _doiTuongDieuKhien;

  DieuKhienDanhSachHienThi({
    required this.soLuongPhanDoan,
    required this.soMucCuaPhanDoan,
    required this.tieuDeChoDoan,
    required this.widgetsCuaCaDoan,
    required this.widgetCuaMuc,
    required this.khoangCachPhiaTren,
    required this.khoangCachPhiaDuoi
  });

  void napLaiDanhSach({List<int>? cacPhanDoan}) {
    _doiTuongDieuKhien?.napLai(cacPhanDoan);
  }

  void dispose() {
    _doiTuongDieuKhien = null;
  }

}

class DanhSachHienThi extends StatefulWidget {

  final DieuKhienDanhSachHienThi dieuKhien;

  const DanhSachHienThi({super.key, required this.dieuKhien});

  @override
  State<StatefulWidget> createState() => _TrangThaiDanhSachHienThi();

}

class _TrangThaiDanhSachHienThi extends State<DanhSachHienThi> {

  @override
  void initState() {
    super.initState();
    widget.dieuKhien._doiTuongDieuKhien = this;
  }

  @override
  void didUpdateWidget(covariant DanhSachHienThi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dieuKhien._doiTuongDieuKhien == this) {
      oldWidget.dieuKhien._doiTuongDieuKhien = null;
    }
    widget.dieuKhien._doiTuongDieuKhien = this;
  }

  void napLai(List<int>? cacPhanDoan) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(5),
      children: _xayDungCacWidgetCon()
    );
  }

  List<Widget> _xayDungCacWidgetCon() {
    List<Widget> children = [];
    final int soDoan = widget.dieuKhien.soLuongPhanDoan.call();
    for (int doan = 0; doan < soDoan; doan += 1) {
      final List<Widget>? toanBoWidgets = widget.dieuKhien.widgetsCuaCaDoan.call(doan);
      int soMuc = 0;
      if (toanBoWidgets != null) {
        soMuc = toanBoWidgets.length;
      } else {
        soMuc = widget.dieuKhien.soMucCuaPhanDoan.call(doan);
      }
      if (soMuc == 0) {
        continue;
      }
      final TruongTieuDe? tieuDe = widget.dieuKhien.tieuDeChoDoan.call(doan);
      if (tieuDe != null) {
        children.add(tieuDe);
      }
      if (toanBoWidgets != null) {
        children.addAll(toanBoWidgets);
      } else {
        for (int muc = 0; muc < soMuc; muc += 1) {
          double? khoangTrong = widget.dieuKhien.khoangCachPhiaTren.call(doan, muc);
          if (khoangTrong != null && khoangTrong > 0) {
            children.add(SizedBox(height: khoangTrong));
          }
          final Widget? widMuc = widget.dieuKhien.widgetCuaMuc.call(doan, muc);
          if (widMuc != null) {
            children.add(widMuc);
          }
          khoangTrong = widget.dieuKhien.khoangCachPhiaDuoi.call(doan, muc);
          if (khoangTrong != null && khoangTrong > 0) {
            children.add(SizedBox(height: khoangTrong));
          }
        }
      }
    }
    return children;
  }

}
