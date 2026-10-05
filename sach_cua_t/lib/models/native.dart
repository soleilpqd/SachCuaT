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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sach_cua_t/main.dart';
// import 'package:sach_cua_t/models/hienthinentang.dart';
import 'package:sach_cua_t/utils/common.dart';

enum _YeuCauTuNenTang {
  /// Kiểm tra định dạng ISBN
  kiemTraISBN,
  // capNhatHienThi;
  /// Khi nhấn nút lùi (chỉ Android)
  khiNhanNutLui,
  /// Khi người dùng chọn tệp từ ngoài app
  khiNhanDuocTep,
  /// Chuẩn hoá ảnh
  chuanHoaAnh,
  /// URL sách
  urlSach
  ;

  static _YeuCauTuNenTang? init(String raw) {
    return switch (raw) {
      "kiemTraISBN" => _YeuCauTuNenTang.kiemTraISBN,
      // "capNhatHienThi" => _MethodFromNative.capNhatHienThi,
      "nutLuiAndroid" => _YeuCauTuNenTang.khiNhanNutLui,
      "nhanDuocTep" => _YeuCauTuNenTang.khiNhanDuocTep,
      "chuanHoaAnh" => _YeuCauTuNenTang.chuanHoaAnh,
      "urlSach" => _YeuCauTuNenTang.urlSach,
      _ => null
    };
  }
}

enum _YeuCauDenNenTang {
  /// Bắt đầu
  batDau,
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
  chonTep,
  /// Chuẩn hoá ảnh
  chuanHoaAnh,
  /// Tìm kiếm ảnh
  timKiemAnh
  ;
  // layThongTinHienThi;

