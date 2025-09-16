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

import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/vanbannoibat.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

/// Gợi ý từ 1 trường trong CSDL
class GoiYCSDL extends GoiYVanBan {

  final String bang;
  List<VanBanNoiBat> _dsKetQua = [];

  GoiYCSDL({required this.bang});

  @override
  Future<List<String>> timKiemGoiY(String dauVao, TruongVanBan widget) async {
    if (dauVao.isEmpty) {
      return [];
    }
    _dsKetQua = await CoSoDuLieu().timKiemGoiY(bang, dauVao);
    _dsKetQua.sapXep();
    return _dsKetQua.map((e) => e.vanBanDayDu).toList();
  }

  @override
  VanBanNoiBat? layVanBanNoiBat(String dayDu, String noiBat)  => _dsKetQua.firstWhere((element) => element.vanBanDayDu == dayDu && element.vanBanNoiBat == noiBat);

  @override
  void daChonGoiY(String tuKhoa) {
    CoSoDuLieu().luuThoiDiemChonGoiY(bang, tuKhoa);
  }

}
