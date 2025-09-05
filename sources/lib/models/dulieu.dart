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
import 'package:image_picker/image_picker.dart';

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
  XFile? hinhAnh;
  XFile? hinhThuNho;

  List<String> nhaXuatBan = [];
  List<String> tacGia = [];
  List<String> dichGia = [];
  List<String> viTri = [];
  Map<String, String> nhan = {};
  List<String> danhDau = [];

}

abstract class DuLieuCoso {
  int maSo = -1;
  String ten = "";
}

/// Nhà xuất bản, đơn vị phát hành
class NhaXuatBan extends DuLieuCoso {
  String? maLuuChieu;
}

/// Tác giả
class TacGia extends DuLieuCoso {
}

/// Dịch giả
class DichGia extends DuLieuCoso {
}

/// Chuỗi sách nhiều tập
class SachNhieuTap extends DuLieuCoso {
}

/// Nhãn sách
class NhanSach extends DuLieuCoso {
  int kieu = -1;
}

/// Vị trí lưu trữ sách
class ViTriSach extends DuLieuCoso {
  int thoiGian = -1;
}

/// Đánh dấu (Bookmark)
class DanhDauSach {
  int maSo = -1;
  int maSach = -1;
  String trang = "";
  ImgImage? image;
}
