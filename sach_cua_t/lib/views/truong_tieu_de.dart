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
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Trường tiêu đề: hiển thị 2 dòng văn bản
///  IN ĐẬM
///  in thường
class TruongTieuDe extends StatelessWidget {

  /// Tiêu đề chính
  final Vbht tieuDeChinh;
  /// Tiêu đề phụ
  final Vbht? tieuDePhu;

  /// CONSTRUCTOR
  const TruongTieuDe({super.key, required this.tieuDeChinh, this.tieuDePhu});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [const SizedBox(height: 10)];
    children.add(
      VbhtWidget(
        text: tieuDeChinh,
        coChu: CoChu.to,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17
        ),
      )
    );
    if (tieuDePhu != null) {
      children.add(
        VbhtWidget(
          text: tieuDePhu!,
          coChu: CoChu.nho,
          style: const TextStyle(fontStyle: FontStyle.italic),
        )
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
    );
  }

}
