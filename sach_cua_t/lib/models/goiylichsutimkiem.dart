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

/// Class test, không có tính ứng dụng
class GoiYLichSuTimKiem extends GoiYVanBan {

  final int soLuongToiDa = 5;
  void Function(String)? khiChonGoiY;
  List<String> _dsTuKhoa = [];

  GoiYLichSuTimKiem() {
    LuuTruCauHinh().layLichSuTimKiem().then((dsTk) => _dsTuKhoa = dsTk);
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
    _dsTuKhoa.remove(tuKhoa);
    _dsTuKhoa.insert(0, tuKhoa);
    LuuTruCauHinh().luuLichSuTimKiem(_dsTuKhoa);
  }

}
