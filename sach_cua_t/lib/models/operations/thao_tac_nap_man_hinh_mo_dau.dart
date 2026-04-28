/*
  Sách của T - Quản lý sách cá nhân
  Copyright © 2026 SoleilPQD

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

import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/operations/thao_tac_nap_sach.dart';

class ThaoTacNapDuLieuManHinhMoDau {

  int tongSoSach = 0;
  final List<Sach> dsDanhDau = [];
  final List<Sach> dsGanDay = [];

  Future<void> napDuLieu() async {
    dsDanhDau.clear();
    dsGanDay.clear();
    final CoSoDuLieu csdl = CoSoDuLieu();
    tongSoSach = await csdl.demTongSoSach();
    if (tongSoSach == 0) {
      return;
    }
    final List<Sach> kqGanDay = await csdl.layDsSachGanDay();
    final List<Sach> kqDanhDau = await csdl.layDanhSachSachDanhDau();
    final List<Sach> kqTongHop = [];
    kqTongHop.addAll(kqDanhDau);
    for (final Sach muc in kqGanDay) {
      final int stt = kqTongHop.indexWhere((phanTu) => phanTu.maSo == muc.maSo);
      if (stt < 0) {
        kqTongHop.add(muc);
      }
    }
    for (final Sach muc in kqTongHop) {
      final ThaoTacNapThongTinSach nap = ThaoTacNapThongTinSach(muc);
      await nap.napThongTin();
    }
    dsDanhDau.addAll(kqDanhDau);
    for (final Sach muc in kqGanDay) {
      final Sach sach = kqTongHop.firstWhere((phanTu) => phanTu.maSo == muc.maSo);
      dsGanDay.add(sach);
    }
  }

  Future<void> xoaDanhDau(int stt) async {
    final Sach sach = dsDanhDau.removeAt(stt);
    await CoSoDuLieu().xoaDanhDau(sach.danhDau.first);
  }

}
