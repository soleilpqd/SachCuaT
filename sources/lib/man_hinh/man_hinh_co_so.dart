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
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Phần Navigation Bar dùng chung cho tất cả các màn hình.
class ManHinhCoSo extends StatelessWidget {

  /// Tiêu đề
  final Vbht tieuDe;
  /// Nút trái
  final Widget? nutTrai;
  /// Nút phải
  final Widget? nutPhai;
  /// Phần chính bên dưới Navigation Bar
  final Widget noiDung;
  /// Điều khiển nút quay lại (bỏ qua nếu `nutTrai != null`)
  final DieuKhienCoSo? dkNutQuayLai;
  /// Hàm xử lý khi nhấn nút quay lại (bỏ qua nếu `nutTrai != null`)
  final Function()? khiNhanQuayLai;

  const ManHinhCoSo({super.key, required this.tieuDe, this.nutTrai, this.nutPhai, required this.noiDung, this.dkNutQuayLai, this.khiNhanQuayLai});

  @override
  Widget build(BuildContext context) {
    Widget? nTrai = nutTrai;
    if (nTrai == null && khiNhanQuayLai != null) {
      nTrai = _taoNutQuayLai();
    }
    return Scaffold(
        appBar: AppBar(
          title: VbhtWidget(text: tieuDe),
          actions: nutPhai != null ? [nutPhai!] : null,
          leading: nTrai
        ),
        body: noiDung
      );
  }

  Widget _taoNutQuayLai() => NutBamBieuTuong(icon: Icons.arrow_back, khiNhan: khiNhanQuayLai, dieuKhien: dkNutQuayLai);

}
