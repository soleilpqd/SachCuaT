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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/utils/isolations.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite
class CoSoDuLieu {

  static const String _BANG_VB_HIEN_THI   = "van_ban_hien_thi";
  static const String _BANG_SACH          = "sach";
  static const String _BANG_NXB           = "nxb";
  static const String _BANG_NXB_SACH      = "nxb_sach";
  static const String _BANG_DICH_GIA      = "dich_gia";
  static const String _BANG_DICH_GIA_SACH = "dich_gia_sach";
  static const String _BANG_TAC_GIA       = "tac_gia";
  static const String _BANG_TAC_GIA_SACH  = "tac_gia_sach";
  static const String _BANG_VI_TRI        = "vi_tri";
  static const String _BANG_VI_TRI_SACH   = "vi_tri_sach";
  static const String _BANG_NHAN          = "nhan";
  static const String _BANG_NHAN_SACH     = "nhan_sach";
  static const String _BANG_DANH_DAU      = "danh_dau";
  static const String _BANG_NHIEU_TAP     = "chuoi";

  CoSoDuLieu._internal();

  static final CoSoDuLieu _duyNhat = CoSoDuLieu._internal();
  factory CoSoDuLieu() { return _duyNhat; }

  Database? _db;
  final int _dbVersion = 1;
  String _thuMucAnhSach = "";
  /// Đã mở hay chưa
  bool get daMo => _db != null;

  /// Khởi đầu
  /// - Mở DB.
  /// - Tạo các thư mục ảnh.
  Future<void> khoiDau() async {
    const tenDB = "sachcuat.db";
    WidgetsFlutterBinding.ensureInitialized();
    final duongDanCoSo = await getDatabasesPath();
    final duongDanCSDL = join(duongDanCoSo, tenDB);
    print("DB: $duongDanCSDL");
    final csdlTonTai = await databaseExists(duongDanCSDL);
    // final dbExisted = false; // DEBUG: overwrite
    if (!csdlTonTai) {
      try {
        await Directory(duongDanCoSo).create(recursive: true);
      } catch (_) {}
      final ByteData data = await rootBundle.load(join("assets", tenDB));
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(duongDanCSDL).writeAsBytes(bytes);
    }
    _thuMucAnhSach = join(duongDanCoSo, "sach");
    final dirAnhSach = Directory(_thuMucAnhSach);
    if (!await dirAnhSach.exists()) {
      try {
        dirAnhSach.create(recursive: true);
      } catch (_) {}
    }
    _db = await openDatabase(duongDanCSDL, version: _dbVersion);
  }

  /// Đóng DB
  void ketThuc() {
    _db?.close();
  }

  // ------

