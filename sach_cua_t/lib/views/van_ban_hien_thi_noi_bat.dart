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
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';

/// Hiển thị nổi bật (tô nền) các đoạn [vanBanNoiBat] có trong [vanBanDayDu]
class VanBanHienThiNoiBat extends StatelessWidget {

  /// Văn bản nổi bật
  final VanBanNoiBat vanBan;
  final TextOverflow tuDongCat;
  final bool danhDauChinh;

  /// Constructor
  const VanBanHienThiNoiBat({super.key, required this.vanBan, this.tuDongCat = TextOverflow.ellipsis, this.danhDauChinh = true});

  /// Xây dựng các đoạn văn bản
  List<TextSpan> _xayDungCacDoanVanBan() {
    List<TextSpan> ketQua = [];
    TextSpan doanVb = const TextSpan();
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
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
      doanVb = TextSpan(
        text: vanBan.vanBanDayDu.substring(vt.$1, vtHt),
        style: TextStyle(backgroundColor: danhDauChinh ? phongCach.mauDanhDauChinh : phongCach.mauDanhDauPhu)
      );
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
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    final TextSpan doanChinh = TextSpan(
      children: cacDoan,
      style: TextStyle(
        color: phongCach.mauNoiDungNen,
        fontFamily: phongCach.tenFont,
        fontSize: phongCach.coFontThuong
      )
    );
    return RichText(text: doanChinh, overflow: tuDongCat);
  }

}
