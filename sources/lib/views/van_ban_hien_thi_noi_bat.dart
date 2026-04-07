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
  final TextOverflow tuDongCat;
  final Color mauNen;

  /// Constructor
  const VanBanHienThiNoiBat({super.key, required this.vanBan, this.tuDongCat = TextOverflow.ellipsis, this.mauNen = Colors.yellow});

  /// Xây dựng các đoạn văn bản
  List<TextSpan> _xayDungCacDoanVanBan() {
    List<TextSpan> ketQua = [];
    TextSpan doanVb = const TextSpan();

    if (vanBan.dsViTriKd.isEmpty) {
      doanVb = TextSpan(text: vanBan.vanBanDayDu);
      ketQua.add(doanVb);
      return ketQua;
    }
    int vtHt = 0;
    for (final vt in vanBan.dsViTriKd) {
      if (vt.$1 > vtHt) {
        doanVb = TextSpan(text: vanBan.vanBanDayDu.substring(vtHt, vt.$1));
        ketQua.add(doanVb);
      }
      vtHt = vt.$1 + vt.$2;
      doanVb = TextSpan(text: vanBan.vanBanDayDu.substring(vt.$1, vtHt), style: TextStyle(backgroundColor: mauNen));
      ketQua.add(doanVb);
    }
    if (vtHt < vanBan.vanBanDayDu.length) {
      doanVb = TextSpan(text: vanBan.vanBanDayDu.substring(vtHt));
      ketQua.add(doanVb);
    }
    return ketQua;
  }

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> cacDoan = _xayDungCacDoanVanBan();
    final TextSpan doanChinh = TextSpan(
      children: cacDoan,
      style: const TextStyle(
        color: Colors.black
      )
    );
    return RichText(text: doanChinh, overflow: tuDongCat);
  }

}
