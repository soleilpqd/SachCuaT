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
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';

/// Thuộc tính trường nút bấm thanh điều hướng
enum ThuocTinhTruongNutBamThanhDieuHuong {
  /// Danh sách nút
  dsNut
}

/// Điều khiển trường nút bấm thanh điều hướng
class DieuKhienTruongNutBamThanhDieuHuong extends DieuKhienCoSo {

  DieuKhienTruongNutBamThanhDieuHuong({super.khaDung, super.laDieuKhienMoi, List<NutBamBieuTuong>? dsNut}) :
    super(thuocTinhBanDau: {ThuocTinhTruongNutBamThanhDieuHuong.dsNut.name: dsNut ?? []});

  @override
  List<String> dsThuocTinhGiaTri() => [ThuocTinhTruongNutBamThanhDieuHuong.dsNut.name];

  @override
  List<String> dsThuocTinh() => ThuocTinhTruongNutBamThanhDieuHuong.values.chuyenDoiSangDS(khac: super.dsThuocTinh());

  List<NutBamBieuTuong> get dsNut => this[ThuocTinhTruongNutBamThanhDieuHuong.dsNut.name] as List<NutBamBieuTuong>;
  set dsNut(List<NutBamBieuTuong> cacNut) => this[ThuocTinhTruongNutBamThanhDieuHuong.dsNut.name] = cacNut;

}

/// Trường nút bấm thanh điều hướng
class TruongNutBamThanhDieuHuong extends GiaoDienCoSo<DieuKhienTruongNutBamThanhDieuHuong> {

  const TruongNutBamThanhDieuHuong({super.key, required DieuKhienTruongNutBamThanhDieuHuong dieuKhien}) : super(dieuKhien: dieuKhien);

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongNutBamThanhDieuHuong();

}

/// Trạng thái trường nút bấm thanh điều hướng
class _TrangThaiTruongNutBamThanhDieuHuong extends TrangThaiCoSo<TruongNutBamThanhDieuHuong> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.dieuKhien?.dsNut ?? [],
    );
  }
}
