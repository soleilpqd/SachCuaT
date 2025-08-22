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

/// Thuộc tính một mẩu giao diện
enum ThuocTinhMotMauGiaoDien {
  /// Giá trị
  giaTri;
}

/// Điều khiển một mẩu giao diện.
/// Cập nhật lại state khi thay đổi giá trị thuộc tính của điều khiển.
class DieuKhienMotMauGiaoDien<T> extends DieuKhienCoSo {

  /// CONSTRUCTOR
  DieuKhienMotMauGiaoDien({required T giaTri}) : super(thuocTinhBanDau: {ThuocTinhMotMauGiaoDien.giaTri.name: giaTri});

  /// Giá trị
  bool get giaTri => this[ThuocTinhMotMauGiaoDien.giaTri.name] as bool;
  /// Giá trị
  set giaTri(bool gt) => this[ThuocTinhMotMauGiaoDien.giaTri.name] = gt;

  @override
  List<String> dsThuocTinh() => ThuocTinhMotMauGiaoDien.values.chuyenDoiSangDS(khac: super.dsThuocTinh());

  // Không xử lý `daThayDoi`

}

/// Stateful Widget đơn giản trong đó việc thay đổi state được điều khiền từ bên ngoài
class MotMauGiaoDien<T> extends GiaoDienCoSo<DieuKhienMotMauGiaoDien> {

  /// CONSTRUCTOR
  const MotMauGiaoDien({super.key, required DieuKhienMotMauGiaoDien dk, required this.builder}) : super(dieuKhien: dk);
  /// Hàm xây dựng nội dung của widget (context, giá trị trạng thái, khả dụng)
  final Widget Function(BuildContext, T?, bool) builder;

  @override
  State<StatefulWidget> createState() => _TrangThaiMotMauGiaoDien();

}

class _TrangThaiMotMauGiaoDien extends TrangThaiCoSo<MotMauGiaoDien> {

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.dieuKhien?.giaTri, widget.dieuKhien?.khaDung ?? true);
  }

}