  String get value {
    return switch (this) {
      _YeuCauDenNenTang.batDau => "batDau",
      _YeuCauDenNenTang.quetMaISBN => "quetMaISBN",
      _YeuCauDenNenTang.luuAnhSach => "luuAnhSach",
      _YeuCauDenNenTang.phienBan => "phienBan",
      _YeuCauDenNenTang.chonAnh => "chonAnh",
      _YeuCauDenNenTang.dan => "dan",
      _YeuCauDenNenTang.chonTep => "chonTep",
      _YeuCauDenNenTang.chuanHoaAnh => "chuanHoaAnh",
      _YeuCauDenNenTang.timKiemAnh => "timKiemAnh",
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

class TienTrinhChuanHoaAnh extends ChangeNotifier {

  Map<String, int> thongTinChuanHoaAnh = {};

  void capNhat(Map<String, int> duLieuMoi) {
    thongTinChuanHoaAnh = duLieuMoi;
    notifyListeners();
  }

}

/// APIs trao đổi với module native
class HeThongMay {

  final MethodChannel _kenhKetNoi = const MethodChannel("sach.cua.T");

  HeThongMay._internal() {
    _kenhKetNoi.setMethodCallHandler((call) {
      final method = _YeuCauTuNenTang.init(call.method);
      if (method != null) {
        switch (method) {
        case _YeuCauTuNenTang.kiemTraISBN:
          return _kiemTraISBN(call.arguments);
        case _YeuCauTuNenTang.khiNhanNutLui:
          return _xuLyNutLuiAndroid();
        case _YeuCauTuNenTang.khiNhanDuocTep:
          _xuLyKhiNhanDuocTep();
        // case _MethodFromNative.capNhatHienThi:
        //   _xuLyThongTinHienThi(call.arguments);
        //   _thongBaoCapNhatHienThi(call.arguments);
        case _YeuCauTuNenTang.chuanHoaAnh:
          _xuLyKhiNhanDuocCapNhatChuanHoaAnh(call.arguments);
        case _YeuCauTuNenTang.urlSach:
          _xuLyKhiNhanDuocUrlSach(call.arguments);
        }
      }
      return Future(() => null);
    });
  }
  static final HeThongMay duyNhat = HeThongMay._internal();
  // final thongTinHienThi = HienThiNenTang();
  // final theoDoi = <TheoDoiHeThongMay>[];
  final ValueNotifier urlSach = ValueNotifier("");
  final TienTrinhChuanHoaAnh theoDoiTienTrinhChuanHoaAnh = TienTrinhChuanHoaAnh();

  Future<Map<String, String>?> batDau(Map<String, String> dsTenThuMuc) async {
    return _kenhKetNoi.invokeMapMethod(_YeuCauDenNenTang.batDau.value, dsTenThuMuc);
  }

  /// Flutter -> Native: Bật camera để quét mã ISBN
  Future<String?> quetMaISBN() async {
    return _kenhKetNoi.invokeMethod<String>(_YeuCauDenNenTang.quetMaISBN.value);
  }

  /// Flutter <- Native: kiểm tra định dạng ISBN
  Future<bool> _kiemTraISBN(String giaTri) {
    return Future.value(LinhTinh.kiemTraISBN(giaTri));
  }

  /// Lưu ảnh sách
  /// - [anhGoc]: đường dẫn ảnh gốc
  /// - [mucTieu]: đường dẫn lưu ảnh sách
  /// - [anhThuNho]; đường dẫn lưu ảnh thu nhỏ
  /// - [gioiHan]: kích thước tối đa (các chiều) của ảnh
  /// - [chieuCao]: kích thước ảnh thu nhỏ (lớn nhất trong 2 chiều)
  /// - [chatLuong]: chất lượng ảnh (độ nén JPEG) (tỉ lệ %: 1-100)
  Future<bool?> luuAnhSach({
    required String anhGoc,
    required String mucTieu,
    required String anhThuNho,
    int gioiHan = 2000,
    int chieuCao = 100,
    int chatLuong = 20,
    int chatLuongTn = 50
  }) async {
    return _kenhKetNoi.invokeMethod<bool>(
      _YeuCauDenNenTang.luuAnhSach.value, {
        "goc": anhGoc,
        "dich": mucTieu,
        "thunho": anhThuNho,
        "gioi_han": gioiHan,
        "cao": chieuCao,
        "chat_luong": chatLuong,
        "chat_luong_tn": chatLuongTn
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

  Future<String?> layThongTinPhienBan() async => _kenhKetNoi.invokeMethod<String>(_YeuCauDenNenTang.phienBan.value);

  /// Khi user nhấn nút Back của Android
  Future<bool?> _xuLyNutLuiAndroid() {
    return Future.value(MainApp.xuLyNutLuiAndroid());
  }

  /// Chụp ảnh hoặc mở kho ảnh
  Future<String?> chonAnh(KieuMedia kieu) async {
    final Map<String, Object?> thamSo = {};
    thamSo["kieu"] = kieu.giaTri;
    return _kenhKetNoi.invokeMethod<String>(_YeuCauDenNenTang.chonAnh.value, thamSo);
  }

  /// Dán
  Future<List<String>?> dan(List<KieuTep> loc) async {
    final Map<String, Object?> thamSo = {};
    thamSo["loc"] = loc.map((muc) => muc.index).toList();
    final List<Object?>? ketQua = await _kenhKetNoi.invokeMethod(_YeuCauDenNenTang.dan.value, thamSo) as List<Object?>?;
    final List<String>? dsDuongDan = ketQua?.cast<String>();
    return Future.value(dsDuongDan);
  }

  /// Xử lý khi nhận được tệp chia sẻ từ hệ thống
  void _xuLyKhiNhanDuocTep() {
    MainApp.xuLyTepDuocChiaSe();
  }

  /// Mở màn hình chọn tệp
  Future<List<String>?> chonTep(List<KieuTep> loc) async {
    final Map<String, Object?> thamSo = {};
    thamSo["loc"] = loc.map((muc) => muc.index).toList();
    final List<Object?>? ketQua = await _kenhKetNoi.invokeMethod(_YeuCauDenNenTang.chonTep.value, thamSo) as List<Object?>?;
    final List<String>? dsDuongDan = ketQua?.cast<String>();
    return Future.value(dsDuongDan);
  }

  /// Chuẩn hoá dữ liệu TODO: hiện tại chỉ có trên iOS
  Future<void> chuanHoaAnh({
    int gioiHan = 2000,
    int chatLuong = 20,
    int chatLuongTn = 50,
    int gioiHanTn = 100,
    bool chiTn = false
    }) async {
    final Map<String, Object?> thamSo = {};
    thamSo["gioi_han"] = gioiHan;
    thamSo["gioi_han_tn"] = gioiHanTn;
    thamSo["chat_luong"] = chatLuong;
    thamSo["chat_luong_tn"] = chatLuongTn;
    thamSo["chi_tn"] = chiTn;
    return _kenhKetNoi.invokeMethod<void>(_YeuCauDenNenTang.chuanHoaAnh.value, thamSo);
  }

  /// Callback trong quá trình chuẩn hoá ảnh
  void _xuLyKhiNhanDuocCapNhatChuanHoaAnh(dynamic thongTin) {
    final Map<Object?, Object?> ketQua = thongTin as Map<Object?, Object?>;
    theoDoiTienTrinhChuanHoaAnh.capNhat(ketQua.cast<String, int>());
  }

  /// Mở màn hình tìm kiếm ảnh trên Internet (trình duyệt web nhúng trong ứng dụng iOS: Safari/ Android: Chrome)
  Future<List<String>?> moTimKiemAnh(String tuKhoa) async {
    final Map<String, Object?> thamSo = {};
    thamSo["tu_khoa"] = tuKhoa;
    final List<Object?>? ketQua = await _kenhKetNoi.invokeMethod(_YeuCauDenNenTang.timKiemAnh.value, thamSo) as List<Object?>?;
    final List<String>? dsDuongDan = ketQua?.cast<String>();
    return Future.value(dsDuongDan);
  }

  /// Callback từ module native: khi user dán/chia sẻ URL trên màn hình tìm kiếm ảnh
  void _xuLyKhiNhanDuocUrlSach(dynamic thongTin) {
    urlSach.value = thongTin as String;
  }

}
