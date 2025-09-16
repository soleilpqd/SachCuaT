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

/// Thuộc tính trường trống không
enum ThuocTinhTruongTrongKhong {
  /// Cao
  cao;
}

/// Điều khiển trường trống không
class DieuKhienTruongTrongKhong extends DieuKhienCoSo {

  /// CONSTRUCTOR
  DieuKhienTruongTrongKhong({
    required double cao,
    super.khaDung,
    super.laDieuKhienMoi
  }) : super(
    thuocTinhBanDau: {
      ThuocTinhTruongTrongKhong.cao.name: cao
    }
  );

  @override
  List<String> dsThuocTinhGiaTri() => [ThuocTinhTruongTrongKhong.cao.name];

  @override
  List<String> dsThuocTinh() => ThuocTinhTruongTrongKhong.values.chuyenDoiSangDS(khac: super.dsThuocTinh());

  /// Cao
  double get cao => this[ThuocTinhTruongTrongKhong.cao.name] as double;
  /// Cao
  set cao(double gt) => this[ThuocTinhTruongTrongKhong.cao.name] = gt;

}

/// Trường trống không (thay đổi chiều cao theo điều khiển)
class TruongTrongKhong extends GiaoDienCoSo<DieuKhienTruongTrongKhong> {

   /// CONSTRUCTOR
  const TruongTrongKhong({super.key, required DieuKhienTruongTrongKhong trinhDieuKhien}) : super(dieuKhien: trinhDieuKhien);

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongTrongKhong();

}

class _TrangThaiTruongTrongKhong extends TrangThaiCoSo<TruongTrongKhong> {

  @override
  Widget build(BuildContext context) {
    return Container(height: widget.dieuKhien?.cao);
  }

}
