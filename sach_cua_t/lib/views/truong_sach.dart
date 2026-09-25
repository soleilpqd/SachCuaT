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

/// Trường thông tin sách cẩn hiển thị
enum ThongTinSachDeHienThi {
  tenSach,
  isbn,
  danhDau,
  tacGia,
  dichGia,
  nxb,
  soTap,
  nhan,
  viTri,
  nhieuTap
}

/// Thông tin sách cần hiển thị
class ThongTinHienThiTruongSach {
  /// Trường thông tin
  final ThongTinSachDeHienThi truong;
  /// Cần làm nổi bật từ khoá?
  final List<String>? tuKhoaNoiBat;
  /// Chế độ làm nổi bật chính hay phụ
  final bool laNoiBatChinh;

  ThongTinHienThiTruongSach({required this.truong, this.tuKhoaNoiBat, this.laNoiBatChinh = true});

}

class TruongSach extends StatelessWidget {

  static List<ThongTinHienThiTruongSach> thongTinMacDinh() => [
    ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.tenSach),
    ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.tacGia),
    ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.dichGia),
    ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.nxb)
  ];

  final Sach sach;
  final List<ThongTinHienThiTruongSach> thongTinCanHienThi;

  const TruongSach({super.key, required this.sach, required this.thongTinCanHienThi});

  @override
  Widget build(BuildContext context) {
    String soTap = "";
    final bool hienThiSoTap = thongTinCanHienThi.indexWhere((element) => element.truong == ThongTinSachDeHienThi.soTap) >= 0;
    if (hienThiSoTap && sach.tap != null && sach.tap! > 0) {
      soTap = "#${sach.tap!}";
    }
    UiImage? hinhAnh;
    if (sach.hinhThuNho != null) {
      hinhAnh = LinhTinh.taoWidgetAnh(sach.hinhThuNho!);
    } else {
      hinhAnh = LinhTinh.taoWidgetAnh(LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.assets, duongDan: "assets/book.jpg"));
    }
    List<Widget> children = [];
    for (final muc in thongTinCanHienThi) {
      String giaTri =
      switch (muc.truong) {
        ThongTinSachDeHienThi.tenSach => sach.ten,
        ThongTinSachDeHienThi.isbn => sach.isbn,
        ThongTinSachDeHienThi.tacGia => sach.tacGia.join("; "),
        ThongTinSachDeHienThi.dichGia => sach.dichGia.join("; "),
        ThongTinSachDeHienThi.nxb => sach.nhaXuatBan.join("; "),
        ThongTinSachDeHienThi.soTap => soTap,
        ThongTinSachDeHienThi.danhDau => sach.danhDau.map((muc) => muc.noiDung).join("; "),
        ThongTinSachDeHienThi.nhan => sach.nhan.entries.map((e) => "${e.key}: ${e.value}").join("; "),
        ThongTinSachDeHienThi.viTri => sach.viTri.join("; "),
        ThongTinSachDeHienThi.nhieuTap => sach.nhieuTap ?? ""
      };
      if (giaTri.isNotEmpty) {
        children.add(VanBanHienThiNoiBat(
          vanBan: VanBanNoiBat(
            vanBanDayDu: giaTri,
            vanBanNoiBat: muc.tuKhoaNoiBat ?? []
          ),
          danhDauChinh: muc.laNoiBatChinh
        ));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.directional(top: 2, bottom: 2),
          child: Container(
            width: 100,
            height: 100,
            color: Color(0xFFDEDEDE),
            child: hinhAnh
          )),
        const SizedBox(width: 5),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
        ))
      ]
    );
  }

}