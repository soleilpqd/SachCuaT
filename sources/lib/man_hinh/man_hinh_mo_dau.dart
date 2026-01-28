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
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';

class DieuKhienManHinhMoDau extends DieuKhienManHinh {

  DieuKhienManHinhMoDau() {
    widgetCuaManHinh = _ManHinhMoDau(dkMh: this);
  }

  /// Khi nhấn nút Thêm sách
  void _khiNhanThemSach() {
    final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach();
    luongManHinh?.themManHinh(manHinh: mhSach);
  }

  DieuKhienManHinhTuDuoiDay? _dkHopThoaiChonSach;

  /// Khi nhấn nút Tìm kiếm
  void _khiNhanTimKiem() {
    // HopThoai.hienThiHopThoaiThongBao(
    //   noiDung: Vbht.trucTiep("Thông báo dài loằng ngoằng. Xin chào. Tạm biệt!"),
    //   nhanCacNut: [Vbht.tuKhoa(TK.dong), Vbht.tuKhoa(TK.luu)],
    //   khiDong: (stt, nhan) => print("STT: $stt; Nhan: ${nhan.vanBan}")
    // );
    // _dkHopThoaiChonSach = HopThoai.hienThiHopThoaiTuDuoiDay(
    //   noiDung: Container(
    //     color: Colors.red,
    //     child: Center(child: TextButton(onPressed: _dongHopThoaiChonSach, child: const Text("CLOSE"))),
    //   ),
    //   khiDong: _dongHopThoaiChonSach
    // );
  }

    void _dongHopThoaiChonSach() {
    if (_dkHopThoaiChonSach != null) {
      _dkHopThoaiChonSach!.luongManHinh?.loaiManHinh(manHinh: _dkHopThoaiChonSach!);
      _dkHopThoaiChonSach = null;
    }
  }

}

class _ManHinhMoDau extends StatelessWidget {

  final DieuKhienManHinhMoDau dkMh;

  const _ManHinhMoDau({required this.dkMh});

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(TK.sachCuaT),
      nutTrai: IconButton(onPressed: dkMh._khiNhanThemSach, icon: const Icon(Icons.add)),
      nutPhai: IconButton(onPressed: dkMh._khiNhanTimKiem, icon: const Icon(Icons.search)),
      noiDung: const Center(child: Text("Hello!"))
    );
  }

}
