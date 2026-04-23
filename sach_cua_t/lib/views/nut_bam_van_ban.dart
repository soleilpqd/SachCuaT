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
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Nút bấm văn bản có điều khiển trạng thái khả dụng
class NutBamVanBan extends GiaoDienCoSo<DieuKhienCoSo> {

  /// Văn bản hiển thị
  final Vbht vanBan;
  /// Hàm xử lý khi nhấn
  final void Function()? khiNhan;

  const NutBamVanBan({super.key, required this.vanBan, this.khiNhan, super.dieuKhien});

  @override
  State<StatefulWidget> createState() => _TrangThaiNutBamVanBan();

}

class _TrangThaiNutBamVanBan extends TrangThaiCoSo<NutBamVanBan> {

  @override
  Widget build(BuildContext context) {
    final bool khaDung = widget.dieuKhien?.khaDung ?? true;
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    return TextButton(
      onPressed: khaDung ? widget.khiNhan : null,
      style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(khaDung ? phongCach.mauChinh : phongCach.mauNoiDungKhoaNen)),
      child: VbhtWidget(coChu: CoChu.binhThuong, text: widget.vanBan)
    );
  }

}
