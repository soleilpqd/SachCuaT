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
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Dữ liệu tạm
class DuLieuTam {

  DuLieuTam._internal();

  static final DuLieuTam _duyNhat = DuLieuTam._internal();
  factory DuLieuTam() { return _duyNhat; }

  final String _tenChiaSe = "chia_se";
  final String _tenDan = "dan";

  Future<Directory> duongDanTam() async => await getTemporaryDirectory();

  /// Khởi đầu
  Future<void> khoiDau() async {
    final Directory duongDanTam = await getTemporaryDirectory();
    print("TAM: ${duongDanTam.path}");
  }

  Future<Directory> _duongDanThuMucTam(bool canTao, String ten) async {
    final Directory duongDanTam = await getTemporaryDirectory();
    final String duongDan = join(duongDanTam.path, ten);
    Directory ketQua = Directory(duongDan);
    if (canTao && !await ketQua.exists()) {
      ketQua = await ketQua.create();
    }
    return ketQua;
  }

  Future<Iterable<String>> _layDsCacTepTrongThuMucTam(String ten) async {
    final Directory thuMucChua = await _duongDanThuMucTam(false, ten);
    List<String> ketQua = [];
    if (await thuMucChua.exists()) {
      await for (final FileSystemEntity muc in thuMucChua.list()) {
        ketQua.add(muc.path);
      }
    }
    return ketQua;
  }

  Future<void> _xoaCacTepTam(String tenThuMuc) async {
    final Directory thuMucChua = await _duongDanThuMucTam(false, tenThuMuc);
    if (await thuMucChua.exists()) {
      await for (final FileSystemEntity muc in thuMucChua.list()) {
        try {
          await muc.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// Lấy đường dẫn thư mục chứa các tệp được dán từ pasteboard
  Future<Directory> duongDanThuMucDan() async => _duongDanThuMucTam(true, _tenDan);

  /// Xoá các tệp được dán
  Future<void> xoaCacTepDan() async => _xoaCacTepTam(_tenDan);

  /// Xoá các tệp được chia sẻ
  Future<void> xoaTepDuocChiaSe() async => _xoaCacTepTam(_tenChiaSe);

  /// Nhập các tệp vào thư mục được chia sẻ
  Future<Iterable<File>> nhapTepDuocChiaSe(Iterable<String> dsDuongDan) async {
    xoaTepDuocChiaSe();
    final Directory thuMucChua = await _duongDanThuMucTam(true, _tenChiaSe);
    List<File> ketQua = [];
    for (String duongDan in dsDuongDan) {
      final File nguon = File(duongDan);
      if (nguon.existsSync()) {
        final String dich = join(thuMucChua.path, basename(duongDan));
        final File kqDich = await nguon.copy(dich);
        ketQua.add(kqDich);
        try {
          nguon.delete();
        } catch (_) {}
      }
    }
    return ketQua;
  }

  /// Lấy danh sách các tệp được chia sẻ
  Future<Iterable<String>> layDsCacTepDuocChiaSe() async => _layDsCacTepTrongThuMucTam(_tenChiaSe);

  String suDungTepTam() {

    return "";
  }

  void lamSachTepTam(String duongDan) {

  }

}