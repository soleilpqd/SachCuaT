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
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_tieu_de.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';

/// Thuộc tính trường bật/tắt (checkbox)
enum ThuocTinhTruongBatTat {
  /// Giá trị
  giaTri;
}

/// Điều khiển trường (dòng) checkbox
class DieuKhienTruongBatTat extends DieuKhienCoSo {

  /// CONSTRUCTOR
  DieuKhienTruongBatTat({
    bool giaTri = false,
    super.khaDung,
    super.laDieuKhienMoi
  }) : super(
    thuocTinhBanDau: {
      ThuocTinhTruongBatTat.giaTri.name: giaTri
    }
  );

  @override
  List<String> dsThuocTinhGiaTri() => [ThuocTinhTruongBatTat.giaTri.name];

  @override
  List<String> dsThuocTinh() => ThuocTinhTruongBatTat.values.chuyenDoiSangDS(khac: super.dsThuocTinh());

  /// Giá trị
  bool get giaTri => this[ThuocTinhTruongBatTat.giaTri.name] as bool;
  /// Giá trị
  set giaTri(bool gt) => this[ThuocTinhTruongBatTat.giaTri.name] = gt;

}

/// Trường bật/tắt (checkbox)
class TruongBatTat extends GiaoDienCoSo<DieuKhienTruongBatTat> {

  /// Tiêu đề
  final Vbht tieuDe;
  final MainAxisAlignment sapXep;
  /// Đảo chiều (thứ tự) hiển thị tiêu đề và ô kiểm
  final bool daoChieu;

  /// CONSTRUCTOR
  const TruongBatTat({
    super.key,
    required this.tieuDe,
    required DieuKhienTruongBatTat trinhDieuKhien,
    this.sapXep = MainAxisAlignment.spaceBetween,
    this.daoChieu = false
  }) : super(dieuKhien: trinhDieuKhien);

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongBatTat();

}

class _TrangThaiTruongBatTat extends TrangThaiCoSo<TruongBatTat> {

  @override
  Widget build(BuildContext context) {
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    final Color mainColor = (widget.dieuKhien?.khaDung ?? true) ? phongCach.mauChinh : phongCach.mauNoiDungKhoaNen;
    List<Widget> dsCacO = [
      NutBamTieuDe(
        tieuDe: widget.tieuDe,
        khaDung: widget.dieuKhien!.khaDung,
        khiNhan: widget.dieuKhien!.khaDung ? _khiNhanTieuDe : null
      ),
      Checkbox(
        value: widget.dieuKhien!.giaTri,
        activeColor: mainColor,
        side: BorderSide(
          color: mainColor,
          width: 2
        ),
        onChanged: widget.dieuKhien!.khaDung
        ? (value) {
          if (value != null) {
            widget.dieuKhien!.giaTri = value;
          }
        }
        : null
      )
    ];
    return Row(
      mainAxisAlignment: widget.sapXep,
      children: widget.daoChieu ? dsCacO.reversed.toList() : dsCacO,
    );
  }

  void _khiNhanTieuDe() {
    widget.dieuKhien?.giaTri = !(widget.dieuKhien?.giaTri ?? false);
  }

}
