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
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_liet_ke_sach.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/danh_sach_hien_thi.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Các phân đoạn màn hình thống kê
enum _PhanDoanManHinhThongKe {
  /// Tổng số
  tong,
  /// Tác giả
  tacGia,
  /// Dịch giả
  dichGia,
  /// Nhà xuất bản (Đơn vị phát hành)
  nxb,
  /// Vị trí
  viTri,
  /// Nhãn
  nhan,
  /// Nhiều tập
  nhieuTap,
  /// Đáy, chân trang
  chanTrang;

  /// Khởi tạo từ giá trị thô [tho]
  static _PhanDoanManHinhThongKe? khoiTao(int tho) {
    return switch (tho) {
      0 => tong,
      1 => tacGia,
      2 => dichGia,
      3 => nxb,
      4 => viTri,
      5 => nhan,
      6 => nhieuTap,
      7 => chanTrang,
      _ => null,
    };
  }

  /// Tổng số
  static int tongSo() => values.length;

}

class _MucThongKe<T> {
  int soLuong = 0;
  final T giaTri;

  _MucThongKe({required this.giaTri, this.soLuong = 1});
}

/// Điều khiển màn hình thống kê
class DieuKhienManHinhThongKe extends DieuKhienManHinh {

  /// Bộ đệm Văn bản hiển thị
  final BoDemVbht demVbht = BoDemVbht();

  /// Danh sách sách
  final List<Sach> dsSach;
  /// Danh sách Tác giả
  final List<_MucThongKe<String>> _kqTacGia = [];
  /// Danh sách Dịch giả
  final List<_MucThongKe<String>> _kqDichGia = [];
  /// Danh sách Đơn vị phát hành
  final List<_MucThongKe<String>> _kqNxb = [];
  /// Danh sách Vị trí
  final List<_MucThongKe<String>> _kqViTri = [];
  /// Danh sách các nhãn sách
  final List<_MucThongKe<String>> _kqNhan = [];
  /// Danh sách các chuỗi sách nhiều tập
  final List<_MucThongKe<String>> _kqSachNhieuTap = [];

  final ScrollController _dkCuon = ScrollController();

  DieuKhienManHinhThongKe({required this.dsSach}) {
    widgetCuaManHinh = _ManHinhThongKe(dieuKhienManHinh: this);
    _phanTich();
  }

  /// Đếm số lượng sách có cùng 1 thuộc tính
  void _phanTichDanhSach<T>(List<T> dsNguon, List<_MucThongKe<T>> dsDich) {
    for (final T nguon in dsNguon) {
      final int stt = dsDich.indexWhere((muc) => muc.giaTri == nguon);
      if (stt < 0) {
        dsDich.add(_MucThongKe(giaTri: nguon));
      } else {
        dsDich[stt].soLuong += 1;
      }
    }
  }

  /// Chuyển danh sách nhãn từ kiểu Map sang List
  List<String> _lamPhangDSNhan(Map<String, String> nhan) {
    List<String> dsNhanGt = [];
    for (final String tenNhan in nhan.keys) {
      final String gtNhan = nhan[tenNhan] ?? "";
      dsNhanGt.add("$tenNhan: $gtNhan");
    }
    return dsNhanGt;
  }

  /// Phân tích thống kê
  void _phanTich() {
    for (final Sach sach in dsSach) {
      _phanTichDanhSach(sach.tacGia, _kqTacGia);
      _phanTichDanhSach(sach.dichGia, _kqDichGia);
      _phanTichDanhSach(sach.nhaXuatBan, _kqNxb);
      _phanTichDanhSach(sach.viTri, _kqViTri);
      final List<String> dsNhanGt = _lamPhangDSNhan(sach.nhan);
      _phanTichDanhSach(dsNhanGt, _kqNhan);
      if (sach.nhieuTap != null && sach.nhieuTap!.isNotEmpty) {
        _phanTichDanhSach([sach.nhieuTap], _kqSachNhieuTap);
      }
    }
  }

  /// Khi nhấn Tiêu đề của màn hình
  void _khiNhanTieuDeMh() {
    _dkCuon.cuonLenDau();
  }

