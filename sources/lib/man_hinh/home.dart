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
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_web.dart';
import 'package:sach_cua_t/models/vov.dart';
import 'package:sach_cua_t/models/vtv.dart';

enum MucMenuChinh {
  menuGoc,
  menuTimSach,
  menuViTri,
  menuThongKe,
  menuThongTin;

  static List<MucMenuChinh> TatCaCacMuc() => [
    MucMenuChinh.menuGoc,
    MucMenuChinh.menuTimSach,
    MucMenuChinh.menuViTri,
    MucMenuChinh.menuThongKe,
    MucMenuChinh.menuThongTin
  ];
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with KhuonMauQuanLyManHinh {

  var _trangHienTai = MucMenuChinh.menuGoc;

  @override
  String get tenManHinh => _xacDinhTieuDeMuc(_trangHienTai);

  @override
  void initState() {
    super.initState();
    DaiPhatThanh.duyNhat.addListener(_theoDoiDaiPhatThanh);
    DaiTruyenHinh.duyNhat.datManHinhDauTien(_xacDinhTieuDeMuc(_trangHienTai));
    DaiTruyenHinh.duyNhat.addListener(_theoDoiDaiTruyenHinh);
  }

  @override
  void deactivate() {
    super.deactivate();
    DaiPhatThanh.duyNhat.removeListener(_theoDoiDaiPhatThanh);
    DaiTruyenHinh.duyNhat.removeListener(_theoDoiDaiTruyenHinh);
  }

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: _xacDinhTieuDeMuc(_trangHienTai),
      nutTrai: _xacDinhNutTrai(),
      nutPhai: PopupMenuButton(
        icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.foregroundColor),
        initialValue: _trangHienTai,
        itemBuilder: _taoMenuChinh,
        onSelected: _khiChonMenu
      ),
      noiDung: const Center(child: Text("Hello world"))
    );
  }

  List<PopupMenuEntry<MucMenuChinh>> _taoMenuChinh(BuildContext ctx) {
    final iconColor = Theme.of(context).popupMenuTheme.iconColor;
    List<PopupMenuEntry<MucMenuChinh>> result = [];
    for (final muc in MucMenuChinh.TatCaCacMuc()) {
      result.add(
        PopupMenuItem(
          value: muc,
          child: Row(children: [
            Icon(_xacDinhBieuTuongMuc(muc), color: iconColor),
            const SizedBox(width: 5),
            Text(_xacDinhTieuDeMuc(muc))
          ])
        )
      );
    }
    return result;
  }

  // Xử lý tác nhân người dùng

  void _khiChonMenu(MucMenuChinh muc) {
    print("MENU ${muc}");
    if (_trangHienTai == muc) {
      return;
    }
    setState(() {
      final mhTrc = _xacDinhTieuDeMuc(_trangHienTai);
      _trangHienTai = muc;
      final mhSau = _xacDinhTieuDeMuc(_trangHienTai);
      DaiTruyenHinh.duyNhat.doiManHinh(mhTrc, mhSau);
    });
  }

  void _khiNhanThemSach() {
    push(ManHinhSach.tenManHinh, const ManHinhSach(null));
    // push(ManHinhWeb.tenManHinh, const ManHinhWeb(tieuDe: "Lưu chiểu", url: "https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu"));
  }

  void _khiNhanMenu() {
    print("Nhan Menu");
  }

  void _khiNhanThemViTri() {
    print("Nhan them vi tri");
  }

  void _khiNhanKhoiTaoLai() {
    print("Nhan khoi tao lai");
  }

  // Xử lý nội bộ

  String _xacDinhTieuDeMuc(MucMenuChinh muc) {
    return switch (muc) {
      MucMenuChinh.menuGoc => "Sách của T",
      MucMenuChinh.menuTimSach => "Tìm sách",
      MucMenuChinh.menuViTri => "Vị trí để sách",
      MucMenuChinh.menuThongKe => "Thống kê",
      MucMenuChinh.menuThongTin => "Thông tin ứng dụng"
    };
  }

  IconData _xacDinhBieuTuongMuc(MucMenuChinh muc) {
    return switch (muc) {
      MucMenuChinh.menuGoc => Icons.home,
      MucMenuChinh.menuTimSach => Icons.search,
      MucMenuChinh.menuViTri => Icons.location_city,
      MucMenuChinh.menuThongKe => Icons.calculate,
      MucMenuChinh.menuThongTin => Icons.info
    };
  }

  Widget? _xacDinhNutTrai() {
    return switch (_trangHienTai) {
        MucMenuChinh.menuGoc  => IconButton(onPressed: _khiNhanThemSach, icon: const Icon(Icons.add)),
        MucMenuChinh.menuTimSach =>  IconButton(onPressed: _khiNhanKhoiTaoLai, icon: const Icon(Icons.restart_alt)),
        MucMenuChinh.menuViTri => IconButton(onPressed: _khiNhanThemViTri, icon: const Icon(Icons.add_location)),
        _ => null
    };
  }

  void _theoDoiDaiPhatThanh() {
    print("NOTIF VOV ${DaiPhatThanh.duyNhat.thongBao}, ${DaiPhatThanh.duyNhat.maDuLieu}");
  }

  void _theoDoiDaiTruyenHinh() {
    print("NOTIF VTV ${DaiTruyenHinh.duyNhat.manHinhTruoc} => ${DaiTruyenHinh.duyNhat.manHinhHienTai}");
  }

}
