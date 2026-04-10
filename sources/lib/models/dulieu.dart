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

import 'package:flutter/material.dart' as Ui;
import 'package:image/image.dart' as Img;
import 'package:sach_cua_t/utils/common.dart';

typedef UiImage = Ui.Image;
typedef ImgImage = Img.Image;

/// Sách
class Sach {
  int? maSo;
  String ten = "";
  bool daHoanThanh = false;
  String isbn = "";
  int? maNhieuTap;
  int? tap;
  Uri? hinhAnh;
  Uri? hinhThuNho;

  List<String> nhaXuatBan = [];
  List<String> tacGia = [];
  List<String> dichGia = [];
  List<String> viTri = [];
  Map<String, String> nhan = {};
  List<String> nhanLuonHien = [];
  List<String> danhDau = [];
  String? nhieuTap;

  static Sach taoDuLieuGia({int chiSo = 0}) {
    Sach ketQua = Sach();
    ketQua.maSo = chiSo;
    ketQua.ten = "Tên sách $chiSo";
    ketQua.isbn = "1234567890";
    ketQua.tacGia.add("Tác giả 01");
    ketQua.tacGia.add("Tác giả 02");
    ketQua.dichGia.add("Dịch giả 01");
    ketQua.dichGia.add("Dịch giả 02");
    ketQua.nhaXuatBan.add("Nhà xuất bản 01");
    ketQua.nhaXuatBan.add("Nhà xuất bản 02");
    ketQua.viTri.add("Vị trí 01");
    ketQua.viTri.add("Vị trí 02");
    ketQua.tap = chiSo;
    ketQua.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.assets, duongDan: "assets/book.jpg");
    ketQua.hinhThuNho = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.assets, duongDan: "assets/book.jpg");
    ketQua.danhDau.add("Danh dau 01");
    ketQua.nhieuTap = "Nhieu tap 01";
    ketQua.nhan = {"Nhan sach 01": "Gia tri nhan 01"};
    return ketQua;
  }

  void inThongTinChiTiet() {
    print("SACH:");
    print("       ma so: $maSo");
    print("         ten: '$ten'");
    print("        ISBN: '$isbn'");
    print("     tac gia: '$tacGia'");
    print("    dich gia: '$dichGia'");
    print("         NXB: '$nhaXuatBan'");
    print("      vi tri: '$viTri'");
    print("         tap: $tap");
    print("    hinh anh: '${hinhAnh?.toString()}'");
    print("    hinh nho: '${hinhThuNho?.toString()}'");
    print("        xong: '$daHoanThanh'");
    print("        nhan: '$nhan'");
    print("  nhan lHien: '$nhanLuonHien'");
    print("    danh dau: '$danhDau'");
  }

}

abstract class DuLieuCoso {
  int maSo = -1;
  String ten = "";
}

/// Nhà xuất bản, đơn vị phát hành
class NhaXuatBan extends DuLieuCoso {
  String? maLuuChieu;

  static NhaXuatBan taoDuLieuGia({int chiSo = 0}) {
    NhaXuatBan ketQua = NhaXuatBan();
    ketQua.maSo = chiSo;
    ketQua.ten = "NXB 0$chiSo";
    return ketQua;
  }
}

/// Tác giả
class TacGia extends DuLieuCoso {

  static TacGia taoDuLieuGia({int chiSo = 0}) {
    TacGia ketQua = TacGia();
    ketQua.maSo = chiSo;
    ketQua.ten = "Tac gia 0$chiSo";
    return ketQua;
  }

}

/// Dịch giả
class DichGia extends DuLieuCoso {

  static DichGia taoDuLieuGia({int chiSo = 0}) {
    DichGia ketQua = DichGia();
    ketQua.maSo = chiSo;
    ketQua.ten = "Dich gia 0$chiSo";
    return ketQua;
  }

}

/// Chuỗi sách nhiều tập
class SachNhieuTap extends DuLieuCoso {

  List<Sach> dsSach = [];

  static SachNhieuTap taoDuLieuGia({int chiSo = 0}) {
    SachNhieuTap ketQua = SachNhieuTap();
    ketQua.maSo = chiSo;
    ketQua.ten = "Nhieu tap 0$chiSo";
    return ketQua;
  }

}

/// Nhãn sách
class NhanSach extends DuLieuCoso {
  String? giaTri;
  int luonHien = -1;

  static NhanSach taoDuLieuGia({int chiSo = 0}) {
    NhanSach ketQua = NhanSach();
    ketQua.maSo = chiSo;
    ketQua.ten = "Nhan sach 0$chiSo";
    return ketQua;
  }
}

/// Vị trí lưu trữ sách
class ViTriSach extends DuLieuCoso {
  int thoiGian = -1;

  static ViTriSach taoDuLieuGia({int chiSo = 0}) {
    ViTriSach ketQua = ViTriSach();
    ketQua.maSo = chiSo;
    ketQua.ten = "Vi tri 0$chiSo";
    return ketQua;
  }
}

/// Đánh dấu (Bookmark)
class DanhDauSach {
  int maSo = -1;
  int maSach = -1;
  String noiDung = "";
  // ImgImage? image; TODO: later
}