  /// Truy vấn văn bản hiển thị
  Future<String?> truyVanVanBanHienThi(String tuKhoa, String phanLoai) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _db!.query(
      _BANG_VB_HIEN_THI,
      where: "\"phan_loai\" = ? AND \"tu_khoa\" = ?",
      whereArgs: [phanLoai, tuKhoa]
    );
    // print("DB SELECT $_BANG_VB_HIEN_THI tuKhoa=$tuKhoa:\n$ketQua");
    final mucDau = ketQua.firstOrNull?["noi_dung"];
    if (mucDau is String) {
      return mucDau;
    }
    return null;
  }

  // ------

  /// Truy vấn danh sách tên các đơn vị phát hành
  Future<List<String>> truyVanDSNxb() async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _db!.query(_BANG_NXB, columns: ["ten"]);
    return ketQua.map((muc) => muc["ten"] as String).toList();
  }

  // ------

  Map<String, Object?> _taoDLChoBangSach(Sach thongTin) => {
    "ten" : thongTin.ten,
    "xong": thongTin.daHoanThanh ? 1 : 0,
    "isbn": thongTin.isbn
  };

  /// Tạo mới bản ghi sách
  Future<int> taoMoiSach(Sach thongTin) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final duLieu = _taoDLChoBangSach(thongTin);
    thongTin.maSo = await _db!.insert(_BANG_SACH, duLieu);
    return thongTin.maSo!;
  }

  /// Cập nhật thông tin sách
  Future<bool> capNhatSach(Sach thongTin) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(thongTin.maSo != null, "Thiếu mã sách để cập nhật.");
    final duLieu = _taoDLChoBangSach(thongTin);
    final ketQua = await _db!.update(_BANG_SACH, duLieu, where: "ma = ?", whereArgs: [thongTin.maSo]);
    return ketQua == 1;
  }

  Future<bool> napThongTinSach(Sach thongTin) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(thongTin.maSo != null, "Thiếu mã sách để cập nhật.");
    final duLieu = await _db!.query(_BANG_SACH, where: "ma = ?", whereArgs: [thongTin.maSo!]);
    if (duLieu.isNotEmpty) {
      final banGhiDau = duLieu.first;
      thongTin.ten = banGhiDau["ten"] as String;
      thongTin.daHoanThanh = (banGhiDau["xong"] as int) != 0;
      thongTin.isbn = banGhiDau["isbn"] as String;
      thongTin.tap = banGhiDau["tap"] as int?;
      thongTin.maNhieuTap = banGhiDau["chuoi"] as int?;
      return true;
    }
    return false;
  }

  // ------

  /// Tìm đơn vị phát hành theo tên
  Future<NhaXuatBan?> timNhaXuatBan(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _db!.query(_BANG_NXB, where: "ten = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      final nxb = NhaXuatBan();
      nxb.maSo = ketQua.first["ma"] as int;
      nxb.ten = ketQua.first["ten"] as String;
      nxb.maLuuChieu = ketQua.first["ma_luu_chieu"] as String?;
      return nxb;
    }
    return null;
  }

  /// Thêm đơn vị phát hành
  Future<void> themNhaXuatBan(NhaXuatBan nxb) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    nxb.maSo = await _db!.insert(_BANG_NXB, {"ten": nxb.ten, "ma_luu_chieu": nxb.maLuuChieu});
  }

  /// Lấy danh sách các NXB của sách
  Future<List<NhaXuatBan>> layDsNhaXuatBanCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _db!.rawQuery(
      """
SELECT "$_BANG_NXB"."ma", "$_BANG_NXB"."ten", "$_BANG_NXB"."ma_luu_chieu" FROM "$_BANG_NXB"
INNER JOIN "$_BANG_NXB_SACH" ON "$_BANG_NXB_SACH"."nxb" = "$_BANG_NXB"."ma"
WHERE "$_BANG_NXB_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return ketQua.map((e) {
      final NhaXuatBan nxb = NhaXuatBan();
      nxb.maSo = e["ma"] as int;
      nxb.ten = e["ten"] as String;
      nxb.maLuuChieu = e["ma_luu_chieu"] as String?;
      return nxb;
    }).toList();
  }

  /// Lưu đơn vị phát hành của sách
  Future<void> themNxbCuaSach(Sach sach, NhaXuatBan nxb) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.insert(_BANG_NXB_SACH, {"sach": sach.maSo!, "nxb": nxb.maSo});
  }

  /// Xoá đơn vị phát hành của sách
  Future<void> xoaNxbCuaSach(Sach sach, NhaXuatBan nxb) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.delete(_BANG_NXB_SACH, where: "sach = ? AND nxb = ?", whereArgs: [sach.maSo, nxb.maSo]);
  }

  // ------

  /// Tìm tác giả theo tên
  Future<TacGia?> timTacGia(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _db!.query(_BANG_TAC_GIA, where: "ten = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      final TacGia tacGia = TacGia();
      tacGia.maSo = ketQua.first["ma"] as int;
      tacGia.ten = ketQua.first["ten"] as String;
      return tacGia;
    }
    return null;
  }

  /// Thêm tác giả
  Future<void> themTacGia(TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    tacGia.maSo = await _db!.insert(_BANG_TAC_GIA, {"ten": tacGia.ten});
  }

  /// Lấy danh sách các tác giả của sách
  Future<List<TacGia>> layDsTacGiaCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _db!.rawQuery(
      """
SELECT "$_BANG_TAC_GIA"."ma", "$_BANG_TAC_GIA"."ten" FROM "$_BANG_TAC_GIA"
INNER JOIN "$_BANG_TAC_GIA_SACH" ON "$_BANG_TAC_GIA_SACH"."tac_gia" = "$_BANG_TAC_GIA"."ma"
WHERE "$_BANG_TAC_GIA_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return ketQua.map((e) {
      final TacGia tg = TacGia();
      tg.maSo = e["ma"] as int;
      tg.ten = e["ten"] as String;
      return tg;
    }).toList();
  }

    /// Lưu tác giả của sách
  Future<void> themTacGiaCuaSach(Sach sach, TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.insert(_BANG_TAC_GIA_SACH, {"sach": sach.maSo!, "tac_gia": tacGia.maSo});
  }

  /// Xoá tác giả của sách
  Future<void> xoaTacGiaCuaSach(Sach sach, TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.delete(_BANG_TAC_GIA_SACH, where: "sach = ? AND tac_gia = ?", whereArgs: [sach.maSo!, tacGia.maSo]);
  }

  // ------

  /// Tìm dịch giả
  Future<DichGia?> timDichGia(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _db!.query(_BANG_DICH_GIA, where: "ten = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      final DichGia dichGia = DichGia();
      dichGia.maSo = ketQua.first["ma"] as int;
      dichGia.ten = ketQua.first["ten"] as String;
      return dichGia;
    }
    return null;
  }

  /// Thêm dịch giả
  Future<void> themDichGia(DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    dichGia.maSo = await _db!.insert(_BANG_DICH_GIA, {"ten": dichGia.ten});
  }

  /// Lấy danh sách các dịch giả của sách
  Future<List<DichGia>> layDsDichGiaCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _db!.rawQuery(
      """
SELECT "$_BANG_DICH_GIA"."ma", "$_BANG_DICH_GIA"."ten" FROM "$_BANG_DICH_GIA"
INNER JOIN "$_BANG_DICH_GIA_SACH" ON "$_BANG_DICH_GIA_SACH"."dich_gia" = "$_BANG_DICH_GIA"."ma"
WHERE "$_BANG_DICH_GIA_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return ketQua.map((e) {
      final DichGia dg = DichGia();
      dg.maSo = e["ma"] as int;
      dg.ten = e["ten"] as String;
      return dg;
    }).toList();
  }

    /// Lưu dịch giả của sách
  Future<void> themDichGiaCuaSach(Sach sach, DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.insert(_BANG_DICH_GIA_SACH, {"sach": sach.maSo!, "dich_gia": dichGia.maSo});
  }

  /// Xoá dịch giả của sách
  Future<void> xoaDichGiaCuaSach(Sach sach, DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.delete(_BANG_DICH_GIA_SACH, where: "sach = ? AND dich_gia = ?", whereArgs: [sach.maSo!, dichGia.maSo]);
  }

  // ------

  /// Tìm vị trí
  Future<ViTriSach?> timViTri(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _db!.query(_BANG_VI_TRI, where: "ten = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      final ViTriSach vt = ViTriSach();
      vt.maSo = ketQua.first["ma"] as int;
      vt.ten = ketQua.first["ten"] as String;
      return vt;
    }
    return null;
  }

  /// Thêm vị trí
  Future<void> themViTri(ViTriSach vt) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    vt.maSo = await _db!.insert(_BANG_VI_TRI, {"ten": vt.ten});
  }

  /// Lấy danh sách các vị trí của sách
  Future<List<ViTriSach>> layDsViTriCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _db!.rawQuery(
      """
SELECT "$_BANG_VI_TRI"."ma", "$_BANG_VI_TRI"."ten", "$_BANG_VI_TRI_SACH"."ngay_nhap" FROM "$_BANG_VI_TRI"
INNER JOIN "$_BANG_VI_TRI_SACH" ON "$_BANG_VI_TRI_SACH"."vi_tri" = "$_BANG_VI_TRI"."ma"
WHERE "$_BANG_VI_TRI_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return ketQua.map((e) {
      final ViTriSach vt = ViTriSach();
      vt.maSo = e["ma"] as int;
      vt.ten = e["ten"] as String;
      vt.thoiGian = e["ngay_nhap"] as int;
      return vt;
    }).toList();
  }

    /// Lưu vị trí của sách
  Future<void> themViTriCuaSach(Sach sach, ViTriSach viTri) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db!.insert(_BANG_VI_TRI_SACH, {"sach": sach.maSo!, "vi_tri": viTri.maSo, "ngay_nhap": now});
  }

  /// Xoá vị trí của sách
  Future<void> xoaViTriCuaSach(Sach sach, ViTriSach viTri) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _db!.delete(_BANG_VI_TRI_SACH, where: "sach = ? AND dich_gia = ?", whereArgs: [sach.maSo!, viTri]);
  }

  // ------

  /// Lấy ảnh của sách
  Future<void> layAnhSach(Sach sach) async {
    assert(sach.maSo != null, "Thiếu mã sách để cập nhật.");
    final duongDanAnh = join(_thuMucAnhSach, "${sach.maSo!}.jpg");
    if (await File(duongDanAnh).exists()) {
      sach.hinhAnh = XFile(duongDanAnh);
    }
    final duongDanAnhNho = join(_thuMucAnhSach, "${sach.maSo!}_tn.jpg");
    if (await File(duongDanAnhNho).exists()) {
      sach.hinhThuNho = XFile(duongDanAnhNho);
    }
  }

  /// Lưu ảnh của sách
  Future<void> luuAnhSach(Sach sach) async {
    assert(sach.maSo != null, "Thiếu mã sách để cập nhật.");
    final String duongDanAnh = join(_thuMucAnhSach, "${sach.maSo!}.jpg");
    final String duongDanAnhNho = join(_thuMucAnhSach, "${sach.maSo!}_tn.jpg");
    if (sach.hinhAnh != null && sach.hinhAnh!.path != duongDanAnh) {
      // final ImgImage? anh = await Isolations.napAnhTuXFile(sach.hinhAnh!);
      // if (anh != null) {
      //   encodeJpgFile(duongDanAnh, anh);
      //   final ImgImage? anhThuNho = await Isolations.taoAnhThuNho(anh);
      //   if (anhThuNho != null) {
      //     encodeJpgFile(duongDanAnhNho, anhThuNho);
      //   }
      // }
      await HeThongMay.duyNhat.luuAnhSach(anhGoc: sach.hinhAnh!.path, mucTieu: duongDanAnh, anhThuNho: duongDanAnhNho);
    } else if (sach.hinhAnh == null) {
      sach.hinhThuNho = null;
      final File fileAnh = File(duongDanAnh);
      final File fileAnhNho = File(duongDanAnhNho);
      if (await fileAnh.exists()) {
        await fileAnh.delete();
      }
      if (await fileAnhNho.exists()) {
        await fileAnhNho.delete();
      }
    }
  }

  // ------

  /// TODO: xoá sách
  Future<void> xoaSach(int maSach) async {

  }

}