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

import 'package:sach_cua_t/models/dulieu.dart';

/// So sánh thông tin sách
class ThaoTacSoSanhSach {

  final Sach thongTin1;
  final Sach thongTin2;

  ThaoTacSoSanhSach({required this.thongTin1, required this.thongTin2});

  bool _soSanhDs(List<String> ds1, List<String> ds2) {
    if (ds1.length != ds2.length) {
      return false;
    }
    for (final muc in ds1) {
      if (!ds2.contains(muc)) {
        return false;
      }
    }
    for (final muc in ds2) {
      if (!ds1.contains(muc)) {
        return false;
      }
    }
    return true;
  }

  /// Tiến hành so sánh
  /// Trả về true nếu 2 thông tin là như nhau
  bool soSanh() {
    if (thongTin1.ten != thongTin2.ten) {
      return false;
    }
    if (thongTin1.isbn != thongTin2.isbn) {
      return false;
    }
    if (thongTin1.daHoanThanh != thongTin2.daHoanThanh) {
      return false;
    }
    if (thongTin1.hinhAnh?.path != thongTin2.hinhAnh?.path) {
      return false;
    }
    // TODO: nhiều tập
    if (!_soSanhDs(thongTin1.tacGia, thongTin2.tacGia)) {
      return false;
    }
    if (!_soSanhDs(thongTin1.dichGia, thongTin2.dichGia)) {
      return false;
    }
    if (!_soSanhDs(thongTin1.nhaXuatBan, thongTin2.nhaXuatBan)) {
      return false;
    }
    if (!_soSanhDs(thongTin1.viTri, thongTin2.viTri)) {
      return false;
    }
    if (!_soSanhDs(thongTin1.nhan.keys.toList(), thongTin2.nhan.keys.toList())) {
      return false;
    }
    for (final String tenNhan in thongTin1.nhan.keys) {
      final String? giaTri1 = thongTin1.nhan[tenNhan];
      final String? giaTri2 = thongTin2.nhan[tenNhan];
      if (giaTri1 != giaTri2) {
        return false;
      }
      final bool luonHien1 = thongTin1.nhanLuonHien.contains(tenNhan);
      final bool luonHien2 = thongTin2.nhanLuonHien.contains(tenNhan);
      if (luonHien1 != luonHien2) {
        return false;
      }
    }
    if (!_soSanhDs(thongTin1.danhDau, thongTin2.danhDau)) {
      return false;
    }
    return true;
  }

}