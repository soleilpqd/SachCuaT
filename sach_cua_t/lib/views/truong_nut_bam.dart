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

/// Trường chỉ xử lý nhấn với Tiêu đề và Biểu tượng
class TruongNutBam extends GiaoDienCoSo<DieuKhienCoSo> {

  /// Hàm xử lý khi nhấn
  final Function() khiNhan;
  /// Tiêu đề
  final Vbht tieuDe;
  /// Hình biểu tượng
  final IconData icon;
  /// Phong cách cần chú ý (Đỏ)
  final bool canChuY;

  const TruongNutBam({
    super.key,
    required this.khiNhan,
    required this.tieuDe,
    required this.icon,
    this.canChuY = false,
    super.dieuKhien
  });

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongNutBam();

}

class _TrangThaiTruongNutBam extends TrangThaiCoSo<TruongNutBam> {

  @override
  Widget build(BuildContext context) {
    final bool khaDung = widget.dieuKhien?.khaDung ?? true;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: Align(
          alignment: AlignmentGeometry.centerRight,
          child: NutBamTieuDe(
            tieuDe: widget.tieuDe,
            khaDung: khaDung,
            canChuY: widget.canChuY,
            khiNhan: khaDung ? widget.khiNhan : null
          ))
        ),
        NutBamBieuTuongTieuDe(
          bieuTuong: widget.icon,
          khaDung: khaDung,
          thuocThanhDieuHuong: false,
          canChuY: widget.canChuY,
          khiNhan: khaDung ? widget.khiNhan : null
        )
      ],
    );
  }

}
