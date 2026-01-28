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
import 'package:sach_cua_t/models/dulieu.dart';

/// Thao tác nạp thông tin sách
class ThaoTacNapThongTinSach {

  /// Nơi chứa thông tin nạp. Yêu cầu đã chứa mã sách.
  final Sach thongTinSach;
  /// Đã nạp xong.
  bool daXong = false;
  /// Kết quả nạp dữ liệu
  bool thanhCong = false;

  /// Constructor
  ThaoTacNapThongTinSach(this.thongTinSach);

  Future<bool> napThongTin() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    final bool kq = await csdl.napThongTinSach(thongTinSach);
    if (!kq) {
      daXong = true;
      thanhCong = false;
      return kq;
    }
    await csdl.layAnhSach(thongTinSach);
    thongTinSach.tacGia = (await csdl.layDsTacGiaCuaSach(thongTinSach)).map((e) => e.ten).toList();
    thongTinSach.dichGia = (await csdl.layDsDichGiaCuaSach(thongTinSach)).map((e) => e.ten).toList();
    thongTinSach.viTri = (await csdl.layDsViTriCuaSach(thongTinSach)).map((e) => e.ten).toList();
    thongTinSach.nhaXuatBan = (await csdl.layDsNhaXuatBanCuaSach(thongTinSach)).map((e) => e.ten).toList();
    // TODO:
    daXong = true;
    thanhCong = true;
    return true;
  }

}