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

typedef UiImage = Ui.Image;
typedef ImgImage = Img.Image;

/// Sách
class Sach {
  int maSo = -1;
  String ten = "";
  bool daHoanThanh = false;
  String isbn = "";
  int maNhieuTap = -1;
  int tap = -1;
  ImgImage? image;

  List<int> nhaXuatBan = [];
  List<int> tacGia = [];
  List<int> dichGia = [];
  List<int> viTri = [];
  Map<int, String> nhan = {};
}

/// Nhà xuất bản, đơn vị phát hành
class NhaXuatBan {
  int maSo = -1;
  String ten = "";
  int? maLuuChieu;
}

/// Tác giả
class TacGia {
  int maSo = -1;
  String ten = "";
}

/// Dịch giả
class DichGia {
  int maSo = -1;
  String ten = "";
}

/// Chuỗi sách nhiều tập
class SachNhieuTap {
  int maSo = -1;
  String ten = "";
}

/// Nhãn sách
class NhanSach {
  int maSo = -1;
  int kieu = -1;
  String ten = "";
}

/// Vị trí lưu trữ sách
class ViTriSach {
  int maSo = -1;
  String ten = "";
}

/// Đánh dấu (Bookmark)
class DanhDauSach {
  int maSo = -1;
  int maSach = -1;
  String trang = "";
  ImgImage? image;
}
