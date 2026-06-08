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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:man_hinh_ung_dung/luong_man_hinh.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_thong_ke.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tro_giup.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/operations/thao_tac_tim_kiem.dart';
import 'package:sach_cua_t/models/vanbannoibat.dart';
import 'package:sach_cua_t/models/xu_ly_nut_lui_android.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/danh_sach_hien_thi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_tieu_de.dart';
import 'package:sach_cua_t/views/truong_nut_bam.dart';
import 'package:sach_cua_t/views/truong_sach.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_noi_bat.dart';

/// Các phân đoạn kết quả tìm kiếm
enum _PhanDoanManHinhTimKiem {
  /// Ô nhập từ khoá
  tuKhoa,
  /// Bộ lọc
  boLoc,
  /// Tên sách
  tenSach,
  /// ISBN
  isbn,
  /// Đánh dấu
  danhDau,
  /// Tác giả
  tacGia,
  /// Dịch giả
  dichGia,
  /// Nhà xuất bản (Đơn vị phát hành)
  nxb,
  /// Vị trí
  viTri,
  /// Tên nhãn
  tenNhan,
  /// Giá trị của nhãn
  giaTriNhan,
  /// Nhiều tập
  nhieuTap,
  /// Đáy, chân trang
  chanTrang;

  /// Khởi tạo từ giá trị thô [tho]
  static _PhanDoanManHinhTimKiem? khoiTao(int tho) {
    return switch (tho) {
      0 => tuKhoa,
      1 => boLoc,
      2 => tenSach,
      3 => isbn,
      4 => danhDau,
      5 => tacGia,
      6 => dichGia,
      7 => nxb,
      8 => viTri,
      9 => tenNhan,
      10 => giaTriNhan,
      11 => nhieuTap,
      12 => chanTrang,
      _ => null,
    };
  }

  /// Tổng số
  static int tongSo() => values.length;

}

/// Bộ lọc tìm kiếm
class _LocTimKiem {

  /// Kiểu lọc
  final _PhanDoanManHinhTimKiem kieuLoc;
  /// Giá trị lọc (văn bản để hiển thị)
  final String giaTriLoc;
  /// Dữ liệu (object dữ liệu)
  final dynamic duLieu;

  _LocTimKiem({required this.kieuLoc, required this.giaTriLoc, required this.duLieu});

}

/// Điều khiển màn hình tìm kiếm
class DieuKhienManHinhTimKiem extends DieuKhienManHinh with TheoDoiDieuKhienCoSo, XuLyNutLuiAndroid {

  /// Bộ đệm Văn bản hiển thị
  final BoDemVbht demVbht = BoDemVbht();
  /// Bộ lọc
  final List<_LocTimKiem> _locTimKiem = [];
  /// Callback với chế độ `chonSachLapChuoi`
  final void Function(Sach)? khiChonSach;
  /// Điều khiển ô nhập từ khoá
  final DieuKhienTruongVanBan dkTuKhoa = DieuKhienTruongVanBan();

  final ThaoTacTimKiem _congCuTimKiem = ThaoTacTimKiem();
  final ScrollController _dkCuon = ScrollController();
  // Kết quả tìm kiếm
  List<Sach> _kqTenSach = [];
  List<Sach> _kqISBN = [];
  List<Sach> _kqDanhDau = [];
  List<TacGia> _kqTacGia = [];
  List<DichGia> _kqDichGia = [];
  List<NhaXuatBan> _kqNxb = [];
  List<ViTriSach> _kqViTri = [];
  List<NhanSach> _kqTenNhan = [];
  List<String> _kqGiaTriNhan = [];
  List<SachNhieuTap> _kqSachNhieuTap = [];
  bool _canTimLai = false;

  DieuKhienManHinhTimKiem({this.khiChonSach, List<int>? sachLoaiTru}) {
    widgetCuaManHinh = _ManHinhTimKiem(dkMh: this);
    _congCuTimKiem.dsLoaiTru = sachLoaiTru;
  }

  // -- Delegate

  @override
  void manHinhDuocThemVaoLuong() {
    super.manHinhDuocThemVaoLuong();
    dkTuKhoa.themTheoDoi(this);
    Future.delayed(const Duration(milliseconds: 500)).then((_) => dkTuKhoa.trangThaiNhap = TrangThaiNhapVanBan.noiDung);
  }

