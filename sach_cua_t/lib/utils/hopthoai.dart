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
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:man_hinh_ung_dung/widget_luong_man_hinh_xep_lop.dart';
import 'package:man_hinh_ung_dung/xay_dung_widget_hoat_hinh.dart';
import 'package:sach_cua_t/main.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/nut_bam_tieu_de.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Hộp thoại thông báo
class HopThoai {

  /// Hiển thị hộp thoại thông báo với nhiều nút
  static void hienThiHopThoaiThongBao(
    {
      /// Nội dung
      required Vbht noiDung,
      /// Tiêu đề các nút
      required List<Vbht> nhanCacNut,
      /// Các nút cần chú ý
      List<int>? cacNutCanChuY,
      /// Hàm xử lý khi nhấn nút (context của hộp thoại, thứ tự nút (từ 0), tiêu đề nút)
      Function(int, Vbht)? khiDong
    }
  ) {
    final DieuKhienManHinhThongBao hopThoaiTb = DieuKhienManHinhThongBao(
      noiDung: noiDung,
      nhanCacNut: nhanCacNut,
      cacNutCanChuY: cacNutCanChuY,
      hanhDong: (stt) => khiDong?.call(stt, nhanCacNut[stt])
    );
    MainApp.luongMHGoc.themManHinh(manHinh: hopThoaiTb);
  }

  /// Hiển thị hộp thoại thông báo trượt lên từ đáy màn hình
  static DieuKhienManHinhTuDuoiDay hienThiHopThoaiTuDuoiDay(
    {
      /// Nội dung
      required Widget noiDung,
      /// Xử lý khi nhấn ra ngoài vùng nội dung (đóng lại)
      required void Function() khiDong,
      bool coHieuUng = true,
    }
  ) {
    final DieuKhienManHinhTuDuoiDay hopThoaiTb = DieuKhienManHinhTuDuoiDay(noiDung: noiDung, khiDong: khiDong);
    MainApp.luongMHGoc.themManHinh(manHinh: hopThoaiTb, thamSo: {WidgetLuongManHinhXepLop.kKeyThamSoChoPhepHoatHinh: coHieuUng});
    return hopThoaiTb;
  }

}

/// Hộp thoại thông báo
class DieuKhienManHinhThongBao extends DieuKhienManHinh {

  /// Nội dung thông báo
  final Vbht noiDung;
  /// Nhãn các nút
  final List<Vbht> nhanCacNut;
  /// Các nút cần chú ý (đỏ)
  final List<int>? cacNutCanChuY;
  /// Hành động khi nhấn vào nút có số thứ tự tương ứng
  final void Function(int)? hanhDong;

  DieuKhienManHinhThongBao({required this.noiDung, required this.nhanCacNut, this.cacNutCanChuY, this.hanhDong}) {
    mauNenWidgetChua = PhongCachGiaoDien().mauDoBong;
    thamSoDieuKhienWidgetLuong[WidgetLuongManHinhXepLop.kKeyThamSoLopTrong] = true;
    thamSoDieuKhienWidgetLuong[WidgetLuongManHinhXepLop.kKeyThamSoHoatHinh] = xayDungLopDoMo;
  }

  @override
  Widget xayDungGiaoDienNguoiDung(BuildContext context, Map<String, dynamic>? thamSo) {
    AnimationController? dkHoatHinh;
    final temp = thamSo?[WidgetLuongManHinhXepLop.kKeyDieuKhienHoatHoa];
    if (temp is AnimationController) {
      dkHoatHinh = temp;
    }
    return _ManHinhThongBao(dieuKhienManHinh: this, dkChuyenDong: dkHoatHinh);
  }

  void _khiNhanNut(int stt) {
    luongManHinh?.loaiManHinh(manHinh: this, khiHoanThanh: () {
      hanhDong?.call(stt);
    });
  }

}

/// Giao diện màn hình hộp thoại thông báo
class _ManHinhThongBao extends StatelessWidget {

  final DieuKhienManHinhThongBao dieuKhienManHinh;
  final AnimationController? dkChuyenDong;

