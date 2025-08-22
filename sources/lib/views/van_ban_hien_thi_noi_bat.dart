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

/// Hiển thị nổi bật (tô nền) các đoạn [vanBanNoiBat] có trong [vanBanDayDu]
class VanBanHienThiNoiBat extends StatelessWidget {

  /// Văn bản nổi bật
  final String vanBanNoiBat;
  /// Văn bản đầy đủ
  final String vanBanDayDu;

  /// Constructor
  const VanBanHienThiNoiBat({super.key, required this.vanBanDayDu, required this.vanBanNoiBat});

  /// Xây dựng các đoạn văn bản
  List<Text> _xayDungCacDoanVanBan() {
    List<Text> ketQua = [];
    if (vanBanNoiBat.isEmpty) {
      ketQua.add(Text(vanBanDayDu));
      return ketQua;
    }
    String buffer = vanBanDayDu;
    String bufferCmp = buffer.toLowerCase();
    String gocCmp = vanBanNoiBat.toLowerCase();
    while (buffer.isNotEmpty) {
      final int viTri = bufferCmp.indexOf(gocCmp);
      if (viTri > 0) {
        ketQua.add(Text(buffer.substring(0, viTri)));
        ketQua.add(Text(vanBanNoiBat, style: const TextStyle(backgroundColor: Colors.yellow)));
        buffer = buffer.substring(viTri + vanBanNoiBat.length);
        bufferCmp = buffer.toLowerCase();
      } else if (viTri == 0) {
        ketQua.add(Text(vanBanNoiBat, style: const TextStyle(backgroundColor: Colors.yellow)));
        buffer = buffer.substring(vanBanNoiBat.length);
        bufferCmp = buffer.toLowerCase();
      } else {
        ketQua.add(Text(buffer));
        buffer = "";
      }
    }
    return ketQua;
  }

  @override
  Widget build(BuildContext context) => Row(children: _xayDungCacDoanVanBan());

}