  @override
  void manHinhBiLoaiBoKhoiLuong() {
    super.manHinhBiLoaiBoKhoiLuong();
    dkTuKhoa.boTheoDoi(this);
  }

  @override
  void manHinhDaThanhManHinhChinhTrongLuong() {
    super.manHinhDaThanhManHinhChinhTrongLuong();
    if (_canTimLai) {
      _canTimLai = false;
      _batDauTim();
    }
  }

  @override
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {
    super.dieuKhienCoSoThayDoiThuocTinh(nguon, cacGiaTri);
    if (nguon == dkTuKhoa && cacGiaTri.keys.contains(ThuocTinhTruongVanBan.vanBan.name)) {
      _khiTuKhoaThayDoi();
    }
  }

  /// Khi `Từ khoá` thay đổi
  void _khiTuKhoaThayDoi() {

  }

  /// Xoá toàn bộ kết quả tìm kiếm
  void _xoaKetQua() {
    _kqTenSach.clear();
    _kqISBN.clear();
    _kqDanhDau.clear();
    _kqTacGia.clear();
    _kqDichGia.clear();
    _kqNxb.clear();
    _kqViTri.clear();
    _kqTenNhan.clear();
    _kqGiaTriNhan.clear();
    _kqSachNhieuTap.clear();
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  /// Bắt đầu tìm
  void _batDauTim() async {
    dkTuKhoa.trangThaiNhap = TrangThaiNhapVanBan.khong;
    _xoaKetQua();
    final String tuKhoa = dkTuKhoa.vanBan.trim();
    dkTuKhoa.khaDung = false;
    _congCuTimKiem.batDauTimKiem(
      khiXong1Viec: () => trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this),
      khiXongTatCa: () {
        dkTuKhoa.khaDung = true;
        _dkCuon.cuonLenDau();
      }
    );
    List<TacGia> locTacGia = [];
    List<DichGia> locDichGia = [];
    List<NhaXuatBan> locNXB = [];
    List<ViTriSach> locViTri = [];
    List<NhanSach> locNhan = [];
    _LocTimKiem? locNhanCanTimGiaTri;
    SachNhieuTap? locNhieuTap;
    for (final _LocTimKiem loc in _locTimKiem) {
      switch (loc.kieuLoc) {
      case _PhanDoanManHinhTimKiem.tacGia:
        locTacGia.add(loc.duLieu);
        break;
      case _PhanDoanManHinhTimKiem.dichGia:
        locDichGia.add(loc.duLieu);
        break;
      case _PhanDoanManHinhTimKiem.nxb:
        locNXB.add(loc.duLieu);
        break;
      case _PhanDoanManHinhTimKiem.viTri:
        locViTri.add(loc.duLieu);
        break;
      case _PhanDoanManHinhTimKiem.tenNhan:
        locNhan.add(loc.duLieu);
        if ((loc.duLieu as NhanSach).giaTri == null) {
          locNhanCanTimGiaTri = loc;
        }
        break;
      case _PhanDoanManHinhTimKiem.nhieuTap:
        locNhieuTap = loc.duLieu;
        break;
      default:
        break;
      }
    }
    final List<List<Sach>> kqTongHopSach = await _congCuTimKiem.timKiemSach(
      tuKhoa: tuKhoa,
      tacGia: locTacGia,
      dichGia: locDichGia,
      nxb: locNXB,
      viTri: locViTri,
      nhan: locNhan,
      nhieuTap: locNhieuTap
    );
    _kqTenSach = kqTongHopSach[0];
    _kqISBN = kqTongHopSach[1];
    _kqDanhDau = kqTongHopSach[2];
    if (locNhanCanTimGiaTri != null) {
      _kqGiaTriNhan = await _congCuTimKiem.timKiemGtNhan(tuKhoa: tuKhoa, tenNhan: locNhanCanTimGiaTri.duLieu);
    }
    if (tuKhoa.isEmpty) {
      return;
    }
    _kqTacGia = await _congCuTimKiem.timKiemTacGia(tuKhoa: tuKhoa, daCo: locTacGia);
    _kqDichGia = await _congCuTimKiem.timKiemDichGia(tuKhoa: tuKhoa, daCo: locDichGia);
    _kqNxb = await _congCuTimKiem.timKiemNXB(tuKhoa: tuKhoa, daCo: locNXB);
    _kqViTri = await _congCuTimKiem.timKiemViTri(tuKhoa: tuKhoa, daCo: locViTri);
    if (locNhanCanTimGiaTri == null) {
      _kqTenNhan = await _congCuTimKiem.timKiemTenNhan(tuKhoa: tuKhoa, daCo: locNhan);
    }
    if (locNhieuTap == null) {
      _kqSachNhieuTap = await _congCuTimKiem.timKiemNhieuTap(tuKhoa: tuKhoa);
    }
  }

