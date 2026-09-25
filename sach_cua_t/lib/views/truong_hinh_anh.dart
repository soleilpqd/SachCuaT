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
import 'package:sach_cua_t/main.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_xem_anh.dart';
import 'package:sach_cua_t/models/du_lieu_tam.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_tieu_de.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';

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
  set hinhAnh(Uri? gt) {
    _thongTinAnh = null;
    this[ThuocTinhTruongHinhAnh.hinhAnh.name] = gt;
  }

  _ThongTinAnh? _thongTinAnh = null;

}

/// Trường hình ảnh và chụp ảnh
/// - Nhấn 1 lần để chụp ảnh.
/// - Nhấn 2 lần để xoá ảnh.
class TruongHinhAnh extends GiaoDienCoSo<DieuKhienTruongHinhAnh> {

  /// Hiển thị thông tin hình ảnh
  final bool hienThiThongTinAnh;
  /// Hàm xử lý khi không bật được camera (quyền, phần cứng...)
  final Function() khiKhongCoMayAnh;
  /// Bộ đệm văn bản hiển thị (dùng cho tiêu đề)
  final BoDemVbht? dem;

  /// CONSTRUCTOR
  const TruongHinhAnh({
    super.key,
    required DieuKhienTruongHinhAnh trinhDieuKhien,
    required this.khiKhongCoMayAnh,
    this.dem,
    this.hienThiThongTinAnh = true
  }) : super(dieuKhien: trinhDieuKhien);

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongHinhAnh();

}

class _ThongTinAnh {
  final int ngang;
  final int doc;
  final int kichThuocOCung;

  _ThongTinAnh({required this.ngang, required this.doc, required this.kichThuocOCung});
}

class _TrangThaiTruongHinhAnh extends TrangThaiCoSo<TruongHinhAnh> {