  const _ManHinhThongBao({required this.dieuKhienManHinh, required this.dkChuyenDong});

  @override
  Widget build(BuildContext context) {
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    List<Widget> dsHienThi = [
      Padding(
        padding: EdgeInsetsGeometry.all(20),
        child:VbhtWidget(
          text: dieuKhienManHinh.noiDung,
          coChu: CoChu.binhThuong,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
        )
      ),
    ];
    bool nutDoc = dieuKhienManHinh.nhanCacNut.length > 2;
    List<Widget> dsCacNut = nutDoc ? dsHienThi : [];
    int stt = 0;
    for (final muc in dieuKhienManHinh.nhanCacNut) {
      if (nutDoc) {
        dsCacNut.add(Container(color: phongCach.mauVien, height: 1.0));
      } else {
        if (stt > 0) {
          dsCacNut.add(Container(color: phongCach.mauVien, width: 1.0, height: 20,));
        }
      }
      int sttNut = stt;
      bool canChuY = dieuKhienManHinh.cacNutCanChuY?.contains(sttNut) ?? false;
      dsCacNut.add(NutBamTieuDe(
        tieuDe: muc,
        khaDung: true,
        canChuY: canChuY,
        khiNhan: () => dieuKhienManHinh._khiNhanNut(sttNut)
      ));
      stt += 1;
    }
    if (!nutDoc) {
      dsHienThi.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: dsCacNut
      ));
    }
    dsHienThi.add(const SizedBox(height: 10));
    final viewChinh = Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: phongCach.mauNen,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: phongCach.mauVien,
              width: 1.0
            ),
            boxShadow: [BoxShadow(
              color: phongCach.mauDoBong,
              offset: const Offset(5, 5),
              blurRadius: 5.0,
              spreadRadius: 2.0
            )]
          ),
          clipBehavior: Clip.antiAlias,
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: dsHienThi)]
          ),
        ),
      )
    );
    if (dkChuyenDong != null) {
      return xayDungLopThuPhong(context, viewChinh, dkChuyenDong!);
    }
    return viewChinh;
  }

}

class DieuKhienManHinhTuDuoiDay extends DieuKhienManHinh {

  final Widget noiDung;
  final void Function() khiDong;

  DieuKhienManHinhTuDuoiDay({required this.noiDung, required this.khiDong}) {
    mauNenWidgetChua = PhongCachGiaoDien().mauDoBong;
    thamSoDieuKhienWidgetLuong[WidgetLuongManHinhXepLop.kKeyThamSoLopTrong] = true;
    thamSoDieuKhienWidgetLuong[WidgetLuongManHinhXepLop.kKeyThamSoHoatHinh] = xayDungLopDoMo;
  }

  @override
  Widget xayDungGiaoDienNguoiDung(BuildContext context, Map<String, dynamic>? thamSo) {
    AnimationController? dkHoatHinh;
    final temp = thamSo?[WidgetLuongManHinhXepLop.kKeyDieuKhienHoatHoa];
    if (temp is AnimationController) {
      dkHoatHinh = temp;
    }
    return _ManHinhTuDuoiDay(dieuKhienManHinh: this, dkChuyenDong: dkHoatHinh);
  }

}

class _ManHinhTuDuoiDay extends StatelessWidget {

  final DieuKhienManHinhTuDuoiDay dieuKhienManHinh;
  final AnimationController? dkChuyenDong;

  const _ManHinhTuDuoiDay({required this.dieuKhienManHinh, required this.dkChuyenDong});

  @override
  Widget build(BuildContext context) {
    final Widget viewChinh = Column(children: [
      Expanded(
        flex: 40,
        child: TextButton(
          style: const ButtonStyle(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            splashFactory: NoSplash.splashFactory
          ),
          onPressed: dieuKhienManHinh.khiDong,
          child: Container(color: Colors.transparent)
        )
      ),
      Expanded(
        flex: 60,
        child: dieuKhienManHinh.noiDung
      )
    ]);
    if (dkChuyenDong != null) {
      return xayDungLopTruotLen(context, viewChinh, dkChuyenDong!);
    }
    return viewChinh;
  }

}
