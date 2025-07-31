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
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/models/vov.dart';
import 'package:sach_cua_t/models/vtv.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

class ManHinhSach extends StatefulWidget {

  static const String tenManHinh = "ManHinhSach";

  final int? maSach;

  const ManHinhSach(this.maSach, {super.key});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhSach();

}

class _TrangThaiManHinhSach extends State<ManHinhSach> with KhuonMauQuanLyManHinh {

  @override
  String get tenManHinh => ManHinhSach.tenManHinh;

  final TruongVanBan _tenSach = TruongVanBan(tieuDe: "Tên sách");

  @override
  void initState() {
    super.initState();
    _tenSach.khiTrangThaiNhapThayDoi = _khiTrangThaiNhapTenSachThayDoi;
  }

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: _xacDinhTieuDe(),
      nutTrai: IconButton(onPressed: _khiNhanThoat, icon: const Icon(Icons.arrow_back)),
      nutPhai: IconButton(onPressed: _khiNhanLuu, icon: const Icon(Icons.save)),
      noiDung: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          _tenSach.build(
            context,
            accesoryWidget: TextButton(
              onPressed: () {
                print("DEMO ${_tenSach.text}");
                _khiNhatNutQuetISBN();
                LinhTinh.dungNhapVanBan();
              },
              child: Text("Button1")
            )
          ),
          const TruongTieuDe(tieuDeChinh: "Nhập thông tin", tieuDePhu: "Chi tiết")
        ]
      )
    );
  }

  // Xử lý tác nhân người dùng

  void _khiNhanLuu() {
    print("Nhan Luu");
    DaiPhatThanh.duyNhat.phatThongBao(KieuThongBao.themMoiSach, 1);
    pop();
  }

  void _khiNhanThoat() {
    pop();
  }

  void _khiTrangThaiNhapTenSachThayDoi(bool coTheNhap) {
    print("TRANG THAI NHAP TEN SACH $coTheNhap");
  }

  void _khiNhatNutQuetISBN() async {
    final String? maISBN = await HeThongMay.duyNhat.quetMaISBN();
    if (maISBN != null) {
      _tenSach.text = maISBN;
    }
  }

  // Xử lý nội bộ

  String _xacDinhTieuDe() {
    return "Tiêu đề sách ở đây | Sách mới";
  }

}