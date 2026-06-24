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

import 'package:flutter/services.dart';
import 'package:sach_cua_t/main.dart';
import 'package:sach_cua_t/models/du_lieu_tam.dart';
// import 'package:sach_cua_t/models/hienthinentang.dart';
import 'package:sach_cua_t/utils/common.dart';

enum _MethodFromNative {
  /// Kiểm tra định dạng ISBN
  kiemTraISBN,
  // capNhatHienThi;
  /// Khi nhấn nút lùi (chỉ Android)
  khiNhanNutLui,
  /// Khi người dùng chọn tệp từ ngoài app
  khiNhanDuocTep,
  ;

  static _MethodFromNative? init(String raw) {
    return switch (raw) {
      "kiemTraISBN" => _MethodFromNative.kiemTraISBN,
      // "capNhatHienThi" => _MethodFromNative.capNhatHienThi,
      "nutLuiAndroid" => _MethodFromNative.khiNhanNutLui,
      "nhanDuocTep" => _MethodFromNative.khiNhanDuocTep,
      _ => null
    };
  }
}

enum _MethodToNative {
  /// Quét mã ISBN
  quetMaISBN,
  /// Lưu ảnh sách
  luuAnhSach,
  /// Lấy phiên bản
  phienBan,
  /// Chụp ảnh hoặc mở kho ảnh
  chonAnh,
  /// Dán pasteboard
  dan,
  /// Mở hộp thoại chọn tệp
  chonTep
  ;
  // layThongTinHienThi;

  String get value {
    return switch (this) {
      _MethodToNative.quetMaISBN => "quetMaISBN",
      _MethodToNative.luuAnhSach => "luuAnhSach",
      _MethodToNative.phienBan => "phienBan",
      _MethodToNative.chonAnh => "chonAnh",
      _MethodToNative.dan => "dan",
      _MethodToNative.chonTep => "chonTep",
      // _MethodToNative.layThongTinHienThi => "layThongTinHienThi"
    };
  }
}

/// Kiểu tệp
enum KieuTep {
  /// Ảnh (JPEG, PNG)
  anh,
  /// zip
  zip,
  /// 7zip
  p7zip
}

/// Kiểu media
enum KieuMedia {
  /// Camera
  camera,
  /// Kho ảnh
  khoAnh;

  int get giaTri {
    return switch (this) {
      KieuMedia.camera => 0,
      KieuMedia.khoAnh => 1
    };
  }
}

// mixin TheoDoiHeThongMay {

//   void heThongCapNhatHienThi(bool banPhim, bool chieuManHinh);

// }

/// APIs trao đổi với module native
class HeThongMay {

  final MethodChannel _kenhKetNoi = const MethodChannel("sach.cua.T");

  HeThongMay._internal() {
    _kenhKetNoi.setMethodCallHandler((call) {
      final method = _MethodFromNative.init(call.method);
      if (method != null) {
        switch (method) {
        case _MethodFromNative.kiemTraISBN:
          return _kiemTraISBN(call.arguments);
        case _MethodFromNative.khiNhanNutLui:
          return _xuLyNutLuiAndroid();
        case _MethodFromNative.khiNhanDuocTep:
          _xuLyKhiNhanDuocTep(call.arguments);
        // case _MethodFromNative.capNhatHienThi:
        //   _xuLyThongTinHienThi(call.arguments);
        //   _thongBaoCapNhatHienThi(call.arguments);
        }
      }
      return Future(() => null);
    });
  }
  static final HeThongMay duyNhat = HeThongMay._internal();
  // final thongTinHienThi = HienThiNenTang();
  // final theoDoi = <TheoDoiHeThongMay>[];

  /// Flutter -> Native: Bật camera để quét mã ISBN
  Future<String?> quetMaISBN() async {
    return _kenhKetNoi.invokeMethod<String>(_MethodToNative.quetMaISBN.value);
  }