  /// Khi nhấn Nút quay lại (<)
  void _khiNhanQuayLai() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  /// Chuyển sang màn hình Liệt kê sách
  void _lietKeSach(List<_MucThongKe<String>> danhSach, int stt, List<String> Function(Sach) thuocTinh) {
    final String gt = danhSach[stt].giaTri;
    final List<Sach> kq = dsSach.where((muc) => thuocTinh(muc).contains(gt)).toList();
    final DieuKhienManHinhLietKeSach mhLietKe = DieuKhienManHinhLietKeSach(dsSach: kq);
    luongManHinh?.themManHinh(manHinh: mhLietKe);
  }

  /// Khi nhấn vào 1 dòng tác giả
  void _khiNhanKqTacGia(int stt) {
    _lietKeSach(_kqTacGia, stt, (muc) => muc.tacGia);
  }

  /// Khi nhấn vào 1 dòng dịch giả
  void _khiNhanKqDichGia(int stt) {
    _lietKeSach(_kqDichGia, stt, (muc) => muc.dichGia);
  }

  /// Khi nhấn vào 1 dòng Nhà xuất bản
  void _khiNhanKqNxb(int stt) {
    _lietKeSach(_kqNxb, stt, (muc) => muc.nhaXuatBan);
  }

  /// Khi nhấn vào 1 dòng Vị trí
  void _khiNhanKqViTri(int stt) {
    _lietKeSach(_kqViTri, stt, (muc) => muc.viTri);
  }

  /// Khi nhấn vào 1 dòng Nhãn sách
  void _khiNhanKqNhan(int stt) {
    _lietKeSach(_kqNhan, stt, (muc) => _lamPhangDSNhan(muc.nhan));
  }

  /// Khi nhấn vào 1 dòng Chuỗi nhiều tập
  void _khiNhanKqNhieuTap(int stt) {
    _lietKeSach(_kqSachNhieuTap, stt, (muc) => [muc.nhieuTap ?? ""]);
  }

}

/// Giao diện màn hình thống kê
class _ManHinhThongKe extends WidgetTinhCuaDieuKhienManHinh<DieuKhienManHinhThongKe> with ListViewTheoPhanDoan {

  _ManHinhThongKe({required super.dieuKhienManHinh});

  @override
  Widget build(BuildContext context) => ManHinhCoSo(
    tieuDe: Vbht.tuKhoa(TK.thongKe, dem: dieuKhienManHinh.demVbht),
    khiNhanQuayLai: dieuKhienManHinh._khiNhanQuayLai,
    khiNhanTieuDe: dieuKhienManHinh._khiNhanTieuDeMh,
    noiDung: xayDungListView(context, scrollCtrl: dieuKhienManHinh._dkCuon)
  );

  @override
  int soLuongPhanDoan() => _PhanDoanManHinhThongKe.tongSo();

  @override
  int soMucCuaPhanDoan(int doan) {
    return switch (_PhanDoanManHinhThongKe.khoiTao(doan)) {
      _PhanDoanManHinhThongKe.tong => 1,
      _PhanDoanManHinhThongKe.tacGia => dieuKhienManHinh._kqTacGia.length,
      _PhanDoanManHinhThongKe.dichGia => dieuKhienManHinh._kqDichGia.length,
      _PhanDoanManHinhThongKe.nxb => dieuKhienManHinh._kqNxb.length,
      _PhanDoanManHinhThongKe.viTri => dieuKhienManHinh._kqViTri.length,
      _PhanDoanManHinhThongKe.nhan => dieuKhienManHinh._kqNhan.length,
      _PhanDoanManHinhThongKe.nhieuTap => dieuKhienManHinh._kqSachNhieuTap.length,
      _PhanDoanManHinhThongKe.chanTrang => 1,
      _ => 0
    };
  }

  /// Xây dựng trường tiêu đề
  TruongTieuDe _xayDungTruongTieuDe({required TK chinh, required TK phu, required String thamSo}) => TruongTieuDe(
    tieuDeChinh: Vbht.tuKhoa(chinh, dem: dieuKhienManHinh.demVbht),
    tieuDePhu: Vbht.tuKhoa(phu, dem: dieuKhienManHinh.demVbht, ts: [thamSo])
  );

