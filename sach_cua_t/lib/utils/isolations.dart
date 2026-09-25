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

// import 'package:flutter/foundation.dart';
// import 'package:image/image.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sach_cua_t/models/dulieu.dart';

// /// Xử lý bất đồng bộ
// class Isolations {

//   /// Khởi tạo view hiển thị ảnh
//   // static Future<UiImage> napKhungAnh(ImgImage image) => compute((argImg) => UiImage.memory(encodePng(argImg)), image);

//   /// Nạp ảnh từ XFile (lib image_picker)
//   static Future<ImgImage?> napAnhTuXFile(XFile file) => compute((argFile) async {
//     Uint8List data = await argFile.readAsBytes();
//     return decodeImage(data);
//   }, file);

//   /// Tạo ảnh thu nhỏ
//   static Future<ImgImage?> taoAnhThuNho(ImgImage image) => compute((args) async {
//     return copyResize(args, height: 50);
//   }, image);

// }
