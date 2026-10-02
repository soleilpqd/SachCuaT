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

import 'dart:io';
import 'package:sach_cua_t/utils/common.dart';

/// Dữ liệu tạm
class DuLieuTam {

  DuLieuTam._internal();

  static final DuLieuTam _duyNhat = DuLieuTam._internal();
  factory DuLieuTam() { return _duyNhat; }

  Map<String, String> dsThuMuc() => {
    "chiaSe": "sct://tam.sach/chia_se",
    "dan": "sct://tam.sach/dan",
    "mayAnh": "sct://tam.sach/may_anh"
  };

  String _thuMucChiaSe = "";
  String _thuMucDan = "";
  String _thuMucMayAnh = "";

  /// Khởi đầu
  bool khoiDau(Map<String, String> dsThuMuc) {
    String? giaTri = dsThuMuc["dan"];
    if (giaTri == null) {
      return false;
    }
    _thuMucDan = giaTri;

    giaTri = dsThuMuc["chiaSe"];
    if (giaTri == null) {
      return false;
    }
    _thuMucChiaSe = giaTri;

    giaTri = dsThuMuc["mayAnh"];
    if (giaTri == null) {
      return false;
    }
    _thuMucMayAnh = giaTri;
    return true;
  }

  Future<int> doKhoiLuongTam() async {
    return (await LinhTinh.doKhoiLuongThuMuc(_thuMucDan)) +
      (await LinhTinh.doKhoiLuongThuMuc(_thuMucChiaSe)) +
      (await LinhTinh.doKhoiLuongThuMuc(_thuMucMayAnh));
  }

  Future<Iterable<String>> _layDsCacTepTrongThuMucTam(String duongDan) async {
    final Directory thuMucChua = Directory(duongDan);
    List<String> ketQua = [];
    if (await thuMucChua.exists()) {
      await for (final FileSystemEntity muc in thuMucChua.list()) {
        ketQua.add(muc.path);
      }
    }
    return ketQua;
  }

  Future<void> _xoaCacTepTam(String duongDan) async {
    final Directory thuMucChua = Directory(duongDan);
    if (await thuMucChua.exists()) {
      await for (final FileSystemEntity muc in thuMucChua.list()) {
        try {
          await muc.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// Lấy đường dẫn thư mục chứa các tệp được dán từ pasteboard
  Directory duongDanThuMucDan() => Directory(_thuMucDan);
  /// Lấy danh sách các tệp được dán
  Future<Iterable<String>> layDsCacTepDuocDan() async => _layDsCacTepTrongThuMucTam(_thuMucDan);
  /// Xoá các tệp được dán
  Future<void> xoaCacTepDan() async => _xoaCacTepTam(_thuMucDan);

  /// Lấy đường dẫn thư mục chứa các tệp được dán từ pasteboard
  Directory duongDanThuMucChiaSe() => Directory(_thuMucChiaSe);
  /// Xoá các tệp được chia sẻ
  Future<void> xoaTepDuocChiaSe() async => _xoaCacTepTam(_thuMucChiaSe);
  /// Lấy danh sách các tệp được chia sẻ
  Future<Iterable<String>> layDsCacTepDuocChiaSe() async => _layDsCacTepTrongThuMucTam(_thuMucChiaSe);

  /// Lấy đường dẫn thư mục chứa các tệp ảnh từ máy ảnh hoặc thư viện
  Directory duongDanThuMucMayAnh() => Directory(_thuMucMayAnh);
  /// Lấy danh sách các tệp ảnh từ máy ảnh hoặc thư viện
  Future<Iterable<String>> layDsCacTepMayAnh() async => _layDsCacTepTrongThuMucTam(_thuMucMayAnh);
  /// Xoá các tệp ảnh từ máy ảnh hoặc thư viện
  Future<void> xoaCacTepMayAnh() async => _xoaCacTepTam(_thuMucMayAnh);

  void xoaTatCa() {
    xoaCacTepMayAnh();
    xoaCacTepDan();
    xoaTepDuocChiaSe();
  }

  // Future<void> xoaTepTam(String duongDan) async {
  //   final Directory thuMucChiaSe = await _duongDanThuMucTam(true, _tenChiaSe);
  //   final Directory thuMucDan = await _duongDanThuMucTam(true, _tenDan);
  //   final File target = File(duongDan);
  //   if ((duongDan.startsWith(thuMucChiaSe.path) || duongDan.startsWith(thuMucDan.path)) && target.existsSync()) {
  //     try {
  //       await target.delete();
  //     } catch (_) {}
  //   }
  // }

  // String suDungTepTam() {

  //   return "";
  // }

  // void lamSachTepTam(String duongDan) {

  // }

}