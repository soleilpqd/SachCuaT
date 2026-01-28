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
      /// Hàm xử lý khi nhấn nút (context của hộp thoại, thứ tự nút (từ 0), tiêu đề nút)
      Function(int, Vbht)? khiDong
    }
  ) {
    final DieuKhienManHinhThongBao hopThoaiTb = DieuKhienManHinhThongBao(
      noiDung: noiDung,
      nhanCacNut: nhanCacNut,
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

class DieuKhienManHinhThongBao extends DieuKhienManHinh {

  final Vbht noiDung;
  final List<Vbht> nhanCacNut;
  final void Function(int)? hanhDong;

  DieuKhienManHinhThongBao({required this.noiDung, required this.nhanCacNut, this.hanhDong}) {
    mauNenWidgetChua = Colors.black.withAlpha(128);
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

class _ManHinhThongBao extends StatelessWidget {

  final DieuKhienManHinhThongBao dieuKhienManHinh;
  final AnimationController? dkChuyenDong;

  const _ManHinhThongBao({required this.dieuKhienManHinh, required this.dkChuyenDong});

  @override
  Widget build(BuildContext context) {
    List<Widget> dsHienThi = [
      const SizedBox(height: 20),
      VbhtWidget(
        text: dieuKhienManHinh.noiDung,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge
      ),
      const SizedBox(height: 20),
    ];
    int stt = 0;
    for (final muc in dieuKhienManHinh.nhanCacNut) {
      dsHienThi.add(Container(color: Colors.grey.withAlpha(128), height: 1.0));
      int sttNut = stt;
      dsHienThi.add(NutBamTieuDe(
        onPressed: () => dieuKhienManHinh._khiNhanNut(sttNut),
        child: VbhtWidget(text: muc)
      ));
      stt += 1;
    }
    dsHienThi.add(const SizedBox(height: 10));
    final viewChinh = Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.withAlpha(128),
              width: 1.0
            ),
            boxShadow: [BoxShadow(
              color: Colors.black.withAlpha(64),
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
    mauNenWidgetChua = Colors.black.withAlpha(128);
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
        child: NutBamTieuDe(onPressed: dieuKhienManHinh.khiDong, child: Container(color: Colors.transparent))
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
