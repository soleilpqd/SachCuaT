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
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:man_hinh_ung_dung/luong_man_hinh.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_xep_lop.dart';
import 'package:man_hinh_ung_dung/xay_dung_widget_hoat_hinh.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';

/// Kiểu màn hình hướng dẫn
enum KieuHuongDan {
  /// Màn hình chính
  chinh,
  /// Thông tin chi tiết sách
  sach,
  /// Tìm kiếm
  timKiem,
  /// Web
  web,
  /// Màn hình giới thiệu chung
  gioiThieu
}

/// Điều khiển màn hình hướng dẫn
class DieuKhienManHinhHuongDan extends DieuKhienManHinh {

  final KieuHuongDan kieu;
  final BoDemVbht _demVbht = BoDemVbht();
  Uint8List? _pdfData;

  DieuKhienManHinhHuongDan({required this.kieu}) {
    thamSoDieuKhienWidgetLuong[WidgetLuongManHinhXepLop.kKeyThamSoHoatHinh] = xayDungLopDoMo;
    _napPdf();
  }

  void _napPdf() async {
    // TODO: đa ngôn ngữ
    final String fName = switch (kieu) {
      KieuHuongDan.chinh => "mo_dau",
      KieuHuongDan.sach => "sach",
      KieuHuongDan.timKiem => "tim_kiem",
      KieuHuongDan.web => "web",
      KieuHuongDan.gioiThieu => "gioi_thieu",
    };
    final String phanLoai = VanBanHienThi().phanLoai.first;
    final Uri uri = LinhTinh.taoDuongDan(phanLoai: PhanLoaiDuongDan.assets, duongDan: "assets/${fName}_$phanLoai.pdf");
    final data = await rootBundle.load(uri.path);
    _pdfData = data.buffer.asUint8List();
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  /// Khi nhấn Đóng
  void _khiNhanDong() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

   @override
  Widget xayDungGiaoDienNguoiDung(BuildContext context, Map<String, dynamic>? thamSo) {
    AnimationController? dkHoatHinh;
    final temp = thamSo?[WidgetLuongManHinhXepLop.kKeyDieuKhienHoatHoa];
    if (temp is AnimationController) {
      dkHoatHinh = temp;
    }
    return _ManHinhHuongDan(dkMh: this, dkChuyenDong: dkHoatHinh);
  }

}

class _ManHinhHuongDan extends StatelessWidget {

  final DieuKhienManHinhHuongDan dkMh;
  final AnimationController? dkChuyenDong;

  const _ManHinhHuongDan({required this.dkMh, this.dkChuyenDong});

  Vbht _tieuDe() => switch(dkMh.kieu) {
    KieuHuongDan.gioiThieu => Vbht.tuKhoa(TK.gioiThieu, dem: dkMh._demVbht),
    _ => Vbht.tuKhoa(TK.huongDan, dem: dkMh._demVbht)
  };

  @override
  Widget build(BuildContext context) {
    Widget viewChinh = ManHinhCoSo(
      tieuDe: _tieuDe(),
      nutTrai: NutBamBieuTuong(
        bieuTuong: Icons.close,
        thuocThanhDieuHuong: true,
        khiNhan: dkMh._khiNhanDong,
      ),
      noiDung: _NoiDungManHinhTroGiup(dieuKhienManHinh: dkMh)
    );
    if (dkChuyenDong != null) {
      return xayDungLopTruotLen(context, viewChinh, dkChuyenDong!);
    }
    return viewChinh;
  }

}

class _NoiDungManHinhTroGiup extends WidgetCuaDieuKhienManHinh<DieuKhienManHinhHuongDan> {

  _NoiDungManHinhTroGiup({required super.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiNoiDungTroGiup();

}

class _TrangThaiNoiDungTroGiup extends TrangThaiWidgetCuaDieuKhien<_NoiDungManHinhTroGiup> {

  @override
  void capNhatGiaoDienCuaManHinh({required DieuKhienManHinh dieuKhienManHinh, ThamSoDieuKhienWidgetManHinh? duLieuDinhKem}) {
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    if (widget.dieuKhienManHinh._pdfData != null) {
      return PDFView(
        pdfData: widget.dieuKhienManHinh._pdfData,
        autoSpacing: false,
        pageFling: false,
        pageSnap: false,
        backgroundColor: phongCach.mauNen,
      );
    }
    return Container(color: phongCach.mauNen);
  }

}