  Widget _xayDungKhungAnh(Color mauNen) {
    final bool khaDung = widget.dieuKhien!.khaDung;
    if (widget.dieuKhien?.hinhAnh != null) {
      final Uri duongDanAnh = widget.dieuKhien!.hinhAnh!;
      final UiImage viewAnh = LinhTinh.taoWidgetAnh(widget.dieuKhien!.hinhAnh!);
      if (widget.hienThiThongTinAnh && duongDanAnh.scheme == PhanLoaiDuongDan.file.name) {
        if (widget.dieuKhien?._thongTinAnh == null) {
          viewAnh.image.evict();
          viewAnh.image.resolve(ImageConfiguration.empty).addListener(ImageStreamListener((thongTin, _) {
            final File tepAnh = File(duongDanAnh.path);
            final int ktTep = tepAnh.lengthSync();
            final _ThongTinAnh ttAnh = _ThongTinAnh(ngang: thongTin.image.width, doc: thongTin.image.height, kichThuocOCung: ktTep);
            setState(() {
              widget.dieuKhien?._thongTinAnh = ttAnh;
            });
          }));
        }
      }
      return viewAnh;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NutBamBieuTuongTieuDe(
          khaDung: khaDung,
          bieuTuong: Icons.paste,
          kichThuocBieuTuong: 60,
          thuocThanhDieuHuong: true,
          khiNhan: _khiNhanDan,
        ),
        NutBamBieuTuongTieuDe(
          khaDung: khaDung,
          bieuTuong: Icons.camera_alt,
          kichThuocBieuTuong: 60,
          thuocThanhDieuHuong: true,
          khiNhan: _khiNhanChonAnh,
        ),
        NutBamBieuTuongTieuDe(
          khaDung: khaDung,
          bieuTuong: Icons.photo_library,
          kichThuocBieuTuong: 60,
          thuocThanhDieuHuong: true,
          khiNhan: _khiNhanKhoAnh,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool khaDung = widget.dieuKhien!.khaDung;
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    final List<Widget> children = [
      Container(
        color: widget.dieuKhien?.hinhAnh == null ? phongCach.mauVien : phongCach.mauNen,
      ),
      _xayDungKhungAnh(khaDung ? phongCach.mauNoiDungChinh : phongCach.mauNoiDungKhoaChinh)
    ];

    final AspectRatio khungVuong = AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: children
      )
    );
    if (widget.dieuKhien?.hinhAnh != null) {
      final duongDanAnh = widget.dieuKhien!.hinhAnh!;
      _ThongTinAnh? thongTinAnh = widget.dieuKhien?._thongTinAnh;
      List<Widget> dsViewConChinh = [khungVuong];
      if (thongTinAnh != null) {
        dsViewConChinh.add(Text(
          """
${duongDanAnh.pathSegments[duongDanAnh.pathSegments.length - 2]}/${duongDanAnh.pathSegments.last}
${thongTinAnh.ngang}x${thongTinAnh.doc}:${LinhTinh.dinhDangKichThuocTep(thongTinAnh.kichThuocOCung)}
""", textAlign: TextAlign.center,
        ));
      }
      dsViewConChinh.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          NutBamBieuTuongTieuDe(
            khaDung: khaDung,
            bieuTuong: Icons.paste_outlined,
            thuocThanhDieuHuong: false,
            khiNhan: _khiNhanDan,
          ),
          NutBamBieuTuongTieuDe(
            khaDung: khaDung,
            bieuTuong: Icons.camera_alt_outlined,
            thuocThanhDieuHuong: false,
            khiNhan: _khiNhanChonAnh,
          ),
          NutBamBieuTuongTieuDe(
            khaDung: khaDung,
            bieuTuong: Icons.photo_library_outlined,
            thuocThanhDieuHuong: false,
            khiNhan: _khiNhanKhoAnh,
          ),
          NutBamBieuTuongTieuDe(
            khaDung: khaDung,
            bieuTuong: Icons.fullscreen,
            thuocThanhDieuHuong: false,
            khiNhan: _khiXemAnhToanManHinh,
          ),
          NutBamBieuTuongTieuDe(
            khaDung: khaDung,
            bieuTuong: Icons.delete_outline,
            thuocThanhDieuHuong: false,
            khiNhan: _khiXoaAnh,
          )
        ],
      ));
      Widget khungChinh = Column(
        children: dsViewConChinh,
      );
      return GestureDetector(
        onTap: khaDung ? _khiXemAnhToanManHinh : null,
        onDoubleTap: khaDung ? _khiXoaAnh : null,
        child: khungChinh
      );
    }
    return khungVuong;
  }

  // Future<void> _chonAnh1(ImageSource nguon) async {
  //   final ImagePicker picker = ImagePicker();
  //   XFile? file;
  //   try {
  //     file = await picker.pickImage(source: nguon);
  //   } catch (error) {
  //     widget.khiKhongCoMayAnh();
  //   }
  //   if (file != null) {
  //     widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: file.path);
  //   }
  // }

  Future<void> _chonAnh(KieuMedia kieu) async {
    try {
      String? duongDan = await HeThongMay.duyNhat.chonAnh(kieu);
      if (duongDan != null) {
        widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: duongDan);
      }
    } catch (error) {
      widget.khiKhongCoMayAnh();
    }
  }

  /// Khi nhấn chọn ảnh (1 nhấn)
  void _khiNhanChonAnh() {
    _chonAnh(KieuMedia.camera);
  }

  /// Khi nhấn xoá ảnh (2 nhấn)
  void _khiXoaAnh() {
    widget.dieuKhien?.hinhAnh = null;
    final DuLieuTam boDem = DuLieuTam();
    boDem.xoaCacTepDan();
    boDem.xoaTepDuocChiaSe();
  }

  void _khiXemAnhToanManHinh() {
    final DieuKhienManHinhXemAnh mhAnh = DieuKhienManHinhXemAnh(duongDanAnh: widget.dieuKhien!.hinhAnh!);
    MainApp.luongMHGoc.themManHinh(manHinh: mhAnh);
  }

  Future<bool> _xuLyTepDaChon(List<String> dsTep) async {
    if (dsTep.isEmpty) { return false; }
    String? duongDanHienTai = widget.dieuKhien?.hinhAnh?.path;
    if (duongDanHienTai != null && dsTep.contains(duongDanHienTai)) {
      final int sttHienTai = dsTep.indexOf(duongDanHienTai);
      for (int stt = sttHienTai + 1; stt < dsTep.length; stt += 1) {
        final String muc = dsTep[stt];
        if (await LinhTinh.kiemTraCoPhaiAnh(muc)) {
          widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: muc);
          return true;
        }
      }
    } else {
      for (final String muc in dsTep) {
        if (await LinhTinh.kiemTraCoPhaiAnh(muc)) {
          widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: muc);
          return true;
        }
      }
    }
    return false;
  }

  void _khiNhanDan() async {
    final List<String>? kqDan = await HeThongMay.duyNhat.dan([.anh]);
    if (kqDan != null && kqDan.isNotEmpty) {
      widget.dieuKhien?.hinhAnh = null;
    }
    final Iterable<String> dsTepDan = await DuLieuTam().layDsCacTepDuocDan();
    final Iterable<String> dsTepChiaSe = await DuLieuTam().layDsCacTepDuocChiaSe();
    final List<String> dsTep = [];
    dsTep.addAll(dsTepDan);
    dsTep.addAll(dsTepChiaSe);
    if (await _xuLyTepDaChon(dsTep)) {
      return;
    }
    final List<String>? kqChonTep = await HeThongMay.duyNhat.chonTep([.anh]);
    if (kqChonTep != null && kqChonTep.isNotEmpty) {
      widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: kqChonTep.first);
    } else if (dsTep.isNotEmpty) {
      widget.dieuKhien?.hinhAnh = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.file, duongDan: dsTep.first);
    }
  }

  void _khiNhanKhoAnh() {
    _chonAnh(KieuMedia.khoAnh);
  }

}