  // --- Xử lý hành động người dùng

  @override
  bool khiNhanNutLuiAndroid() {
    _khiNhanQuayLai();
    return false;
  }

  /// Khi nhấn Tiêu đề của màn hình
  void _khiNhanTieuDeMh() {
    _dkCuon.cuonLenDau();
  }

  /// Khi nhấn Nút quay lại (<)
  void _khiNhanQuayLai() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  /// Khi nhấn nút Tìm kiếm
  void _khiNhanTimKiem() {
    _batDauTim();
  }

  /// Khi nhấn 1 dòng Bộ lọc trên danh sách kết quả tìm kiếm
  void _khiNhanBoLoc(_LocTimKiem loc) {
    _locTimKiem.remove(loc);
    _batDauTim();
  }

  /// Khi nhấn dòng Thống kê trên danh sách kết quả tìm kiếm Tên sách
  void _khiNhanThongKe() {
    final DieuKhienManHinhThongKe mhThongKe = DieuKhienManHinhThongKe(dsSach: _kqTenSach);
    luongManHinh?.themManHinh(manHinh: mhThongKe);
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Tên sách
  void _khiNhanKqTenSach(int stt) {
    final Sach sach = _kqTenSach[stt];
    _khiNhanSach(sach);
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm ISBN
  void _khiNhanKqISBN(int stt) {
    final Sach sach = _kqISBN[stt];
    _khiNhanSach(sach);
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm ISBN
  void _khiNhanKqDanhDau(int stt) {
    final Sach sach = _kqDanhDau[stt];
    _khiNhanSach(sach);
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Tác giả
  void _khiNhanKqTacGia(int stt) {
    TacGia tacGia = _kqTacGia.removeAt(stt);
    _LocTimKiem loc = _LocTimKiem(kieuLoc: _PhanDoanManHinhTimKiem.tacGia, giaTriLoc: tacGia.ten, duLieu: tacGia);
    _locTimKiem.add(loc);
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Dịch giả
  void _khiNhanKqDichGia(int stt) {
    DichGia dichGia = _kqDichGia.removeAt(stt);
    _LocTimKiem loc = _LocTimKiem(kieuLoc: _PhanDoanManHinhTimKiem.dichGia, giaTriLoc: dichGia.ten, duLieu: dichGia);
    _locTimKiem.add(loc);
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Dịch giả
  void _khiNhanKqNXB(int stt) {
    NhaXuatBan nxb = _kqNxb.removeAt(stt);
    _LocTimKiem loc = _LocTimKiem(kieuLoc: _PhanDoanManHinhTimKiem.nxb, giaTriLoc: nxb.ten, duLieu: nxb);
    _locTimKiem.add(loc);
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Vị trí sách
  void _khiNhanKqViTri(int stt) {
    ViTriSach viTri = _kqViTri.removeAt(stt);
    _LocTimKiem loc = _LocTimKiem(kieuLoc: _PhanDoanManHinhTimKiem.viTri, giaTriLoc: viTri.ten, duLieu: viTri);
    _locTimKiem.add(loc);
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Tên nhãn
  void _khiNhanKqTenNhan(int stt) {
    NhanSach nhan = _kqTenNhan.removeAt(stt);
    _LocTimKiem loc = _LocTimKiem(kieuLoc: _PhanDoanManHinhTimKiem.tenNhan, giaTriLoc: nhan.ten, duLieu: nhan);
    _locTimKiem.add(loc);
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Giá trị nhãn
  void _khiNhanKqGiaTriNhan(int stt) {
    String gtNhan = _kqGiaTriNhan.removeAt(stt);
    for (final _LocTimKiem loc in _locTimKiem) {
      if (loc.kieuLoc == _PhanDoanManHinhTimKiem.tenNhan) {
        final NhanSach nhan = loc.duLieu;
        if (nhan.giaTri == null) {
          nhan.giaTri = gtNhan;
          break;
        }
      }
    }
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  /// Khi nhấn 1 dòng kết quả tìm kiếm Sách nhiều tập
  void _khiNhanKqSachNhieuTap(int stt) {
    SachNhieuTap nhieuTap = _kqSachNhieuTap.removeAt(stt);
    _LocTimKiem loc = _LocTimKiem(kieuLoc: _PhanDoanManHinhTimKiem.nhieuTap, giaTriLoc: nhieuTap.ten, duLieu: nhieuTap);
    _locTimKiem.add(loc);
    dkTuKhoa.vanBan = "";
    _batDauTim();
  }

  void _khiNhanSach(Sach sach) {
    if (khiChonSach != null) {
      luongManHinh?.loaiManHinh(manHinh: this, khiHoanThanh: () => khiChonSach!.call(sach));
    } else {
      _canTimLai = false;
      final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach(maSach: sach.maSo, khiLuuSach: () => _canTimLai = true);
      luongManHinh?.themManHinh(manHinh: mhSach);
    }
  }

}

class _ManHinhTimKiem extends StatelessWidget {

  final DieuKhienManHinhTimKiem dkMh;

  const _ManHinhTimKiem({required this.dkMh});

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(TK.timKiem, dem: dkMh.demVbht),
      nutPhai: [ManHinhCoSo.taoNutHuongDan(KieuHuongDan.timKiem)],
      khiNhanQuayLai: dkMh._khiNhanQuayLai,
      khiNhanTieuDe: dkMh._khiNhanTieuDeMh,
      noiDung: _NoiDungManHinhTimKiem(dieuKhienManHinh: dkMh)
    );
  }

}

class _NoiDungManHinhTimKiem extends WidgetCuaDieuKhienManHinh<DieuKhienManHinhTimKiem> {

  _NoiDungManHinhTimKiem({required super.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiNoiDungMhTimKiem();

}

class _TrangThaiNoiDungMhTimKiem extends TrangThaiWidgetCuaDieuKhien<_NoiDungManHinhTimKiem> with ListViewTheoPhanDoan {

  String get tuKhoa => widget.dieuKhienManHinh.dkTuKhoa.vanBan.trim();

  _TrangThaiNoiDungMhTimKiem();

  @override
  Widget build(BuildContext context) => xayDungListView(context, scrollCtrl: widget.dieuKhienManHinh._dkCuon);

  @override
  void capNhatGiaoDienCuaManHinh({required DieuKhienManHinh dieuKhienManHinh, ThamSoDieuKhienWidgetManHinh? duLieuDinhKem}) {
    setState(() {});
  }

  @override
  int soLuongPhanDoan() => _PhanDoanManHinhTimKiem.tongSo();

  @override
  int soMucCuaPhanDoan(int doan) {
    return switch (_PhanDoanManHinhTimKiem.khoiTao(doan)) {
      _PhanDoanManHinhTimKiem.tuKhoa => 1,
      _PhanDoanManHinhTimKiem.boLoc => widget.dieuKhienManHinh._locTimKiem.length,
      _PhanDoanManHinhTimKiem.tenSach => widget.dieuKhienManHinh._kqTenSach.isNotEmpty ? widget.dieuKhienManHinh._kqTenSach.length + 1 : 0,
      _PhanDoanManHinhTimKiem.isbn => widget.dieuKhienManHinh._kqISBN.length,
      _PhanDoanManHinhTimKiem.danhDau => widget.dieuKhienManHinh._kqDanhDau.length,
      _PhanDoanManHinhTimKiem.tacGia => widget.dieuKhienManHinh._kqTacGia.length,
      _PhanDoanManHinhTimKiem.dichGia => widget.dieuKhienManHinh._kqDichGia.length,
      _PhanDoanManHinhTimKiem.nxb => widget.dieuKhienManHinh._kqNxb.length,
      _PhanDoanManHinhTimKiem.viTri => widget.dieuKhienManHinh._kqViTri.length,
      _PhanDoanManHinhTimKiem.tenNhan => widget.dieuKhienManHinh._kqTenNhan.length,
      _PhanDoanManHinhTimKiem.giaTriNhan => widget.dieuKhienManHinh._kqGiaTriNhan.length,
      _PhanDoanManHinhTimKiem.nhieuTap => widget.dieuKhienManHinh._kqSachNhieuTap.length,
      _PhanDoanManHinhTimKiem.chanTrang => 1,
      _ => 0
    };
  }

  TruongTieuDe _xayDungTruongTieuDe({required TK chinh, required TK phu, required String thamSo}) => TruongTieuDe(
    tieuDeChinh: Vbht.tuKhoa(chinh, dem: widget.dieuKhienManHinh.demVbht),
    tieuDePhu: Vbht.tuKhoa(phu, dem: widget.dieuKhienManHinh.demVbht, ts: [thamSo])
  );

  @override
  TruongTieuDe? tieuDeChoDoan(int doan) {
    final DieuKhienManHinhTimKiem dkMh = widget.dieuKhienManHinh;
    final _PhanDoanManHinhTimKiem? phanDoan = _PhanDoanManHinhTimKiem.khoiTao(doan);
    return switch (phanDoan) {
      _PhanDoanManHinhTimKiem.tenSach => _xayDungTruongTieuDe(
        chinh: TK.sachCuaT,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqTenSach.length}"
      ),
      _PhanDoanManHinhTimKiem.isbn => _xayDungTruongTieuDe(
        chinh: TK.isbn,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqISBN.length}"
      ),
      _PhanDoanManHinhTimKiem.danhDau => _xayDungTruongTieuDe(
        chinh: TK.danhDau,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqDanhDau.length}"
      ),
      _PhanDoanManHinhTimKiem.tacGia => _xayDungTruongTieuDe(
        chinh: TK.tacGia,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqTacGia.length}"
      ),
      _PhanDoanManHinhTimKiem.dichGia => _xayDungTruongTieuDe(
        chinh: TK.dichGia,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqDichGia.length}"
      ),
      _PhanDoanManHinhTimKiem.nxb => _xayDungTruongTieuDe(
        chinh: TK.dvPhatHanh,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqNxb.length}"
      ),
      _PhanDoanManHinhTimKiem.viTri => _xayDungTruongTieuDe(
        chinh: TK.viTri,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqViTri.length}"
      ),
      _PhanDoanManHinhTimKiem.tenNhan => _xayDungTruongTieuDe(
        chinh: TK.tenNhan,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqTenNhan.length}"
      ),
      _PhanDoanManHinhTimKiem.giaTriNhan => _xayDungTruongTieuDe(
        chinh: TK.giaTriNhan,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqGiaTriNhan.length}"
      ),
      _PhanDoanManHinhTimKiem.nhieuTap => _xayDungTruongTieuDe(
        chinh: TK.tieuDeSachNhieuTap,
        phu: TK.soLuongKetQua,
        thamSo: "${dkMh._kqSachNhieuTap.length}"
      ),
      _ => null,
    };
  }

  @override
  List<Widget>? widgetsCuaCaDoan(int doan) => null;

  @override
  Widget? widgetCuaMuc(int doan, int dong) {
    return switch (_PhanDoanManHinhTimKiem.khoiTao(doan)) {
      _PhanDoanManHinhTimKiem.tuKhoa => _xayDungONhapTuKhoa(),
      _PhanDoanManHinhTimKiem.boLoc => _xayDungNhanBoLoc(dong),
      _PhanDoanManHinhTimKiem.tenSach => _xayDungDongKqTenSach(dong),
      _PhanDoanManHinhTimKiem.isbn => _xayDungDongKqISBN(dong),
      _PhanDoanManHinhTimKiem.danhDau => _xayDungDongKqDanhDau(dong),
      _PhanDoanManHinhTimKiem.tacGia => _xayDungDongKetQuaTen(
        danhSach: widget.dieuKhienManHinh._kqTacGia,
        stt: dong,
        khiNhan: widget.dieuKhienManHinh._khiNhanKqTacGia
      ),
      _PhanDoanManHinhTimKiem.dichGia => _xayDungDongKetQuaTen(
        danhSach: widget.dieuKhienManHinh._kqDichGia,
        stt: dong,
        khiNhan: widget.dieuKhienManHinh._khiNhanKqDichGia
      ),
      _PhanDoanManHinhTimKiem.nxb => _xayDungDongKetQuaTen(
        danhSach: widget.dieuKhienManHinh._kqNxb,
        stt: dong,
        khiNhan: widget.dieuKhienManHinh._khiNhanKqNXB
      ),
      _PhanDoanManHinhTimKiem.viTri => _xayDungDongKetQuaTen(
        danhSach: widget.dieuKhienManHinh._kqViTri,
        stt: dong,
        khiNhan: widget.dieuKhienManHinh._khiNhanKqViTri
      ),
      _PhanDoanManHinhTimKiem.tenNhan => _xayDungDongKetQuaTen(
        danhSach: widget.dieuKhienManHinh._kqTenNhan,
        stt: dong,
        khiNhan: widget.dieuKhienManHinh._khiNhanKqTenNhan
      ),
      _PhanDoanManHinhTimKiem.giaTriNhan => _xayDungDongKetQuaTenCuThe(
        stt: dong,
        ten: widget.dieuKhienManHinh._kqGiaTriNhan[dong],
        khiNhan: widget.dieuKhienManHinh._khiNhanKqGiaTriNhan
      ),
      _PhanDoanManHinhTimKiem.nhieuTap => _xayDungDongKetQuaTen(
        danhSach: widget.dieuKhienManHinh._kqSachNhieuTap,
        stt: dong,
        khiNhan: widget.dieuKhienManHinh._khiNhanKqSachNhieuTap
      ),
      _ => null
    };
  }

  /// Xây dựng Ô nhập từ khoá
  Widget _xayDungONhapTuKhoa() => TruongVanBan(
    cauHinh: CauHinhTruongVanBan(
      kieuNutEnter: TextInputAction.search,
      khiNhanEnter: (_) => widget.dieuKhienManHinh._khiNhanTimKiem()
    ),
    trinhDieuKhien: widget.dieuKhienManHinh.dkTuKhoa,
    xayDungNutBenPhai: (_, khaDung) => NutBamBieuTuongTieuDe(
      bieuTuong: Icons.search,
      khaDung: khaDung,
      thuocThanhDieuHuong: false,
      khiNhan: khaDung ? widget.dieuKhienManHinh._khiNhanTimKiem : null
    )
  );

  Vbht _xayDungNhanBoLocNhanSach(_LocTimKiem boLoc) {
    final NhanSach nhan = boLoc.duLieu as NhanSach;
    if (nhan.giaTri == null) {
      return Vbht.tuKhoa(TK.locTenNhan, dem: widget.dieuKhienManHinh.demVbht, ts: [nhan.ten]);
    }
    return Vbht.tuKhoa(TK.locGiaTriNhan, dem: widget.dieuKhienManHinh.demVbht, ts: [nhan.ten, nhan.giaTri ?? ""]);
  }

  /// Xây dựng nhãn bộ lọc
  Widget _xayDungNhanBoLoc(int stt) {
    _LocTimKiem boLoc = widget.dieuKhienManHinh._locTimKiem[stt];
    Vbht tieuDe = switch (boLoc.kieuLoc) {
      _PhanDoanManHinhTimKiem.tacGia => Vbht.tuKhoa(TK.locTacGia, dem: widget.dieuKhienManHinh.demVbht, ts: [boLoc.giaTriLoc]),
      _PhanDoanManHinhTimKiem.dichGia => Vbht.tuKhoa(TK.locDichGia, dem: widget.dieuKhienManHinh.demVbht, ts: [boLoc.giaTriLoc]),
      _PhanDoanManHinhTimKiem.nxb => Vbht.tuKhoa(TK.locNxb, dem: widget.dieuKhienManHinh.demVbht, ts: [boLoc.giaTriLoc]),
      _PhanDoanManHinhTimKiem.viTri => Vbht.tuKhoa(TK.locViTri, dem: widget.dieuKhienManHinh.demVbht, ts: [boLoc.giaTriLoc]),
      _PhanDoanManHinhTimKiem.tenNhan => _xayDungNhanBoLocNhanSach(boLoc),
      _PhanDoanManHinhTimKiem.nhieuTap => Vbht.tuKhoa(TK.locNhieuTap, dem: widget.dieuKhienManHinh.demVbht, ts: [boLoc.giaTriLoc]),
      _ => Vbht.trucTiep("${boLoc.kieuLoc}: ${boLoc.giaTriLoc}")
    };
    return TruongNutBam(
      khiNhan: () => widget.dieuKhienManHinh._khiNhanBoLoc(boLoc),
      tieuDe: tieuDe,
      icon: Icons.delete
    );
  }

  String _xayDungTuKhoaNoiBatChoLocNhan(NhanSach locNhan) {
    if (locNhan.giaTri == null) {
      return locNhan.ten;
    }
    return "${locNhan.ten}: ${locNhan.giaTri!}";
  }

  /// Xây dựng các trường thông tin sách để hiển thị
  void _xayDungCacTruongThongTinSach(List<ThongTinHienThiTruongSach> dsTruongSach) {
    List<String> tuKhoaTacGia = [];
    List<String> tuKhoaDichGia = [];
    List<String> tuKhoaNXB = [];
    List<String> tuKhoaViTri = [];
    List<String> tuKhoaNhan = [];
    String? tuKhoaNhieuTap;
    for (_LocTimKiem loc in widget.dieuKhienManHinh._locTimKiem) {
      switch (loc.kieuLoc) {
      case _PhanDoanManHinhTimKiem.tacGia:
        tuKhoaTacGia.add(loc.giaTriLoc);
        break;
      case _PhanDoanManHinhTimKiem.dichGia:
        tuKhoaDichGia.add(loc.giaTriLoc);
        break;
      case _PhanDoanManHinhTimKiem.nxb:
        tuKhoaNXB.add(loc.giaTriLoc);
        break;
      case _PhanDoanManHinhTimKiem.viTri:
        tuKhoaViTri.add(loc.giaTriLoc);
        break;
      case _PhanDoanManHinhTimKiem.tenNhan:
        tuKhoaNhan.add(_xayDungTuKhoaNoiBatChoLocNhan(loc.duLieu));
        break;
      case _PhanDoanManHinhTimKiem.nhieuTap:
        tuKhoaNhieuTap = loc.giaTriLoc;
        break;
      default:
        break;
      }
    }
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.tacGia, tuKhoaNoiBat: tuKhoaTacGia, laNoiBatChinh: false));
    if (tuKhoaDichGia.isNotEmpty) {
      dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.dichGia, tuKhoaNoiBat: tuKhoaDichGia, laNoiBatChinh: false));
    }
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.nxb, tuKhoaNoiBat: tuKhoaNXB, laNoiBatChinh: false));
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.viTri, tuKhoaNoiBat: tuKhoaViTri, laNoiBatChinh: false));
    if (tuKhoaNhan.isNotEmpty) {
      dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.nhan, tuKhoaNoiBat: tuKhoaNhan, laNoiBatChinh: false));
    }
    if (tuKhoaNhieuTap != null && tuKhoaNhieuTap.isNotEmpty) {
      dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.nhieuTap, tuKhoaNoiBat: [tuKhoaNhieuTap], laNoiBatChinh: false));
    }
  }

  /// Xây dựng dòng kết quả Sách
  Widget _xayDungDongKqTenSach(int stt) {
    if (stt == 0) {
      return TruongNutBam(
        khiNhan: widget.dieuKhienManHinh._khiNhanThongKe,
        tieuDe: Vbht.tuKhoa(TK.thongKe, dem: widget.dieuKhienManHinh.demVbht),
        icon: Icons.analytics
      );
    }
    Sach sach = widget.dieuKhienManHinh._kqTenSach[stt - 1];
    List<ThongTinHienThiTruongSach> dsTruongSach = [];
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.tenSach, tuKhoaNoiBat: [tuKhoa], laNoiBatChinh: true));
    _xayDungCacTruongThongTinSach(dsTruongSach);
        return _xayDungDongKetQuaSach(
      stt: stt - 1,
      sach: sach,
      dsTruongSach: dsTruongSach,
      khiNhan: widget.dieuKhienManHinh._khiNhanKqTenSach
    );
  }

  /// Xây dựng dòng kết quả ISBN
  Widget _xayDungDongKqISBN(int stt) {
    Sach sach = widget.dieuKhienManHinh._kqISBN[stt];
    List<ThongTinHienThiTruongSach> dsTruongSach = [];
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.tenSach));
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.isbn, tuKhoaNoiBat: [tuKhoa], laNoiBatChinh: true));
    _xayDungCacTruongThongTinSach(dsTruongSach);
    return _xayDungDongKetQuaSach(
      stt: stt,
      sach: sach,
      dsTruongSach: dsTruongSach,
      khiNhan: widget.dieuKhienManHinh._khiNhanKqISBN
    );
  }

  /// Xây dựng dòng kết quả Đánh dấu
  Widget _xayDungDongKqDanhDau(int stt) {
    Sach sach = widget.dieuKhienManHinh._kqDanhDau[stt];
    List<ThongTinHienThiTruongSach> dsTruongSach = [];
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.tenSach));
    _xayDungCacTruongThongTinSach(dsTruongSach);
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.danhDau, tuKhoaNoiBat: [tuKhoa], laNoiBatChinh: true));
    return _xayDungDongKetQuaSach(
      stt: stt,
      sach: sach,
      dsTruongSach: dsTruongSach,
      khiNhan: widget.dieuKhienManHinh._khiNhanKqDanhDau
    );
  }

  /// Xây dựng dòng kết quả sách
  Widget _xayDungDongKetQuaSach({
    required int stt,
    required Sach sach,
    required List<ThongTinHienThiTruongSach> dsTruongSach,
    required void Function(int) khiNhan
  }) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    child: TruongSach(
      sach: sach,
      thongTinCanHienThi: dsTruongSach,
    ), onTap: () => khiNhan.call(stt)
  );

  /// Xây dựng dòng kết quả chỉ có tên cụ thể
  Widget _xayDungDongKetQuaTenCuThe({
    required int stt,
    required String ten,
    required void Function(int) khiNhan
  }) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: VanBanHienThiNoiBat(
        vanBan: VanBanNoiBat(
          vanBanDayDu: ten,
          vanBanNoiBat: [tuKhoa]
        )
      ),
      onTap: () => khiNhan.call(stt)
  );

  /// Xây dựng dòng kết quả chỉ có tên
  Widget _xayDungDongKetQuaTen({
    required List<DuLieuCoso> danhSach,
    required int stt,
    required void Function(int) khiNhan
  }) => _xayDungDongKetQuaTenCuThe(stt: stt, ten: danhSach[stt].ten, khiNhan: khiNhan);

  @override
  double? khoangCachPhiaTren(int doan, int dong) {
    const double khoangTrongCoSo = 10.0;
    return switch (_PhanDoanManHinhTimKiem.khoiTao(doan)) {
      _PhanDoanManHinhTimKiem.tacGia ||
      _PhanDoanManHinhTimKiem.dichGia ||
      _PhanDoanManHinhTimKiem.nxb ||
      _PhanDoanManHinhTimKiem.viTri ||
      _PhanDoanManHinhTimKiem.tenNhan ||
      _PhanDoanManHinhTimKiem.giaTriNhan ||
      _PhanDoanManHinhTimKiem.nhieuTap
      => dong == 0 ? khoangTrongCoSo : null,
      _ => null
    };
  }

  @override
  double? khoangCachPhiaDuoi(int doan, int dong) {
    const double khoangTrongCoSo = 10.0;
    return switch (_PhanDoanManHinhTimKiem.khoiTao(doan)) {
      _PhanDoanManHinhTimKiem.tacGia ||
      _PhanDoanManHinhTimKiem.dichGia ||
      _PhanDoanManHinhTimKiem.nxb ||
      _PhanDoanManHinhTimKiem.viTri ||
      _PhanDoanManHinhTimKiem.tenNhan ||
      _PhanDoanManHinhTimKiem.giaTriNhan ||
      _PhanDoanManHinhTimKiem.nhieuTap
      => khoangTrongCoSo,
      _PhanDoanManHinhTimKiem.chanTrang => 50.0,
      _ => null
    };
  }

}
