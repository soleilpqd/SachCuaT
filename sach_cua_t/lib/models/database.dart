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
import 'package:path/path.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/luutrucauhinh.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/models/vanbannoibat.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite
class CoSoDuLieu {

  static const String BANG_VB_HIEN_THI   = "van_ban_hien_thi";
  static const String BANG_SACH          = "sach";
  static const String BANG_NXB           = "nxb";
  static const String BANG_NXB_SACH      = "nxb_sach";
  static const String BANG_DICH_GIA      = "dich_gia";
  static const String BANG_DICH_GIA_SACH = "dich_gia_sach";
  static const String BANG_TAC_GIA       = "tac_gia";
  static const String BANG_TAC_GIA_SACH  = "tac_gia_sach";
  static const String BANG_VI_TRI        = "vi_tri";
  static const String BANG_VI_TRI_SACH   = "vi_tri_sach";
  static const String BANG_NHAN          = "nhan";
  static const String BANG_NHAN_SACH     = "nhan_sach";
  static const String BANG_DANH_DAU      = "danh_dau";
  static const String BANG_NHIEU_TAP     = "chuoi";

  CoSoDuLieu._internal();

  static final CoSoDuLieu _duyNhat = CoSoDuLieu._internal();
  factory CoSoDuLieu() { return _duyNhat; }

  Database? _db;
  final int _dbVersion = 1;
  String _thuMucAnhSach = "";
  String get thuMucAnhSach => _thuMucAnhSach;
  /// Đã mở hay chưa
  bool get daMo => _db != null;
  /// Thời điểm tham chiếu (thời điểm cài app)
  int _thoiDiemThamChieu = 0;

  /// Khởi đầu
  /// - Mở DB.
  /// - Tạo các thư mục ảnh.
  Future<void> khoiDau() async {
    const tenDB = "sachcuat.db";
    WidgetsFlutterBinding.ensureInitialized();

    final int? tdtc = await LuuTruCauHinh().layThoiDiemThamChieu();
    if (tdtc != null) {
      _thoiDiemThamChieu = tdtc;
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      _thoiDiemThamChieu = now;
      LuuTruCauHinh().luuThoiDiemThamChieu(now);
    }
    // Cơ sở dữ liệu
    final duongDanCoSo = await getDatabasesPath();
    final duongDanCSDL = join(duongDanCoSo, tenDB);
    print("DB: $duongDanCSDL");
    final csdlTonTai = await databaseExists(duongDanCSDL);
    // final dbExisted = false; // DEBUG: overwrite
    try {
        await Directory(duongDanCoSo).create(recursive: true);
      } catch (_) {}
    final ByteData data = await rootBundle.load(join("assets", tenDB));
    final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    if (!csdlTonTai) {
      await File(duongDanCSDL).writeAsBytes(bytes);
    }
    // Thư mục lưu ảnh
    _thuMucAnhSach = join(duongDanCoSo, "sach");
    final dirAnhSach = Directory(_thuMucAnhSach);
    if (!await dirAnhSach.exists()) {
      try {
        dirAnhSach.create(recursive: true);
      } catch (_) {}
    }
    _db = await openDatabase(duongDanCSDL, version: _dbVersion);
    await _kiemTraDuLieuChuan(bytes, duongDanCoSo);
  }

  /// Cập nhật lại dữ liệu chuẩn (văn bản hiển thị) từ DB gốc trong bundle
  Future<void> _kiemTraDuLieuChuan(List<int> duLieuGoc, String duongDanCoSo) async {
    const tenDBGoc = "sachcuat_tam.db";
    final duongDanCSDL = join(duongDanCoSo, tenDBGoc);
    final tepCSDL = File(duongDanCSDL);
    await tepCSDL.writeAsBytes(duLieuGoc);
    final Database dbGoc = await openDatabase(duongDanCSDL);
    final List<Map<String, Object?>> coKiemTra = await dbGoc.query(
      BANG_VB_HIEN_THI,
      where: "\"tu_khoa\" = ?",
      whereArgs: ["_"]
    );
    for (final co in coKiemTra) {
      final String? coHienTai = await truyVanVanBanHienThi(co["tu_khoa"] as String, co["phan_loai"] as String);
      if (coHienTai != (co["noi_dung"] as String)) {
        await _delete(BANG_VB_HIEN_THI, where: "\"phan_loai\" = ?", whereArgs: [co["phan_loai"]]);
        final List<Map<String, Object?>> cacTuKhoaGoc = await dbGoc.query(
          BANG_VB_HIEN_THI,
          where: "\"phan_loai\" = ?",
          whereArgs: [co["phan_loai"]]
        );
        for (final tkGoc in cacTuKhoaGoc) {
          await _insert(BANG_VB_HIEN_THI, tkGoc);
        }
      }
    }
    dbGoc.close();
    try {
      tepCSDL.delete();
    } catch (_) {}
  }

  /// Đóng DB
  void ketThuc() {
    _db?.close();
  }

  int get thoiDiemThamChieuHienTai => DateTime.now().millisecondsSinceEpoch - _thoiDiemThamChieu;

  // ------

  bool _ghiLog = false;
  set ghiLog(bool giaTri) { _ghiLog = giaTri; }

