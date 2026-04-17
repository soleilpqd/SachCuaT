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
import 'package:man_hinh_ung_dung/luong_man_hinh.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tim_kiem.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tro_giup.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/danh_sach_hien_thi.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Phân đoạn màn hình mở đầu
enum _PhanDoanManHinhMoDau {
  /// Đánh dấu
  danhDau,
  /// Gần đây
  ganDay,
  ///Giới thiệu
  gioiThieu;

  /// Khởi tạo từ giá trị thô [tho]
  static _PhanDoanManHinhMoDau? khoiTao(int tho) {
    return switch (tho) {
      0 => danhDau,
      1 => ganDay,
      2 => gioiThieu,
      _ => null,
    };
  }

  /// Tổng số
  static int tongSo() => values.length;
}

class DieuKhienManHinhMoDau extends DieuKhienManHinh {

  int _tongSoSach = 0;
  final BoDemVbht _boDemVbht = BoDemVbht();
  final ScrollController _dkCuon = ScrollController();
  String _phienBan = "";

  DieuKhienManHinhMoDau() {
    widgetCuaManHinh = _ManHinhMoDau(dieuKhienManHinh: this);
    HeThongMay.duyNhat.layThongTinPhienBan().then((giaTri) {
      _phienBan = giaTri ?? "";
      print("PHIEN BAN $_phienBan");
      trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
    });
  }

  @override
  void manHinhSeThanhManHinhChinhTrongLuong() {
    super.manHinhSeThanhManHinhChinhTrongLuong();
    CoSoDuLieu().demTongSoSach().then((value) {
      if (_tongSoSach != value) {
        _tongSoSach = value;
        trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
      }
    });
  }

  /// Khi nhấn nút Thêm sách
  void _khiNhanThemSach() {
    final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach();
    luongManHinh?.themManHinh(manHinh: mhSach);
  }

  DieuKhienManHinhTuDuoiDay? _dkHopThoaiChonSach;

  /// Khi nhấn nút Tìm kiếm
  void _khiNhanTimKiem() {
    final DieuKhienManHinhTimKiem mhTimKiem = DieuKhienManHinhTimKiem();
    luongManHinh?.themManHinh(manHinh: mhTimKiem);
    // HopThoai.hienThiHopThoaiThongBao(
    //   noiDung: Vbht.trucTiep("Thông báo dài loằng ngoằng. Xin chào. Tạm biệt!"),
    //   nhanCacNut: [Vbht.tuKhoa(TK.dong), Vbht.tuKhoa(TK.luu)],
    //   khiDong: (stt, nhan) => print("STT: $stt; Nhan: ${nhan.vanBan}")
    // );
    // _dkHopThoaiChonSach = HopThoai.hienThiHopThoaiTuDuoiDay(
    //   noiDung: Container(
    //     color: Colors.red,
    //     child: Center(child: TextButton(onPressed: _dongHopThoaiChonSach, child: const Text("CLOSE"))),
    //   ),
    //   khiDong: _dongHopThoaiChonSach
    // );
  }

  void _khiNhanQuet() {

  }

    void _dongHopThoaiChonSach() {
    if (_dkHopThoaiChonSach != null) {
      _dkHopThoaiChonSach!.luongManHinh?.loaiManHinh(manHinh: _dkHopThoaiChonSach!);
      _dkHopThoaiChonSach = null;
    }
  }

}

class _ManHinhMoDau extends WidgetCuaDieuKhienManHinh<DieuKhienManHinhMoDau> {

  const _ManHinhMoDau({required super.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhMoDau();

}

class _TrangThaiManHinhMoDau extends TrangThaiWidgetCuaDieuKhien<_ManHinhMoDau> with ListViewTheoPhanDoan {

  @override
  void capNhatGiaoDienCuaManHinh({required DieuKhienManHinh dieuKhienManHinh, ThamSoDieuKhienWidgetManHinh? duLieuDinhKem}) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DieuKhienManHinhMoDau dkMh = widget.dieuKhienManHinh;
    List<Widget> nutPhai = [];
    if (dkMh._tongSoSach > 0) {
      nutPhai.add(NutBamBieuTuong(
        bieuTuong: Icons.camera_alt_outlined,
        thuocThanhDieuHuong: true,
        khiNhan: dkMh._khiNhanQuet
      ));
      nutPhai.add(NutBamBieuTuong(
        bieuTuong: Icons.search,
        thuocThanhDieuHuong: true,
        khiNhan: dkMh._khiNhanTimKiem
      ));
    }
    nutPhai.add(ManHinhCoSo.taoNutHuongDan(KieuHuongDan.chinh));
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(TK.sachCuaT),
      nutTrai: dkMh._tongSoSach > 0 ? NutBamBieuTuong(
        bieuTuong: Icons.add,
        thuocThanhDieuHuong: true,
        khiNhan: dkMh._khiNhanThemSach
      ) : null,
      nutPhai: nutPhai,
      noiDung: dkMh._tongSoSach > 0 ?
        // xayDungListView(context, scrollCtrl: widget.dieuKhienManHinh._dkCuon) :
        const Center(child: Text("HELLO!")) :
        _xayDungManHinhLanDau(context)
    );
  }

  /// Xây dựng màn hình lần đầu
  Widget _xayDungManHinhLanDau(BuildContext context) {
    final DieuKhienManHinhMoDau dkMh = widget.dieuKhienManHinh;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VbhtWidget(
          text: Vbht.tuKhoa(TK.chuaCoSach, dem: dkMh._boDemVbht),
          coChu: CoChu.binhThuong,
          textAlign: TextAlign.center
        ),
        NutBamBieuTuong(
          bieuTuong: Icons.add,
          khiNhan: dkMh._khiNhanThemSach,
          thuocThanhDieuHuong: false
        )
      ],
    );
  }

  @override
  double? khoangCachPhiaDuoi(int doan, int dong) {
    return switch (_PhanDoanManHinhMoDau.khoiTao(doan)) {
      _PhanDoanManHinhMoDau.gioiThieu => 50.0,
      _ => null
    };
  }

  @override
  double? khoangCachPhiaTren(int doan, int dong) {
    return null;
  }

  @override
  int soLuongPhanDoan() {
    // TODO: implement soLuongPhanDoan
    throw UnimplementedError();
  }

  @override
  int soMucCuaPhanDoan(int doan) {
    // TODO: implement soMucCuaPhanDoan
    throw UnimplementedError();
  }

  @override
  TruongTieuDe? tieuDeChoDoan(int doan) {
    // TODO: implement tieuDeChoDoan
    throw UnimplementedError();
  }

  @override
  Widget? widgetCuaMuc(int doan, int dong) {
    // TODO: implement widgetCuaMuc
    throw UnimplementedError();
  }

  @override
  List<Widget>? widgetsCuaCaDoan(int doan) {
    // TODO: implement widgetsCuaCaDoan
    throw UnimplementedError();
  }

}
