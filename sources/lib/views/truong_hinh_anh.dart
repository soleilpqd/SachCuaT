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
import 'package:image_picker/image_picker.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Thuộc tính trường hình ảnh
enum ThuocTinhTruongHinhAnh {
  /// Hình ảnh (XFile)
  hinhAnh;
}

/// Điều khiển trường hình ảnh và chụp ảnh
class DieuKhienTruongHinhAnh extends DieuKhienCoSo {

  /// CONSTRUCTOR
  DieuKhienTruongHinhAnh({Uri? hinhAnh, super.khaDung, super.laDieuKhienMoi}) : super(thuocTinhBanDau: {ThuocTinhTruongHinhAnh.hinhAnh.name: hinhAnh});

  @override
  List<String> dsThuocTinhGiaTri() => [ThuocTinhTruongHinhAnh.hinhAnh.name];

  @override
  List<String> dsThuocTinh() => ThuocTinhTruongHinhAnh.values.chuyenDoiSangDS(khac: super.dsThuocTinh());

  /// Hình ảnh
  Uri? get hinhAnh => this[ThuocTinhTruongHinhAnh.hinhAnh.name];
  /// Hình ảnh
  set hinhAnh(Uri? gt) => this[ThuocTinhTruongHinhAnh.hinhAnh.name] = gt;

}

/// Trường hình ảnh và chụp ảnh
/// - Nhấn 1 lần để chụp ảnh.
/// - Nhấn 2 lần để xoá ảnh.
class TruongHinhAnh extends GiaoDienCoSo<DieuKhienTruongHinhAnh> {

  /// Hàm xử lý khi không bật được camera (quyền, phần cứng...)
  final Function() khiKhongCoMayAnh;
  /// Bộ đệm văn bản hiển thị (dùng cho tiêu đề)
  final BoDemVbht? dem;

  /// CONSTRUCTOR
  const TruongHinhAnh({super.key, required DieuKhienTruongHinhAnh trinhDieuKhien, required this.khiKhongCoMayAnh, this.dem}) : super(dieuKhien: trinhDieuKhien);

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongHinhAnh();

}

class _TrangThaiTruongHinhAnh extends TrangThaiCoSo<TruongHinhAnh> {

  @override
  Widget build(BuildContext context) {
    final bool khaDung = widget.dieuKhien!.khaDung;
    List<Widget> children = [
      Container(
        color: widget.dieuKhien?.hinhAnh == null ? Colors.grey : Colors.white,
      ),
      widget.dieuKhien?.hinhAnh != null ?
        LinhTinh.taoWidgetAnh(widget.dieuKhien!.hinhAnh!) :
        Icon(
          Icons.camera_alt,
          size: 60,
          color: khaDung ? Colors.white : Colors.grey,
        )
    ];
    if (widget.dieuKhien?.hinhAnh == null && khaDung) {
      children.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [VbhtWidget(text: Vbht.tuKhoa(TK.hdsdAnh, dem: widget.dem), textAlign: TextAlign.right)],
        )
      );
    }
    return GestureDetector(
      onTap: khaDung ? _khiNhanChonAnh : null,
      onDoubleTap: khaDung ? _khiXoaAnh : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: children
        ),
      )
    );
  }

  /// Khi nhấn chọn ảnh (1 nhấn)
  void _khiNhanChonAnh() async {
    final ImagePicker picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(source: ImageSource.camera);
    } catch (error) {
      widget.khiKhongCoMayAnh();
    }
    if (file != null) {
      widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: file.path);
    }
  }

  /// Khi nhấn xoá ảnh (2 nhấn)
  void _khiXoaAnh() {
    widget.dieuKhien?.hinhAnh = null;
  }

}