  Future<List<Map<String, Object?>>> _query(
    String table,
    {
      bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset
    }
  ) {
    if (_ghiLog) {
      String log = "SELECT";
      if (distinct != null && distinct)  {
        log += " DISTINCT";
      }
      if (columns != null && columns.isNotEmpty) {
        log += " $columns";
      } else {
        log += " *";
      }
      log += " FROM $table";
      if (where != null) {
        log += " WHERE $where";
        if (whereArgs != null && whereArgs.isNotEmpty) {
          log += " $whereArgs";
        }
      }
      if (groupBy != null) {
        log += " GROUP BY $groupBy";
      }
      if (having != null) {
        log += " HAVING $having";
      }
      if (orderBy != null) {
        log += " ORDER BY $orderBy";
      }
      if (limit != null) {
        log += " LIMIT $limit";
      }
      if (offset != null) {
        log += " OFFSET $offset";
      }
      log += ";";
      print(log);
    }
    return _db!.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset
    );
  }

  Future<List<Map<String, Object?>>> _rawQuery(
    String sql,
    [List<Object?>? arguments]
  ) {
    if (_ghiLog) {
      String log = sql;
      if (arguments!= null && arguments.isNotEmpty) {
        log += " $arguments";
      }
      print(log);
    }
    return _db!.rawQuery(sql, arguments);
  }

  Future<int> _insert(
    String table,
    Map<String, Object?> values
  ) {
    if (_ghiLog) {
      print("INSERT INTO $table VALUES $values;");
    }
    return _db!.insert(table, values);
  }

  Future<int> _update(
    String table,
    Map<String, Object?> values,
    {
      String? where,
      List<Object?>? whereArgs
    }
  ) {
    if (_ghiLog) {
      String log = "UPDATE $table SET $values";
      if (where != null) {
        log += " WHERE $where";
        if (whereArgs != null && whereArgs.isNotEmpty) {
          log += " $whereArgs";
        }
      }
      log += ";";
      print(log);
    }
    return _db!.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> _delete(String table, {String? where, List<Object?>? whereArgs}) {
    if (_ghiLog) {
      String log = "DELETE FROM $table";
      if (where != null) {
        log += " WHERE $where";
        if (whereArgs != null && whereArgs.isNotEmpty) {
          log += " $whereArgs";
        }
      }
      log += ";";
      print(log);
    }
    return _db!.delete(table, where: where, whereArgs: whereArgs);
  }

  // ------

  /// Truy vấn văn bản hiển thị
  Future<String?> truyVanVanBanHienThi(String tuKhoa, String phanLoai) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(
      BANG_VB_HIEN_THI,
      where: "\"phan_loai\" = ? AND \"tu_khoa\" = ?",
      whereArgs: [phanLoai, tuKhoa]
    );
    // print("DB SELECT $BANG_VB_HIEN_THI tuKhoa=$tuKhoa:\n$ketQua");
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
    final List<Map<String, Object?>> ketQua = await _query(BANG_NXB, columns: ["ten"]);
    return ketQua.map((muc) => muc["ten"] as String).toList();
  }

  // ------

  /// Chuyển đổi dữ liệu từ object sang dữ liệu cho CSDL
  Map<String, Object?> _taoDLChoBangSach(Sach thongTin) => {
    "ten" : thongTin.ten,
    "ten_kd": LinhTinh.loaiBoDautiengViet(thongTin.ten),
    "xong": thongTin.daHoanThanh ? 1 : 0,
    "isbn": thongTin.isbn,
    "xem": thoiDiemThamChieuHienTai
  };

  /// Tạo mới bản ghi sách
  Future<int> taoMoiSach(Sach thongTin) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    Map<String, Object?> duLieu = _taoDLChoBangSach(thongTin);
    duLieu["chon"] = duLieu["xem"]; // Ưu tiên gợi ý với tên mới tạo
    thongTin.maSo = await _insert(BANG_SACH, duLieu);
    return thongTin.maSo!;
  }

  /// Cập nhật thông tin sách
  Future<bool> capNhatSach(Sach thongTin) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(thongTin.maSo != null, "Thiếu mã sách để cập nhật.");
    final duLieu = _taoDLChoBangSach(thongTin);
    final ketQua = await _update(BANG_SACH, duLieu, where: "\"ma\" = ?", whereArgs: [thongTin.maSo]);
    return ketQua == 1;
  }

  /// Gán dữ liệu từ kết quả CSDL sang object
  void _ganDLVaoSach(Map<String, Object?> banGhi, Sach thongTin) {
    thongTin.maSo = banGhi["ma"] as int;
    thongTin.ten = banGhi["ten"] as String;
    thongTin.daHoanThanh = (banGhi["xong"] as int) != 0;
    thongTin.isbn = banGhi["isbn"] as String;
    thongTin.tap = banGhi["tap"] as int?;
    thongTin.maNhieuTap = banGhi["chuoi"] as int?;
  }

  /// Nạp thông tin sách
  Future<bool> napThongTinSach(Sach thongTin) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(thongTin.maSo != null, "Thiếu mã sách.");
    final duLieu = await _query(BANG_SACH, where: "\"ma\" = ?", whereArgs: [thongTin.maSo!]);
    if (duLieu.isNotEmpty) {
      final banGhiDau = duLieu.first;
      _ganDLVaoSach(banGhiDau, thongTin);
      return true;
    }
    return false;
  }

  /// Kiểm tra tên sách có tồn tại hay không
  Future<bool> kiemTraTenSach(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final duLieu = await _query(BANG_SACH, where: "\"ten\" = ?", whereArgs: [ten], limit: 1);
    return duLieu.isNotEmpty;
  }

  /// Lưu thời điểm tham chiếu vừa xem
  Future<void> luuVuaXem(String bang, int ma) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _update(bang, {"xem": thoiDiemThamChieuHienTai}, where: "\"ma\" = ?", whereArgs: [ma]);
  }

    /// Đếm tổng số sách
  Future<int> demTongSoSach() async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _rawQuery("SELECT COUNT(\"ma\") AS C FROM \"$BANG_SACH\";");
    if (ketQua.isNotEmpty) {
      return ketQua.first["C"] as int;
    }
    return 0;
  }

  /// Xoá sách
  Future<void> xoaSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(BANG_SACH, where: "\"ma\" = ?", whereArgs: [maSach]);
  }

  Future<List<Sach>> layDsSachGanDay() async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(
      BANG_SACH,
      orderBy: "\"xem\" DESC",
      limit: 5
    );
    return ketQua.map((muc) {
      final Sach sach = Sach();
      _ganDLVaoSach(muc, sach);
      return sach;
    }).toList();
  }

  // ------

  /// Gán dữ liệu từ kết quả CSDL sang object
  List<NhaXuatBan> _ganDLVaoNxb(List<Map<String, Object?>> duLieu) {
    return duLieu.map((muc) {
      final NhaXuatBan kq = NhaXuatBan();
      kq.maSo = muc["ma"] as int;
      kq.ten = muc["ten"] as String;
      kq.maLuuChieu = muc["ma_luu_chieu"] as String?;
      return kq;
    }).toList();
  }

  /// Tìm đơn vị phát hành theo tên
  Future<NhaXuatBan?> timNhaXuatBan(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(BANG_NXB, where: "\"ten\" = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      return _ganDLVaoNxb([ketQua.first]).first;
    }
    return null;
  }

  /// Thêm đơn vị phát hành
  Future<void> themNhaXuatBan(NhaXuatBan nxb) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final tdHt = thoiDiemThamChieuHienTai;
    nxb.maSo = await _insert(BANG_NXB, {
      "ten": nxb.ten,
      "ten_kd": LinhTinh.loaiBoDautiengViet(nxb.ten),
      "ma_luu_chieu": nxb.maLuuChieu,
      "chon": tdHt,
      "xem": tdHt
    });
  }

  // /// Xoá bản ghi NXB
  // Future<void> xoaNxb(NhaXuatBan nxb) async {
  //   assert(_db != null, "CSDL chưa được khởi tạo.");
  //   assert(nxb.maSo >= 0, "Thiếu mã NXB.");
  //   await _delete(BANG_NXB, where: "\"ma\" = ?", whereArgs: [nxb.maSo]);
  // }

  /// Lấy danh sách các NXB của sách
  Future<List<NhaXuatBan>> layDsNhaXuatBanCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT "$BANG_NXB"."ma", "$BANG_NXB"."ten", "$BANG_NXB"."ma_luu_chieu" FROM "$BANG_NXB"
