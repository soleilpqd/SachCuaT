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

/// Gợi ý giá trị nhãn
class GoiYNhan extends GoiYVanBan {

  /// Danh sách kết quả
  List<VanBanNoiBat> _dsKetQua = [];
  /// Lấy tên nhãn
  String Function()? layTenNhan;

  GoiYNhan();

  void dispose() {
    layTenNhan = null;
  }

  @override
  Future<List<String>> timKiemGoiY(String dauVao, TruongVanBan widget) async {
    _dsKetQua.clear();
    if (dauVao.isEmpty) {
      return [];
    }
    final String nhan = layTenNhan?.call() ?? "";
    if (nhan.isEmpty) {
      return [];
    }
    _dsKetQua = await CoSoDuLieu().timKiemGiaTriNhan(nhan, dauVao);
    _dsKetQua.sapXep();
    return _dsKetQua.map((e) => e.vanBanDayDu).toList();
  }

  @override
  void daChonGoiY(String tuKhoa) {
    final String nhan = layTenNhan?.call() ?? "";
    if (nhan.isEmpty) {
      return;
    }
    CoSoDuLieu().luuThoiDiemChonGiaTriNhan(nhan, tuKhoa);
  }

  @override
  VanBanNoiBat? layVanBanNoiBat(String dayDu, String noiBat) {
    try {
      return _dsKetQua.firstWhere((element) => element.vanBanDayDu == dayDu && element.vanBanNoiBat == noiBat);
    } catch (_) {
      return null;
    }
  }

}