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

import 'package:sach_cua_t/views/truong_van_ban.dart';

/// Class test, không có tính ứng dụng
class GoiYSo extends GoiYVanBan {

  @override
  Future<List<String>> timKiemGoiY(String dauVao, TruongVanBan widget) async {
    List<String> ketQua = [];
    if (widget.cauHinh.soKyTuToiDa != null && dauVao.length >= widget.cauHinh.soKyTuToiDa!) {
      return ketQua;
    }
    for (var so = 0; so <= 9; so += 1) {
      ketQua.add("$dauVao$so");
    }
    return ketQua;
  }

  @override
  bool tiepTucGoiY(String dauVao, TruongVanBan widget) {
    if (widget.cauHinh.soKyTuToiDa != null && dauVao.length >= widget.cauHinh.soKyTuToiDa!) {
      return false;
    }
    return true;
  }

}