INNER JOIN "$BANG_NXB_SACH" ON "$BANG_NXB_SACH"."nxb" = "$BANG_NXB"."ma"
WHERE "$BANG_NXB_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return _ganDLVaoNxb(ketQua);
  }

  /// Lưu đơn vị phát hành của sách
  Future<void> themNxbCuaSach(Sach sach, NhaXuatBan nxb) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(nxb.maSo >= 0, "Thiếu mã số NXB");
    await _insert(BANG_NXB_SACH, {"sach": sach.maSo!, "nxb": nxb.maSo});
  }

  /// Xoá đơn vị phát hành của sách
  Future<void> xoaNxbCuaSach(Sach sach, NhaXuatBan nxb) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(nxb.maSo >= 0, "Thiếu mã số NXB");
    await _delete(BANG_NXB_SACH, where: "\"sach\" = ? AND \"nxb\" = ?", whereArgs: [sach.maSo, nxb.maSo]);
  }

  /// Xoá tất cả đơn vị phát hành của sách
  Future<void> xoaTatCaNxbCuaSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(BANG_NXB_SACH, where: "\"sach\" = ?", whereArgs: [maSach]);
  }

//   /// Đếm số sách của NXB
//   Future<int> demSoSachCuaNXB(NhaXuatBan nxb) async {
//     assert(_db != null, "CSDL chưa được khởi tạo.");
//     assert(nxb.maSo >= 0, "Thiếu mã NXB.");
//     final List<Map<String, Object?>> ketQua = await _rawQuery(
//       """
// SELECT COUNT("sach") AS C FROM "$BANG_NXB_SACH"
// WHERE "nxb" = ?;
// """,
//       [nxb.maSo]
//     );
//     if (ketQua.isNotEmpty) {
//       return ketQua.first["C"] as int;
//     }
//     return 0;
//   }

  // ------

  /// Chuyển dữ liệu từ CSDL vào object
  List<TacGia> _ganDLVaoTacGia(List<Map<String, Object?>> duLieu) {
    return duLieu.map((muc) {
      final TacGia kq = TacGia();
      kq.maSo = muc["ma"] as int;
      kq.ten = muc["ten"] as String;
      return kq;
    }).toList();
  }

  /// Tìm tác giả theo tên
  Future<TacGia?> timTacGia(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(BANG_TAC_GIA, where: "\"ten\" = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      return _ganDLVaoTacGia([ketQua.first]).first;
    }
    return null;
  }

  /// Thêm tác giả
  Future<void> themTacGia(TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final tdht = thoiDiemThamChieuHienTai;
    tacGia.maSo = await _insert(BANG_TAC_GIA, {
      "ten": tacGia.ten,
      "ten_kd": LinhTinh.loaiBoDautiengViet(tacGia.ten),
      "chon": tdht,
      "xem": tdht
    });
  }

  /// Xoá bản ghi tác giả
  Future<void> xoaTacGia(TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(tacGia.maSo >= 0, "Thiếu mã tác giả.");
    await _delete(BANG_TAC_GIA, where: "\"ma\" = ?", whereArgs: [tacGia.maSo]);
  }

  /// Lấy danh sách các tác giả của sách
  Future<List<TacGia>> layDsTacGiaCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT "$BANG_TAC_GIA"."ma", "$BANG_TAC_GIA"."ten" FROM "$BANG_TAC_GIA"
INNER JOIN "$BANG_TAC_GIA_SACH" ON "$BANG_TAC_GIA_SACH"."tac_gia" = "$BANG_TAC_GIA"."ma"
WHERE "$BANG_TAC_GIA_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return _ganDLVaoTacGia(ketQua);
  }

  /// Lưu tác giả của sách
  Future<void> themTacGiaCuaSach(Sach sach, TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(tacGia.maSo >= 0, "Thiếu mã tác giả.");
    await _insert(BANG_TAC_GIA_SACH, {"sach": sach.maSo!, "tac_gia": tacGia.maSo});
  }

  /// Xoá tác giả của sách
  Future<void> xoaTacGiaCuaSach(Sach sach, TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(tacGia.maSo >= 0, "Thiếu mã tác giả.");
    await _delete(BANG_TAC_GIA_SACH, where: "\"sach\" = ? AND \"tac_gia\" = ?", whereArgs: [sach.maSo!, tacGia.maSo]);
  }

  /// Xoá tất cả tác giả của sách
  Future<void> xoaTatCaTacGiaCuaSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(BANG_TAC_GIA_SACH, where: "\"sach\" = ?", whereArgs: [maSach]);
  }

  /// Đếm số sách của tác giả
  Future<int> demSoSachCuaTacGia(TacGia tacGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(tacGia.maSo >= 0, "Thiếu mã tác giả.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT COUNT("sach") AS C FROM "$BANG_TAC_GIA_SACH"
WHERE "tac_gia" = ?;
""",
      [tacGia.maSo]
    );
    if (ketQua.isNotEmpty) {
      return ketQua.first["C"] as int;
    }
    return 0;
  }

  // ------

  /// Gán dữ liệu từ kết quả CSDL sang object
  List<DichGia> _ganDLVaoDichGia(List<Map<String, Object?>> duLieu) {
    return duLieu.map((muc) {
      final DichGia kq = DichGia();
      kq.maSo = muc["ma"] as int;
      kq.ten = muc["ten"] as String;
      return kq;
    }).toList();
  }

  /// Tìm dịch giả
  Future<DichGia?> timDichGia(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(BANG_DICH_GIA, where: "\"ten\" = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      return _ganDLVaoDichGia([ketQua.first]).first;
    }
    return null;
  }

  /// Thêm dịch giả
  Future<void> themDichGia(DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final tdht = thoiDiemThamChieuHienTai;
    dichGia.maSo = await _insert(BANG_DICH_GIA, {
      "ten": dichGia.ten,
      "ten_kd": LinhTinh.loaiBoDautiengViet(dichGia.ten),
      "xem": tdht,
      "chon": tdht
    });
  }

  /// Xoá bản ghi dịch giả
  Future<void> xoaDichGia(DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(dichGia.maSo >= 0, "Thiếu mã dịch giả.");
    await _delete(BANG_TAC_GIA, where: "\"ma\" = ?", whereArgs: [dichGia.maSo]);
  }

  /// Lấy danh sách các dịch giả của sách
  Future<List<DichGia>> layDsDichGiaCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT "$BANG_DICH_GIA"."ma", "$BANG_DICH_GIA"."ten" FROM "$BANG_DICH_GIA"
INNER JOIN "$BANG_DICH_GIA_SACH" ON "$BANG_DICH_GIA_SACH"."dich_gia" = "$BANG_DICH_GIA"."ma"
WHERE "$BANG_DICH_GIA_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return _ganDLVaoDichGia(ketQua);
  }

    /// Lưu dịch giả của sách
  Future<void> themDichGiaCuaSach(Sach sach, DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(dichGia.maSo >= 0, "Thiếu mã dịch giả.");
    await _insert(BANG_DICH_GIA_SACH, {"sach": sach.maSo!, "dich_gia": dichGia.maSo});
  }

  /// Xoá dịch giả của sách
  Future<void> xoaDichGiaCuaSach(Sach sach, DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(dichGia.maSo >= 0, "Thiếu mã dịch giả.");
    await _delete(BANG_DICH_GIA_SACH, where: "\"sach\" = ? AND \"dich_gia\" = ?", whereArgs: [sach.maSo!, dichGia.maSo]);
  }

  /// Xoá tất cả dịch giả của sách
  Future<void> xoaTatCaDichGiaCuaSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(BANG_DICH_GIA_SACH, where: "\"sach\" = ?", whereArgs: [maSach]);
  }

  /// Đếm số sách của dịch giả
  Future<int> demSoSachCuaDichGia(DichGia dichGia) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(dichGia.maSo >= 0, "Thiếu mã dịch giả.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT COUNT("sach") AS C FROM "$BANG_DICH_GIA_SACH"
WHERE "dich_gia" = ?;
""",
      [dichGia.maSo]
    );
    if (ketQua.isNotEmpty) {
      return ketQua.first["C"] as int;
    }
    return 0;
  }

  // ------

  /// Gán dữ liệu từ kết quả CSDL sang object
  List<ViTriSach> _ganDLVaoViTriSach(List<Map<String, Object?>> duLieu) {
    return duLieu.map((muc) {
      final ViTriSach kq = ViTriSach();
      kq.maSo = muc["ma"] as int;
      kq.ten = muc["ten"] as String;
      kq.thoiGian = (muc["ngay_nhap"] as int?) ?? -1;
      return kq;
    }).toList();
  }

  /// Tìm vị trí
  Future<ViTriSach?> timViTri(String ten) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(BANG_VI_TRI, where: "\"ten\" = ?", whereArgs: [ten]);
    if (ketQua.isNotEmpty) {
      return _ganDLVaoViTriSach([ketQua.first]).first;
    }
    return null;
  }

  /// Thêm vị trí
  Future<void> themViTri(ViTriSach vt) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final tdht = thoiDiemThamChieuHienTai;
    vt.maSo = await _insert(BANG_VI_TRI, {
      "ten": vt.ten,
      "ten_kd": LinhTinh.loaiBoDautiengViet(vt.ten),
      "xem": tdht,
      "chon": tdht
    });
  }

  /// Xoá vị trí
  Future<void> xoaViTri(ViTriSach vt) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(vt.maSo >= 0, "Thiếu mã vị trí.");
    await _delete(
      BANG_VI_TRI,
      where: "\"ma\" = ?",
      whereArgs: [vt.maSo]
    );
  }

  /// Lấy danh sách các vị trí của sách
  Future<List<ViTriSach>> layDsViTriCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT "$BANG_VI_TRI"."ma", "$BANG_VI_TRI"."ten", "$BANG_VI_TRI_SACH"."ngay_nhap" FROM "$BANG_VI_TRI"
