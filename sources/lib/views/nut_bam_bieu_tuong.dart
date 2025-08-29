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

/// Nút bấm biểu tượng có điều khiển trạng thái khả dụng
class NutBamBieuTuong extends GiaoDienCoSo<DieuKhienCoSo> {

  /// Hình biểu tượng
  final IconData icon;
  /// Màu chính
  final Color mauChinh;
  /// Màu phụ (màu không khả dụng)
  final Color mauPhu;
  /// Hàm xử lý khi nhấn
  final void Function()? khiNhan;

  /// CONSTRUCTOR
  const NutBamBieuTuong({super.key, required this.icon, this.khiNhan, super.dieuKhien, this.mauChinh = Colors.white, this.mauPhu = Colors.grey});

  @override
  State<StatefulWidget> createState() => _TrangThaiNutBamBieuTuong();

}

class _TrangThaiNutBamBieuTuong extends TrangThaiCoSo<NutBamBieuTuong> {

  @override
  Widget build(BuildContext context) {
    final bool khaDung = widget.dieuKhien?.khaDung ?? true;
    return IconButton(
      onPressed: khaDung ? widget.khiNhan : null,
      icon: Icon(widget.icon, color: khaDung ? widget.mauChinh : widget.mauPhu)
    );
  }

}
