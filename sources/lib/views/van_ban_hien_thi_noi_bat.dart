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
import 'package:sach_cua_t/models/vanbannoibat.dart';

/// Hiển thị nổi bật (tô nền) các đoạn [vanBanNoiBat] có trong [vanBanDayDu]
class VanBanHienThiNoiBat extends StatelessWidget {

  /// Văn bản nổi bật
  final VanBanNoiBat vanBan;

  /// Constructor
  const VanBanHienThiNoiBat({super.key, required this.vanBan});

  /// Xây dựng các đoạn văn bản
  List<Text> _xayDungCacDoanVanBan() {
    List<Text> ketQua = [];
    if (vanBan.dsViTriKd.isEmpty) {
      ketQua.add(Text(vanBan.vanBanDayDu));
      return ketQua;
    }
    int vtHt = 0;
    for (final vt in vanBan.dsViTriKd) {
      if (vt > vtHt) {
        ketQua.add(Text(vanBan.vanBanDayDu.substring(vtHt, vt)));
      }
      vtHt = vt + vanBan.vanBanNoiBat.length;
      ketQua.add(Text(vanBan.vanBanDayDu.substring(vt, vtHt), style: const TextStyle(backgroundColor: Colors.yellow)));
    }
    if (vtHt < vanBan.vanBanDayDu.length) {
      ketQua.add(Text(vanBan.vanBanDayDu.substring(vtHt)));
    }
    return ketQua;
  }

  @override
  Widget build(BuildContext context) => Row(children: _xayDungCacDoanVanBan());

}
