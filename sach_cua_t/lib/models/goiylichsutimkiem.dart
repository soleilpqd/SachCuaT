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

import 'package:sach_cua_t/models/luutrucauhinh.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

/// Gợi ý từ khoá lịch sử tìm tiếm
class GoiYLichSuTimKiem extends GoiYVanBan {

  final int _soLuongToiDa = 5;
  void Function(String)? khiChonGoiY;
  final List<String> _dsTuKhoa = [];

  GoiYLichSuTimKiem() {
    LuuTruCauHinh().layLichSuTimKiem().then((dsTk) {
      final List<String> lsTk = dsTk.where((test) => test.isNotEmpty).toList();
      while (lsTk.length > _soLuongToiDa) {
        lsTk.removeLast();
      }
      _dsTuKhoa.addAll(lsTk);
    });
  }

  @override
  Future<List<String>> timKiemGoiY(String dauVao, TruongVanBan widget) async {
    List<String> ketQua = _dsTuKhoa.toList();
    ketQua.remove(dauVao);
    return ketQua;
  }

  @override
  void daChonGoiY(String tuKhoa) {
    super.daChonGoiY(tuKhoa);
    khiChonGoiY?.call(tuKhoa);
  }

  void capNhatLichSu(String tuKhoa) {
    if (tuKhoa.isEmpty) {
      return;
    }
    _dsTuKhoa.remove(tuKhoa);
    _dsTuKhoa.insert(0, tuKhoa);
    while (_dsTuKhoa.length > _soLuongToiDa) {
      _dsTuKhoa.removeLast();
    }
    LuuTruCauHinh().luuLichSuTimKiem(_dsTuKhoa);
  }

}