  /// Flutter <- Native: kiểm tra định dạng ISBN
  Future<bool> _kiemTraISBN(String giaTri) {
    return Future.value(LinhTinh.kiemTraISBN(giaTri));
  }

  /// Lưu ảnh sách
  /// - [anhGoc]: đường dẫn ảnh gốc
  /// - [mucTieu]: đường dẫn lưu ảnh sách
  /// - [anhThuNho]; đường dẫn lưu ảnh thu nhỏ
  /// - [chieuCao]: chiều cao ảnh thu nhỏ
  Future<bool?> luuAnhSach({required String anhGoc, required String mucTieu, required String anhThuNho, int chieuCao = 100}) async {
    return _kenhKetNoi.invokeMethod<bool>(
      _MethodToNative.luuAnhSach.value, {
        "goc": anhGoc,
        "dich": mucTieu,
        "thunho": anhThuNho,
        "cao": chieuCao
      });
  }

  // void _xuLyThongTinHienThi(dynamic duLieu) {
  //   if (duLieu is Map<Object?, Object?>) {
  //     thongTinHienThi.trichXuat(duLieu);
  //   }
  // }

  // void _thongBaoCapNhatHienThi(dynamic duLieu) {
  //   bool thayDoiBp = false;
  //   bool thayDoiChieu = false;
  //   if (duLieu is Map<Object?, Object?>) {
  //     dynamic banPhim = duLieu["bp"];
  //     dynamic chieu = duLieu["chieu"];
  //     if (banPhim is bool) {
  //       thayDoiBp = banPhim;
  //     }
  //     if (chieu is bool) {
  //       thayDoiChieu = chieu;
  //     }
  //   }
  //   for (final muc in theoDoi) {
  //     muc.heThongCapNhatHienThi(thayDoiBp, thayDoiChieu);
  //   }
  // }

  /// Lấy thông tin hiển thị của Native module
  // Future<void> layThongTinHienThi() async {
    // final duLieu = await _kenhKetNoi.invokeMethod<Map<Object?, Object?>>(_MethodToNative.layThongTinHienThi.value);
    // _xuLyThongTinHienThi(duLieu);
  // }

  Future<String?> layThongTinPhienBan() async => _kenhKetNoi.invokeMethod<String>(_MethodToNative.phienBan.value);

  Future<bool?> _xuLyNutLuiAndroid() {
    return Future.value(MainApp.xuLyNutLuiAndroid());
  }

  /// Chụp ảnh hoặc mở kho ảnh
  Future<String?> chonAnh(KieuMedia kieu) async {
    final Map<String, Object?> thamSo = {};
    thamSo["duong_dan"] = (await DuLieuTam().duongDanTam()).path;
    thamSo["kieu"] = kieu.giaTri;
    return _kenhKetNoi.invokeMethod<String>(_MethodToNative.chonAnh.value, thamSo);
  }

  Future<List<String?>?> dan(List<KieuTep> loc) async {
    final Directory duongDanTam = await DuLieuTam().duongDanThuMucDan();
    final Map<String, Object?> thamSo = {};
    thamSo["duong_dan"] = duongDanTam.path;
    thamSo["loc"] = loc.map((muc) => muc.index).toList();
    final List<Object?>? ketQua = await _kenhKetNoi.invokeMethod(_MethodToNative.dan.value, thamSo) as List<Object?>?;
    final List<String>? dsDuongDan = ketQua?.cast<String>();
    print("DAN $dsDuongDan");
    return Future.value(dsDuongDan);
  }

  void _xuLyKhiNhanDuocTep(dynamic dsDuongDan) {
    final List<String> dsDuongDanChuan = (dsDuongDan as List<Object?>).cast<String>();
    DuLieuTam().nhapTepDuocChiaSe(dsDuongDanChuan).then((ketQua) {
      MainApp.xuLyTepDuocChiaSe(ketQua);
    });
  }

}
