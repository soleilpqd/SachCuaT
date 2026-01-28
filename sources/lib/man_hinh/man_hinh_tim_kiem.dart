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
import 'package:flutter/widgets.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/luutrucauhinh.dart';
import 'package:sach_cua_t/models/vtv.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/truong_bat_tat.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

// TODO: màn hình danh sách sách

enum CheDoManHinhTimKiem {
  timKiemTatCa,
  chonSachLapChuoi
}

class _DieuKhienManHinhTimKiem {

  late BuildContext context;
  /// Bộ đệm Văn bản hiển thị
  final BoDemVbht demVbht = BoDemVbht();
  /// Chế độ làm việc
  final CheDoManHinhTimKiem cheDo;
  /// Callback với chế độ `chonSachLapChuoi`
  final void Function(Sach)? khiChonSach;
  /// Điều khiển ô nhập từ khoá
  final DieuKhienTruongVanBan dkTuKhoa = DieuKhienTruongVanBan();
  /// Điều khiển ô nhập Tìm chính xác
  final DieuKhienTruongBatTat dkTimChinhXac = DieuKhienTruongBatTat();
  /// Hàm xử lý để chuyển sang màn hình mới (gán bởi màn hình chính, gọi bởi phần view nội dung)
  void Function(String, Widget)? push;
  /// Hàm xử lý khi quay lại (gán bởi màn hình chính, gọi bởi phần view nội dung)
  void Function()? pop;

  _DieuKhienManHinhTimKiem({required this.cheDo, this.khiChonSach});

}

class ManHinhTimKiem extends StatelessWidget with KhuonMauQuanLyManHinh {

  static const String maManHinh = "ManHinhTimKiem";

  final _DieuKhienManHinhTimKiem _dieuKhienManHinh;

  ManHinhTimKiem({super.key, required CheDoManHinhTimKiem cheDo, void Function(Sach)? khiChonSach}) :
    _dieuKhienManHinh = _DieuKhienManHinhTimKiem(cheDo: cheDo, khiChonSach: khiChonSach) {
    _dieuKhienManHinh.push = push;
    _dieuKhienManHinh.pop = pop;
  }

  @override
  String get tenManHinh => maManHinh;

  @override
  BuildContext get context => _dieuKhienManHinh.context;

  @override
  Widget build(BuildContext context) {
    _dieuKhienManHinh.context = context;
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(TK.timKiem, dem: _dieuKhienManHinh.demVbht),
      noiDung: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TruongVanBan(trinhDieuKhien: _dieuKhienManHinh.dkTuKhoa, cauHinh: const CauHinhTruongVanBan(tuDongKichHoatNhap: true)),
          TruongBatTat(tieuDe: Vbht.tuKhoa(TK.timKiemChinhXac, dem: _dieuKhienManHinh.demVbht), trinhDieuKhien: _dieuKhienManHinh.dkTimChinhXac),
          Expanded(child: _ManHinhTimKiem(dieuKhienManHinh: _dieuKhienManHinh))
        ]
      )
    );
  }

}

class _ManHinhTimKiem extends StatefulWidget {

  final _DieuKhienManHinhTimKiem dieuKhienManHinh;

  const _ManHinhTimKiem({required this.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhTimKiem();

}

class _TrangThaiManHinhTimKiem extends State<_ManHinhTimKiem> with TheoDoiDieuKhienCoSo {

  /// Đồng hồ tìm kiếm
  Timer? _dongHoTimKiem;
  String _tuKhoaTimKiem = "";

  List<Sach> _dsKqSach = [];
  List<NhaXuatBan> _dsKqNxb = [];
  List<TacGia> _dsKqTacGia = [];
  List<DichGia> _dsKqDichGia = [];
  List<ViTriSach> _dsKqViTri = [];
  List<DanhDauSach> _dsKqDanhDau = [];
  List<NhanSach> _dsKqNhan = [];
  List<NhomSach> _dsKqNhom = [];

  @override
  void initState() {
    super.initState();
    widget.dieuKhienManHinh.dkTuKhoa.themTheoDoi(this);
    LuuTruCauHinh().layTimKiemChinhXac().then((value) {
      widget.dieuKhienManHinh.dkTimChinhXac.giaTri = value ?? false;
      widget.dieuKhienManHinh.dkTimChinhXac.themTheoDoi(this);
    });
  }

  @override
  void didUpdateWidget(covariant _ManHinhTimKiem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dieuKhienManHinh != widget.dieuKhienManHinh) {
      oldWidget.dieuKhienManHinh.dkTuKhoa.boTheoDoi(this);
      oldWidget.dieuKhienManHinh.dkTimChinhXac.boTheoDoi(this);
      widget.dieuKhienManHinh.dkTuKhoa.themTheoDoi(this);
      widget.dieuKhienManHinh.dkTimChinhXac.themTheoDoi(this);
    }
  }

  @override
  void dispose() {
    widget.dieuKhienManHinh.dkTuKhoa.boTheoDoi(this);
    widget.dieuKhienManHinh.dkTimChinhXac.boTheoDoi(this);
    _dongHoTimKiem?.cancel();
    _dongHoTimKiem = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(5),
        children: _xayDungManHinhKetQua(context)
      );
  }

  List<Widget> _xayDungManHinhKetQua(BuildContext context) {
    List<Widget> ketQua = [];

    return ketQua;
  }

  @override
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {
    super.dieuKhienCoSoThayDoiThuocTinh(nguon, cacGiaTri);
    if (nguon == widget.dieuKhienManHinh.dkTuKhoa && cacGiaTri.keys.contains(ThuocTinhTruongVanBan.vanBan.name)) {
      _khiTuKhoaThayDoi();
    } else if (nguon == widget.dieuKhienManHinh.dkTimChinhXac && cacGiaTri.keys.contains(ThuocTinhTruongBatTat.giaTri.name)) {
      _khiTimChinhXacThayDoi();
    }
  }

  /// Khi `Từ khoá` thay đổi
  void _khiTuKhoaThayDoi() {
    _dongHoTimKiem?.cancel();
    _dongHoTimKiem = Timer(const Duration(milliseconds: 1000), _batDauTim);
  }

  /// Bắt đầu tìm
  void _batDauTim() {
    _dongHoTimKiem = null;
    if (_tuKhoaTimKiem != widget.dieuKhienManHinh.dkTuKhoa.vanBan) {
      _tuKhoaTimKiem = widget.dieuKhienManHinh.dkTuKhoa.vanBan;
      if (_tuKhoaTimKiem.isNotEmpty) {
        _tienHanhTim();
      }
    }
  }

  /// Khi `Tìm chính xác` thay đổi
  void _khiTimChinhXacThayDoi() {
    LuuTruCauHinh().luuTimKiemChinhXac(widget.dieuKhienManHinh.dkTimChinhXac.giaTri);
    _tienHanhTim();
  }

  /// Tiến hành tìm
  void _tienHanhTim() {

  }

}