INNER JOIN "$BANG_VI_TRI_SACH" ON "$BANG_VI_TRI_SACH"."vi_tri" = "$BANG_VI_TRI"."ma"
WHERE "$BANG_VI_TRI_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return _ganDLVaoViTriSach(ketQua);
  }

  /// Lưu vị trí của sách
  Future<void> themViTriCuaSach(Sach sach, ViTriSach viTri) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(viTri.maSo >= 0, "Thiếu mã vị trí.");
    final now = DateTime.now().millisecondsSinceEpoch;
    await _insert(BANG_VI_TRI_SACH, {"sach": sach.maSo!, "vi_tri": viTri.maSo, "ngay_nhap": now});
  }

  /// Xoá vị trí của sách
  Future<void> xoaViTriCuaSach(Sach sach, ViTriSach viTri) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(viTri.maSo >= 0, "Thiếu mã vị trí.");
    await _delete(BANG_VI_TRI_SACH, where: "\"sach\" = ? AND \"vi_tri\" = ?", whereArgs: [sach.maSo!, viTri.maSo]);
  }

  /// Xoá tất cả các vị trí của sách
  Future<void> xoaTatCaViTriCuaSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(BANG_VI_TRI_SACH, where: "\"sach\" = ?", whereArgs: [maSach]);
  }

  /// Đếm số sách của vị trí
  Future<int> demSoSachCuaViTri(ViTriSach viTri) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(viTri.maSo >= 0, "Thiếu mã vị trí.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT COUNT("sach") AS C FROM "$BANG_VI_TRI_SACH"
WHERE "vi_tri" = ?;
""",
      [viTri.maSo]
    );
    if (ketQua.isNotEmpty) {
      return ketQua.first["C"] as int;
    }
    return 0;
  }

  // ------

  /// Lấy ảnh của sách
  Future<void> layAnhSach(Sach sach) async {
    assert(sach.maSo != null, "Thiếu mã sách để cập nhật.");
    final duongDanAnh = join(_thuMucAnhSach, "${sach.maSo!}.jpg");
    if (await File(duongDanAnh).exists()) {
      sach.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: duongDanAnh);
    }
    final duongDanAnhNho = join(_thuMucAnhSach, "${sach.maSo!}_tn.jpg");
    if (await File(duongDanAnhNho).exists()) {
      sach.hinhThuNho = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: duongDanAnhNho);
    }
  }

  /// Lưu ảnh của sách
  Future<void> luuAnhSach(Sach sach) async {
    assert(sach.maSo != null, "Thiếu mã sách để cập nhật.");
    final String duongDanAnh = join(_thuMucAnhSach, "${sach.maSo!}.jpg");
    final String duongDanAnhNho = join(_thuMucAnhSach, "${sach.maSo!}_tn.jpg");
    final File fileAnh = File(duongDanAnh);
    final File fileAnhNho = File(duongDanAnhNho);
    bool xoaDemAnh = false;
    if (sach.hinhAnh != null && sach.hinhAnh!.path != duongDanAnh) {
      // final ImgImage? anh = await Isolations.napAnhTuXFile(sach.hinhAnh!);
      // if (anh != null) {
      //   encodeJpgFile(duongDanAnh, anh);
      //   final ImgImage? anhThuNho = await Isolations.taoAnhThuNho(anh);
      //   if (anhThuNho != null) {
      //     encodeJpgFile(duongDanAnhNho, anhThuNho);
      //   }
      // }
      xoaDemAnh = true;
      await HeThongMay.duyNhat.luuAnhSach(anhGoc: sach.hinhAnh!.path, mucTieu: duongDanAnh, anhThuNho: duongDanAnhNho);
    } else if (sach.hinhAnh == null) {
      sach.hinhThuNho = null;
      xoaDemAnh = true;
      if (await fileAnh.exists()) {
        await fileAnh.delete();
      }
      if (await fileAnhNho.exists()) {
        await fileAnhNho.delete();
      }
    }
    if (xoaDemAnh) {
      if (await fileAnh.exists()) {
        final FileImage dem = FileImage(fileAnh);
        await dem.evict();
      }
      if (await fileAnhNho.exists()) {
        final FileImage dem = FileImage(fileAnhNho);
        await dem.evict();
      }
    }
  }

  Future<void> _xoaAnh(String anh) async {
    final File fileAnh = File(anh);
    if (await fileAnh.exists()) {
      await fileAnh.delete();
    }
  }

  /// Xoá ảnh của sách
  Future<void> xoaAnhCuaSach(int maSach) async {
    final String duongDanAnh = join(_thuMucAnhSach, "$maSach.jpg");
    final String duongDanAnhNho = join(_thuMucAnhSach, "$maSach.jpg");
    _xoaAnh(duongDanAnhNho);
    _xoaAnh(duongDanAnh);
  }

  // ------

  /// Tìm kiếm gợi ý từ bảng [bang] với cột `ten LIKE %[tuKhoa]% OR ten_kd LIKE %[tuKhoa kd]%` (kd: không dấu)
  Future<List<VanBanNoiBat>> timKiemGoiY(String bang, String tuKhoa) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final String tkKd = LinhTinh.loaiBoDautiengViet(tuKhoa);
    // print("TimKiemGoiY: $bang; $tuKhoa; $tkKd");
    final ketQua = tuKhoa.isEmpty ?
      await _query(
        bang,
        columns: ["ten", "chon"],
        orderBy: "\"chon\" DESC",
        limit: 5,
      ) :
      await _query(
        bang,
        columns: ["ten", "chon"],
        where: "\"ten\" LIKE ? OR \"ten_kd\" LIKE ?",
        whereArgs: ["%$tuKhoa%", "%$tkKd%"]
      );
    return ketQua.map((muc) => VanBanNoiBat(vanBanDayDu: muc["ten"] as String, vanBanNoiBat: [tuKhoa], daChon: muc["chon"] as int?)).toList();
  }

  /// Lưu thời điểm đã chọn gợi ý vào bảng [bang]
  Future<void> luuThoiDiemChonGoiY(String bang, String tuKhoa) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _update(bang, {"chon": thoiDiemThamChieuHienTai}, where: "\"ten\" = ?", whereArgs: [tuKhoa]);
  }

  // ------

  /// Tìm kiếm giá trị nhãn
  Future<List<VanBanNoiBat>> timKiemGiaTriNhan(String tenNhan, String tuKhoa) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final String tkKd = LinhTinh.loaiBoDautiengViet(tuKhoa);
    final List<Map<String, Object?>> ketQua = tuKhoa.isEmpty ?
      await _rawQuery(
        """
SELECT "$BANG_NHAN_SACH"."gia_tri", MAX("$BANG_NHAN_SACH"."chon") AS "chon" FROM "$BANG_NHAN_SACH"
INNER JOIN "$BANG_NHAN" ON "$BANG_NHAN_SACH"."nhan" = "$BANG_NHAN"."ma"
WHERE "$BANG_NHAN"."ten" = ?
GROUP BY "$BANG_NHAN_SACH"."gia_tri"
ORDER BY "chon" DESC
LIMIT 5;
""",
      [tenNhan]
    ) :
     await _rawQuery(
      """
SELECT "$BANG_NHAN_SACH"."gia_tri", MAX("$BANG_NHAN_SACH"."chon") AS "chon" FROM "$BANG_NHAN_SACH"
INNER JOIN "$BANG_NHAN" ON "$BANG_NHAN_SACH"."nhan" = "$BANG_NHAN"."ma"
WHERE "$BANG_NHAN"."ten" = ? AND ("$BANG_NHAN_SACH"."gia_tri" LIKE ? OR "$BANG_NHAN_SACH"."gia_tri_kd" LIKE ?)
GROUP BY "$BANG_NHAN_SACH"."gia_tri";
""",
      [tenNhan, "%$tuKhoa%", "%$tkKd%"]
    );
    return ketQua.map((muc) => VanBanNoiBat(vanBanDayDu: muc["gia_tri"] as String, vanBanNoiBat: [tuKhoa], daChon: muc["chon"] as int?)).toList();
  }

  /// Lưu thời điểm chọn giá trị nhãn
  Future<void> luuThoiDiemChonGiaTriNhan(String tenNhan, String tuKhoa) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final kqNhan = await _query(BANG_NHAN, columns: ["ma"], where: "\"ten\" = ?", whereArgs: [tenNhan]);
    final td = {"chon": thoiDiemThamChieuHienTai};
    if (kqNhan.isNotEmpty) {
      for (final muc in kqNhan) {
        final int nhan = muc["ma"] as int;
        _update(BANG_NHAN_SACH, td, where: "\"nhan\" = ? AND \"gia_tri\" = ?", whereArgs: [nhan, tuKhoa]);
      }
    }
  }

  /// Lấy danh sách nhãn luôn hiện
  Future<List<String>> layDSNhanLuonHien() async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final ketQua = await _query(BANG_NHAN, columns: ["ten"], where: "\"luon_hien\" > 0");
    return ketQua.map((muc) => muc["ten"] as String).toList();
  }

  /// Gán dữ liệu từ kết quả CSDL sang object
  List<NhanSach> _ganDLVaoNhan(List<Map<String, Object?>> duLieu) {
    return duLieu.map((muc) {
      final NhanSach kq = NhanSach();
      kq.maSo = muc["ma"] as int;
      kq.ten = muc["ten"] as String;
      kq.giaTri = muc["gia_tri"] as String?;
      kq.luonHien = (muc["luon_hien"] as int?) ?? 0;
      return kq;
    }).toList();
  }

  /// Lấy danh sách nhãn có tên trong danh sách
  Future<List<NhanSach>> layDSNhan(List<String> tenNhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(tenNhan.isNotEmpty, "Danh sách tên nhãn rỗng.");
    String thamSo = List<String>.filled(tenNhan.length, "?").join(",");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT "$BANG_NHAN"."ma", "$BANG_NHAN"."ten", "$BANG_NHAN"."luon_hien" FROM "$BANG_NHAN"
WHERE "$BANG_NHAN"."ten" IN ($thamSo);
""",
      tenNhan
    );
    return _ganDLVaoNhan(ketQua);
  }

  /// Thêm nhãn
  Future<void> themNhan(NhanSach nhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final tdht = thoiDiemThamChieuHienTai;
    nhan.maSo = await _insert(BANG_NHAN, {
      "ten": nhan.ten,
      "ten_kd": LinhTinh.loaiBoDautiengViet(nhan.ten),
      "chon": tdht,
      "luon_hien": nhan.luonHien
    });
  }

  /// Xoá nhãn
  Future<void> xoaNhan(NhanSach nhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(nhan.maSo >= 0, "Thiếu mã nhãn.");
    await _delete(
      BANG_NHAN,
      where: "\"ma\" = ?",
      whereArgs: [nhan.maSo]
    );
  }

  /// Lấy danh sách nhãn của sách
  Future<List<NhanSach>> layDSNhanCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT "$BANG_NHAN"."ma", "$BANG_NHAN"."ten", "$BANG_NHAN"."luon_hien", "$BANG_NHAN_SACH"."gia_tri" FROM "$BANG_NHAN"
