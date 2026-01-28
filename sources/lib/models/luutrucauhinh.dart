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

import 'package:shared_preferences/shared_preferences.dart';

/// Lưu trữ cấu hình
class LuuTruCauHinh {

  LuuTruCauHinh._internal();
  static final LuuTruCauHinh _duyNhat = LuuTruCauHinh._internal();
  factory LuuTruCauHinh() => _duyNhat;

  SharedPreferences? _prefs;

  Future<void> _khoiTaoNeuCan() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Lấy thời điểm tham chiếu
  Future<int?> layThoiDiemThamChieu() async {
    await _khoiTaoNeuCan();
    return _prefs!.getInt("thoi_diem_tham_chieu");
  }

  /// Lưu thời điểm tham chiếu
  Future<void> luuThoiDiemThamChieu(int value) async {
    await _khoiTaoNeuCan();
    _prefs!.setInt("thoi_diem_tham_chieu", value);
  }

  /// Lấy tuỳ chọn hiển thị danh sách tập đầy đủ
  Future<bool?> layHienThiDSTapDayDu() async {
    await _khoiTaoNeuCan();
    return _prefs!.getBool("hien_thi_ds_tap_day_du");
  }

  /// Lưu tuỳ chọn hiển thị danh sách tập đầy đủ
  Future<void> luuHienThiDSTapDayDu(bool value) async {
    await _khoiTaoNeuCan();
    _prefs!.setBool("hien_thi_ds_tap_day_du", value);
  }

  /// Lấy tuỳ chọn hiển thị danh sách tập đầy đủ
  Future<bool?> layTimKiemChinhXac() async {
    await _khoiTaoNeuCan();
    return _prefs!.getBool("tim_kiem_chinh_xac");
  }

  /// Lưu tuỳ chọn hiển thị danh sách tập đầy đủ
  Future<void> luuTimKiemChinhXac(bool value) async {
    await _khoiTaoNeuCan();
    _prefs!.setBool("tim_kiem_chinh_xac", value);
  }

}