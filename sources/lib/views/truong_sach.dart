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
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/vanbannoibat.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_noi_bat.dart';

class TruongSach extends StatelessWidget {

  final Sach sach;
  final String? tuKhoaNoiBat;
  final bool hienThiSoTap;

  const TruongSach({super.key, required this.sach, required this.hienThiSoTap, this.tuKhoaNoiBat});

  @override
  Widget build(BuildContext context) {
    final String tenSach = sach.ten;
    final String tenTacGia = sach.tacGia.join("; ");
    final String tenDichGia = sach.dichGia.join("; ");
    final String tenNXB = sach.nhaXuatBan.join("; ");
    String soTap = "";
    if (hienThiSoTap && sach.tap != null && sach.tap! > 0) {
      soTap = "#${sach.tap!}";
    }
    String vbNb = tuKhoaNoiBat ?? "";
    UiImage? hinhAnh;
    if (sach.hinhThuNho != null) {
      hinhAnh = LinhTinh.taoWidgetAnh(sach.hinhThuNho!);
    }
    List<Widget> children = [VanBanHienThiNoiBat(vanBan: VanBanNoiBat(vanBanDayDu: tenSach, vanBanNoiBat: vbNb))];
    if (soTap.isNotEmpty) {
      children.add(Text(soTap));
    }
    children.addAll([
      VanBanHienThiNoiBat(vanBan: VanBanNoiBat(vanBanDayDu: tenTacGia, vanBanNoiBat: vbNb)),
      VanBanHienThiNoiBat(vanBan: VanBanNoiBat(vanBanDayDu: tenDichGia, vanBanNoiBat: vbNb)),
      VanBanHienThiNoiBat(vanBan: VanBanNoiBat(vanBanDayDu: tenNXB, vanBanNoiBat: vbNb))
    ]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 100, height: 100, color: Colors.grey, child: hinhAnh),
        const SizedBox(width: 5),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
        ))
      ]
    );
  }

}