INNER JOIN "$BANG_NHAN_SACH" ON "$BANG_NHAN_SACH"."nhan" = "$BANG_NHAN"."ma"
WHERE "$BANG_NHAN_SACH"."sach" = ?;
""",
      [sach.maSo!]
    );
    return _ganDLVaoNhan(ketQua);
  }

  /// Thêm nhãn cho sách
  Future<void> themNhanChoSach(Sach sach, NhanSach nhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(nhan.maSo >= 0, "Thiếu mã nhãn.");
    final tdht = thoiDiemThamChieuHienTai;
    await _insert(BANG_NHAN_SACH, {
      "sach": sach.maSo,
      "nhan": nhan.maSo,
      "gia_tri": nhan.giaTri,
      "gia_tri_kd": LinhTinh.loaiBoDautiengViet(nhan.giaTri ?? ""),
      "chon": tdht
    });
  }

  /// Cập nhật giá trị nhãn của sách
  Future<void> capNhatNhanChoSach(Sach sach, NhanSach nhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(nhan.maSo >= 0, "Thiếu mã nhãn.");
    await _update(
      BANG_NHAN_SACH,
      {
        "gia_tri": nhan.giaTri,
        "gia_tri_kd": LinhTinh.loaiBoDautiengViet(nhan.giaTri ?? "")
      },
      where: "\"sach\" = ? AND \"nhan\" = ?",
      whereArgs: [sach.maSo, nhan.maSo]
    );
  }

  /// Xoá nhãn của sách
  Future<void> xoaNhanChoSach(Sach sach, NhanSach nhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    assert(nhan.maSo >= 0, "Thiếu mã nhãn.");
    await _delete(
      BANG_NHAN_SACH,
      where: "\"sach\" = ? AND \"nhan\" = ?",
      whereArgs: [sach.maSo, nhan.maSo]
    );
  }

  /// Xoá tất cả nhãn của sách
  Future<void> xoaTatCaNhanChoSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(
      BANG_NHAN_SACH,
      where: "\"sach\" = ?",
      whereArgs: [maSach]
    );
  }

  /// Đặt lại tất cả giá trị của trường `luon_hien`
  Future<void> datLaiLuonHienCuaNhan() async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _update(
      BANG_NHAN,
      { "luon_hien": 0 }
    );
  }

  /// Đặt giá trị `luon_hien` của các nhãn
  Future<void> datLuonHienCuaNhan(List<String> dsNhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final String thamSo = List<String>.filled(dsNhan.length, "?").join(",");
    await _update(
      BANG_NHAN,
      { "luon_hien": 1 },
      where: "\"ten\" IN ($thamSo)",
      whereArgs: dsNhan
    );
  }

  /// Đếm số giá trị của nhãn sách
  Future<int> demSoGiaTriCuaNhan(NhanSach nhan) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(nhan.maSo >= 0, "Thiếu mã nhãn sách.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT COUNT("sach") AS C FROM "$BANG_NHAN_SACH"
WHERE "nhan" = ?;
""",
      [nhan.maSo]
    );
    if (ketQua.isNotEmpty) {
      return ketQua.first["C"] as int;
    }
    return 0;
  }

  // ------

  /// Lấy danh sách đánh dấu của sách
  Future<List<DanhDauSach>> layDSDanhDauCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    final List<Map<String, Object?>> ketQua = await _query(
      BANG_DANH_DAU,
      where: "\"sach\" = ?",
      whereArgs: [sach.maSo!],
      orderBy: "\"thoi_gian\""
    );
    return ketQua.map((muc) {
      final DanhDauSach danhDau = DanhDauSach();
      danhDau.maSo = muc["ma"] as int;
      danhDau.maSach = muc["sach"] as int;
      danhDau.noiDung = muc["ghi_chu"] as String;
      return danhDau;
    }).toList();
  }

  /// Thêm đánh dấu cho sách
  Future<void> themDanhDauChoSach(DanhDauSach danhDau) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(danhDau.maSach >= 0, "Thiếu mã sách.");
    final tdht = thoiDiemThamChieuHienTai;
    danhDau.maSo = await _insert(BANG_DANH_DAU, {
      "sach": danhDau.maSach,
      "ghi_chu": danhDau.noiDung,
      "ghi_chu_kd": LinhTinh.loaiBoDautiengViet(danhDau.noiDung),
      "thoi_gian": tdht
    });
  }

  /// Xoá đánh dấu của sách
  Future<void> xoaDanhDau(DanhDauSach danhDau) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(danhDau.maSo >= 0, "Thiếu mã đánh dấu.");
    await _delete(
      BANG_DANH_DAU,
      where: "\"ma\" = ?",
      whereArgs: [danhDau.maSo]
    );
  }

  /// Xoá tất cả đánh dấu của sách
  Future<void> xoaTatCaDanhDauCuaSach(int maSach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(
      BANG_DANH_DAU,
      where: "\"sach\" = ?",
      whereArgs: [maSach]
    );
  }

  /// Lấy danh sách các sách có đánh dấu
  Future<List<Sach>> layDanhSachSachDanhDau() async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> banGhiS = await _rawQuery("""
SELECT "$BANG_SACH".*, "$BANG_DANH_DAU"."ma" AS "ma_dd", "$BANG_DANH_DAU"."ghi_chu" FROM "$BANG_SACH"
INNER JOIN "$BANG_DANH_DAU" ON "$BANG_SACH"."ma" = "$BANG_DANH_DAU"."sach"
ORDER BY "$BANG_DANH_DAU"."thoi_gian" DESC;
""");
    List<Sach> ketQua = [];
    for (final Map<String, Object?> banGhi in banGhiS) {
      final Sach sach = Sach();
      _ganDLVaoSach(banGhi, sach);
      final DanhDauSach danhDau = DanhDauSach();
      danhDau.maSach = sach.maSo ?? 0;
      danhDau.maSo = banGhi["ma_dd"] as int;
      danhDau.noiDung = (banGhi["ghi_chu"] as String?) ?? "";
      sach.danhDau = [danhDau];
      ketQua.add(sach);
    }
    return ketQua;
  }

  // ------

  /// Gán dữ liệu cho object SachNhieuTap
  List<SachNhieuTap> _ganDLVaoChuoiSachNhieuTap(List<Map<String, Object?>> duLieu) {
    return duLieu.map((muc) {
      final SachNhieuTap kq = SachNhieuTap();
      kq.maSo = muc["ma"] as int;
      kq.ten = muc["ghi_chu"] as String;
      return kq;
    }).toList();
  }

  /// Nạp thông tin cho chuỗi sách nhiều tập
  Future<SachNhieuTap?> timChuoiSachNhieuTap(int maSo) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    List<Map<String, Object?>> ketQua = await _query(
      BANG_NHIEU_TAP,
      where: "\"ma\" = ?",
      whereArgs: [maSo]
    );
    if (ketQua.isNotEmpty) {
      return _ganDLVaoChuoiSachNhieuTap([ketQua.first]).first;
    }
    return null;
  }

  /// Thêm mới chuỗi sách nhiều tập
  Future<void> themChuoiSachNhieuTap(SachNhieuTap chuoi) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    chuoi.maSo = await _insert(
      BANG_NHIEU_TAP,
      {
        "ghi_chu": chuoi.ten,
        "ghi_chu_kd": LinhTinh.loaiBoDautiengViet(chuoi.ten)
      }
    );
  }

  /// Thêm mới chuỗi sách nhiều tập
  Future<void> suaChuoiSachNhieuTap(SachNhieuTap chuoi) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(chuoi.maSo >= 0, "Thiếu mã chuỗi sách.");
    chuoi.maSo = await _update(
      BANG_NHIEU_TAP,
      {
        "ghi_chu": chuoi.ten,
        "ghi_chu_kd": LinhTinh.loaiBoDautiengViet(chuoi.ten)
      },
      where: "\"ma\" = ?",
      whereArgs: [chuoi.maSo]
    );
  }

  /// Lấy danh sách sách thuộc chuỗi
  Future<List<Sach>> layDanhSachSachThuocChuoi(int maChuoi) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    List<Map<String, Object?>> ketQua = await _query(
      BANG_SACH,
      where: "\"chuoi\" = ?",
      whereArgs: [maChuoi]
    );
    return _chuyenDoiDuLieuSach(ketQua);
  }

  /// Xoá chuỗi sách nhiều tập
  Future<void> xoaChuoiSachNhieuTap(int maNhieuTap) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _delete(
      BANG_NHIEU_TAP,
      where: "\"ma\" = ?",
      whereArgs: [maNhieuTap]
    );
  }

  Future<void> luuThongTinNhieuTapCuaSach(Sach sach) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    assert(sach.maSo != null, "Thiếu mã sách.");
    await _update(
      BANG_SACH,
      {
        "chuoi": sach.maNhieuTap,
        "tap": sach.tap
      },
      where: "\"ma\" = ?",
      whereArgs: [sach.maSo]
    );
  }

  /// Đếm số giá trị của nhãn sách
  Future<int> demSoSachChuoiNhieuTap(int maNhieuTap) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _rawQuery(
      """
SELECT COUNT("ma") AS C FROM "$BANG_SACH"
WHERE "chuoi" = ?;
""",
      [maNhieuTap]
    );
    if (ketQua.isNotEmpty) {
      return ketQua.first["C"] as int;
    }
    return 0;
  }

  Future<void> xoaHetSachKhoiChuoi(int maNhieuTap) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    await _update(
      BANG_SACH,
      {
        "chuoi": null,
        "tap": null
      },
      where: "\"chuoi\" = ?",
      whereArgs: [maNhieuTap]
    );
  }

  // ------ Tìm kiếm

  /// Tìm kiếm theo từ khoá từ 1 bảng
  Future<List<Map<String, Object?>>> _timKiemTheoTuKhoa({
    required String bang,
    required String tuKhoa,
    String truong = "ten",
    List<String>? dieuKienAnd,
    List<Object?>? dieuKienAndArgs
  }) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final String tuKhoaKd = LinhTinh.loaiBoDautiengViet(tuKhoa);
    String where = "";
    List<Object?> args = [];
    if (tuKhoa.isNotEmpty) {
      where = "\"$truong\" LIKE ? OR \"${truong}_kd\" LIKE ?";
      args = ["%$tuKhoa%", "%$tuKhoaKd%"];
    }
    if (dieuKienAnd != null && dieuKienAnd.isNotEmpty) {
      if (where.isNotEmpty) {
        where = "($where) AND";
      }
      int stt = 0;
      for (final String dk in dieuKienAnd) {
        if (stt == dieuKienAnd.length -  1) {
          where += " $dk";
        } else {
          where += " $dk AND";
        }
        stt += 1;
      }
      where = where.trim();
      if (dieuKienAndArgs != null) {
        args.addAll(dieuKienAndArgs);
      }
    }
    if (where.isEmpty) {
      return [];
    }
    final List<Map<String, Object?>> ketQua = await _query(
      bang,
      distinct: true,
      where: where,
      whereArgs: args
    );
    final List<VanBanNoiBat> dsSapXep = ketQua.map((muc) => VanBanNoiBat(vanBanDayDu: muc[truong] as String, vanBanNoiBat: [tuKhoa], duLieuDinhKem: muc)).toList();
    dsSapXep.sapXep();
    return dsSapXep.map((muc) => muc.duLieuDinhKem as Map<String, Object?>).toList();
  }

  /// Tìm kiếm tác giả
  Future<List<TacGia>> timKiemTacGia(String tuKhoa) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_TAC_GIA,
      tuKhoa: tuKhoa
    );
    return _ganDLVaoTacGia(ketQua);
  }

  /// Tìm kiếm dịch giả
  Future<List<DichGia>> timKiemDichGia(String tuKhoa) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_DICH_GIA,
      tuKhoa: tuKhoa
    );
    return _ganDLVaoDichGia(ketQua);
  }

  /// Tìm kiếm nhà xuất bản
  Future<List<NhaXuatBan>> timKiemNXB(String tuKhoa) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_NXB,
      tuKhoa: tuKhoa
    );
    return _ganDLVaoNxb(ketQua);
  }

  /// Tìm kiếm vị trí sách
  Future<List<ViTriSach>> timKiemViTriSach(String tuKhoa) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_VI_TRI,
      tuKhoa: tuKhoa
    );
    return _ganDLVaoViTriSach(ketQua);
  }

  /// Tìm kiếm tên nhãn
  Future<List<NhanSach>> timKiemTenNhan(String tuKhoa) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_NHAN,
      tuKhoa: tuKhoa
    );
    return _ganDLVaoNhan(ketQua);
  }

  /// Tìm kiếm giá trị nhãn
  Future<List<String>> timKiemGtNhan(String tuKhoa, NhanSach nhan) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_NHAN_SACH,
      tuKhoa: tuKhoa,
      truong: "gia_tri",
      dieuKienAnd: ["\"nhan\" = ?"],
      dieuKienAndArgs: [nhan.maSo]
    );
    return ketQua.map((muc) {
      return muc["gia_tri"] as String;
    }).toList();
  }

  /// Tìm kiếm Sách nhiều tập
  Future<List<SachNhieuTap>> timKiemSachNhieuTap(String tuKhoa) async {
    final List<Map<String, Object?>> ketQua = await _timKiemTheoTuKhoa(
      bang: BANG_NHIEU_TAP,
      tuKhoa: tuKhoa,
      truong: "ghi_chu"
    );
    return _ganDLVaoChuoiSachNhieuTap(ketQua);
  }

  /// Xây dựng điều kiện tìm sách
  void _xayDungDieuKienTimSach(
    List<int>? danhSach,
    List<String> whereStatements, List<Object?> whereArgs, List<String> joinStatements,
    String tenBang, String truong
  ) {
    if (danhSach != null && danhSach.isNotEmpty) {
      int stt = 0;
      for (final muc in danhSach) {
        final String tenAs = "\"${tenBang}_$stt\"";
        joinStatements.add("INNER JOIN \"$tenBang\" AS $tenAs ON \"$BANG_SACH\".\"ma\" = $tenAs.\"sach\"");
        whereStatements.add("$tenAs.\"$truong\" = ?");
        whereArgs.add(muc);
        stt += 1;
      }
    }
  }

  /// Gán giá trị dữ liệu vào object
  List<Sach> _chuyenDoiDuLieuSach(List<Map<String, Object?>> banGhi) {
    return banGhi.map((muc) {
      final Sach kq = Sach();
      _ganDLVaoSach(muc, kq);
      return kq;
    }).toList();
  }

  /// Thực hiện tìm kiếm sách
  Future<List<Sach>> _thucHienTimKiemSach(
    List<int>? tacGia,
    List<int>? dichGia,
    List<int>? nxb,
    List<int>? viTri,
    List<NhanSach>? nhan,
    int? nhieuTap,
    List<String> whereStatements, List<Object?> whereArgs, List<String> joinStatements
  ) async {
    _xayDungDieuKienTimSach(tacGia, whereStatements, whereArgs, joinStatements, BANG_TAC_GIA_SACH, "tac_gia");
    _xayDungDieuKienTimSach(dichGia, whereStatements, whereArgs, joinStatements, BANG_DICH_GIA_SACH, "dich_gia");
    _xayDungDieuKienTimSach(nxb, whereStatements, whereArgs, joinStatements, BANG_NXB_SACH, "nxb");
    _xayDungDieuKienTimSach(viTri, whereStatements, whereArgs, joinStatements, BANG_VI_TRI_SACH, "vi_tri");
    if (nhan != null && nhan.isNotEmpty) {
      int stt = 0;
      for (final muc in nhan) {
        final String tenAs = "\"${BANG_NHAN_SACH}_$stt\"";
        joinStatements.add("INNER JOIN \"$BANG_NHAN_SACH\" AS $tenAs ON \"$BANG_SACH\".\"ma\" = $tenAs.\"sach\"");
        whereStatements.add("$tenAs.\"nhan\" = ?");
        whereArgs.add(muc.maSo);
        if (muc.giaTri != null && muc.giaTri!.isNotEmpty) {
          final String gtKd = LinhTinh.loaiBoDautiengViet(muc.giaTri!);
          whereStatements.add("($tenAs.\"gia_tri\" LIKE ? OR $tenAs.\"gia_tri_kd\" LIKE ?)");
          whereArgs.add("%${muc.giaTri!}%");
          whereArgs.add("%$gtKd%");
        } else {
          whereStatements.add("$tenAs.\"gia_tri\" != \"\"");
        }
        stt += 1;
      }
    }
    if (nhieuTap != null) {
      whereStatements.add("\"$BANG_SACH\".\"chuoi\" = ?");
      whereArgs.add(nhieuTap);
    }
    if (whereStatements.isEmpty) { return []; }
    String sqlStatement = "SELECT \"$BANG_SACH\".* FROM \"$BANG_SACH\"";
    if (joinStatements.isNotEmpty) {
      sqlStatement += "\n${joinStatements.join("\n")}";
    }
    sqlStatement += "\nWHERE ${whereStatements.join(" AND ")}";
    sqlStatement += "\nGROUP BY \"$BANG_SACH\".\"ma\"";
    sqlStatement += "\nORDER BY \"$BANG_SACH\".\"xem\" DESC;";
    List<Map<String, Object?>> ketQua = await _rawQuery(sqlStatement, whereArgs);
    return _chuyenDoiDuLieuSach(ketQua);
  }

  /// Tìm kiếm sách theo từ khoá hoặc các bộ lọc
  Future<List<Sach>> timKiemSach({
    required String tuKhoa,
    List<int>? tacGia,
    List<int>? dichGia,
    List<int>? nxb,
    List<int>? viTri,
    List<NhanSach>? nhan,
    int? nhieuTap
  }) async {
    List<String> whereStatements = [];
    List<Object?> whereArgs = [];
    List<String> joinStatements = [];
    if (tuKhoa.isNotEmpty) {
      final String tkKd = LinhTinh.loaiBoDautiengViet(tuKhoa);
      whereStatements.add("(\"$BANG_SACH\".\"ten\" LIKE ? OR \"$BANG_SACH\".\"ten_kd\" LIKE ?)");
      whereArgs.add("%$tuKhoa%");
      whereArgs.add("%$tkKd%");
    }
    return await _thucHienTimKiemSach(tacGia, dichGia, nxb, viTri, nhan, nhieuTap, whereStatements, whereArgs, joinStatements);
  }

  /// Tìm kiếm sách theo ISBN và các bộ lọc
  Future<List<Sach>> timKiemSachTheoISBN({
    required String tuKhoa,
    List<int>? tacGia,
    List<int>? dichGia,
    List<int>? nxb,
    List<int>? viTri,
    List<NhanSach>? nhan,
    int? nhieuTap
  }) async {
    if (tuKhoa.isEmpty) { return []; }
    List<String> whereStatements = [];
    List<Object?> whereArgs = [];
    List<String> joinStatements = [];
    whereStatements.add("\"$BANG_SACH\".\"isbn\" LIKE ?");
    whereArgs.add("%$tuKhoa%");
    return await _thucHienTimKiemSach(tacGia, dichGia, nxb, viTri, nhan, nhieuTap, whereStatements, whereArgs, joinStatements);
  }

  /// Tìm kiếm sách theo Đánh dấu và các bộ lọc
  Future<List<Sach>> timKiemSachTheoDanhDau({
    required String tuKhoa,
    List<int>? tacGia,
    List<int>? dichGia,
    List<int>? nxb,
    List<int>? viTri,
    List<NhanSach>? nhan,
    int? nhieuTap
  }) async {
    if (tuKhoa.isEmpty) { return []; }
    List<String> whereStatements = [];
    List<Object?> whereArgs = [];
    List<String> joinStatements = [];
    joinStatements.add("INNER JOIN \"$BANG_DANH_DAU\" ON \"$BANG_SACH\".\"ma\" = \"$BANG_DANH_DAU\".\"sach\"");
    final String tkKd = LinhTinh.loaiBoDautiengViet(tuKhoa);
    whereStatements.add("(\"$BANG_DANH_DAU\".\"ghi_chu\" LIKE ? OR \"$BANG_DANH_DAU\".\"ghi_chu_kd\" LIKE ?)");
    whereArgs.add("%$tuKhoa%");
    whereArgs.add("%$tkKd%");
    return await _thucHienTimKiemSach(tacGia, dichGia, nxb, viTri, nhan, nhieuTap, whereStatements, whereArgs, joinStatements);
  }

  /// Tìm sách theo mã ISBN
  Future<int?> timSachTheoISBN(String isbn) async {
    assert(_db != null, "CSDL chưa được khởi tạo.");
    final List<Map<String, Object?>> ketQua = await _query(
      BANG_SACH,
      where: "\"isbn\" = ?",
      whereArgs: [isbn]
    );
    if (ketQua.isNotEmpty) {
      return ketQua.first["ma"] as int;
    }
    return null;
  }

}