  @override
  TruongTieuDe? tieuDeChoDoan(int doan) {
    final _PhanDoanManHinhThongKe? phanDoan = _PhanDoanManHinhThongKe.khoiTao(doan);
    return switch (phanDoan) {
      _PhanDoanManHinhThongKe.tong => _xayDungTruongTieuDe(
        chinh: TK.sachCuaT,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh.dsSach.length}"
      ),
      _PhanDoanManHinhThongKe.tacGia => _xayDungTruongTieuDe(
        chinh: TK.tacGia,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh._kqTacGia.length}"
      ),
      _PhanDoanManHinhThongKe.dichGia => _xayDungTruongTieuDe(
        chinh: TK.dichGia,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh._kqDichGia.length}"
      ),
      _PhanDoanManHinhThongKe.nxb => _xayDungTruongTieuDe(
        chinh: TK.dvPhatHanh,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh._kqNxb.length}"
      ),
      _PhanDoanManHinhThongKe.viTri => _xayDungTruongTieuDe(
        chinh: TK.viTri,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh._kqViTri.length}"
      ),
      _PhanDoanManHinhThongKe.nhan => _xayDungTruongTieuDe(
        chinh: TK.tieuDeNhan,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh._kqNhan.length}"
      ),
      _PhanDoanManHinhThongKe.nhieuTap => _xayDungTruongTieuDe(
        chinh: TK.tieuDeSachNhieuTap,
        phu: TK.soLuongKetQua,
        thamSo: "${dieuKhienManHinh._kqSachNhieuTap.length}"
      ),
      _ => null,
    };
  }

  @override
  List<Widget>? widgetsCuaCaDoan(int doan) => null;

  @override
  Widget? widgetCuaMuc(int doan, int dong) {
    return switch (_PhanDoanManHinhThongKe.khoiTao(doan)) {
      _PhanDoanManHinhThongKe.tacGia => _xayDungDongKetQua(
        danhSach: dieuKhienManHinh._kqTacGia,
        stt: dong,
        khiNhan: dieuKhienManHinh._khiNhanKqTacGia
      ),
      _PhanDoanManHinhThongKe.dichGia => _xayDungDongKetQua(
        danhSach: dieuKhienManHinh._kqDichGia,
        stt: dong,
        khiNhan: dieuKhienManHinh._khiNhanKqDichGia
      ),
      _PhanDoanManHinhThongKe.nxb => _xayDungDongKetQua(
        danhSach: dieuKhienManHinh._kqNxb,
        stt: dong,
        khiNhan: dieuKhienManHinh._khiNhanKqNxb
      ),
      _PhanDoanManHinhThongKe.viTri => _xayDungDongKetQua(
        danhSach: dieuKhienManHinh._kqViTri,
        stt: dong,
        khiNhan: dieuKhienManHinh._khiNhanKqViTri
      ),
      _PhanDoanManHinhThongKe.nhan => _xayDungDongKetQua(
        danhSach: dieuKhienManHinh._kqNhan,
        stt: dong,
        khiNhan: dieuKhienManHinh._khiNhanKqNhan
      ),
      _PhanDoanManHinhThongKe.nhieuTap => _xayDungDongKetQua(
        danhSach: dieuKhienManHinh._kqSachNhieuTap,
        stt: dong,
        khiNhan: dieuKhienManHinh._khiNhanKqNhieuTap
      ),
      _ => null
    };
  }

  /// Xây dựng dòng kết quả chỉ có tên
  Widget _xayDungDongKetQua({
    required List<_MucThongKe<String>> danhSach,
    required int stt,
    required void Function(int) khiNhan
  }) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: VbhtWidget(
        coChu: CoChu.binhThuong,
        text: Vbht.trucTiep("${danhSach[stt].giaTri} [${danhSach[stt].soLuong}]"),
      ),
      onTap: () => khiNhan.call(stt)
  );

  @override
  double? khoangCachPhiaTren(int doan, int dong) {
    return switch (_PhanDoanManHinhThongKe.khoiTao(doan)) {
      _PhanDoanManHinhThongKe.tong => null,
      _PhanDoanManHinhThongKe.chanTrang => 50.0,
      _ => 10.0
    };
  }

  @override
  double? khoangCachPhiaDuoi(int doan, int dong) {
    return switch (_PhanDoanManHinhThongKe.khoiTao(doan)) {
      _PhanDoanManHinhThongKe.tong => null,
      _PhanDoanManHinhThongKe.chanTrang => 50.0,
      _ => null
    };
  }

}
