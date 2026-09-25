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
import 'package:sach_cua_t/main.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_chuan_hoa_anh.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_sach.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tim_kiem.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tro_giup.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/models/operations/thao_tac_nap_man_hinh_mo_dau.dart';
import 'package:sach_cua_t/models/xu_ly_nut_lui_android.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/danh_sach_hien_thi.dart';
import 'package:sach_cua_t/views/dieu_khien_cuon.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/truong_nut_bam.dart';
import 'package:sach_cua_t/views/truong_nut_bam_thanh_dieu_huong.dart';
import 'package:sach_cua_t/views/truong_sach.dart';
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

class DieuKhienManHinhMoDau extends DieuKhienManHinh with XuLyNutLuiAndroid {

  final BoDemVbht _boDemVbht = BoDemVbht();
  final DieuKhienCuon _dkCuon = DieuKhienCuon();
  final Vbht phienBan = Vbht.gianTiep(HeThongMay.duyNhat.layThongTinPhienBan());
  final ThaoTacNapDuLieuManHinhMoDau nguonDuLieu = ThaoTacNapDuLieuManHinhMoDau();
  final DieuKhienTruongNutBamThanhDieuHuong _dkNutPhai = DieuKhienTruongNutBamThanhDieuHuong();
  int _khoiLuongDuLieu = 0;

  DieuKhienManHinhMoDau() {
    widgetCuaManHinh = _ManHinhMoDau(dkMh: this);
  }

  @override
  void manHinhSeThanhManHinhChinhTrongLuong() {
    super.manHinhSeThanhManHinhChinhTrongLuong();
    _truyVanDuLieu();
  }

  @override
  bool khiNhanNutLuiAndroid() => true;

  void _cauHinhNutDieuHuong() {
    List<NutBamBieuTuong> nutPhai = [];
    if (nguonDuLieu.tongSoSach > 0) {
      nutPhai.add(NutBamBieuTuong(
        bieuTuong: Icons.camera_alt_outlined,
        thuocThanhDieuHuong: true,
        khiNhan: _khiNhanQuet
      ));
      nutPhai.add(NutBamBieuTuong(
        bieuTuong: Icons.search,
        thuocThanhDieuHuong: true,
        khiNhan: _khiNhanTimKiem
      ));
    }
    nutPhai.add(ManHinhCoSo.taoNutHuongDan(KieuHuongDan.chinh));
    _dkNutPhai.dsNut = nutPhai;
  }

  void _truyVanDuLieu() {
    nguonDuLieu.napDuLieu().then((_) {
      _cauHinhNutDieuHuong();
      trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
    });
    CoSoDuLieu().doKhoiLuongDuLieu().then((khoiLuong) {
      _khoiLuongDuLieu = khoiLuong;
      trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
    });
    _cauHinhNutDieuHuong();
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  /// Khi nhấn tiêu đề màn hình
  void _khiNhanTieuDeManHinh() {
    _dkCuon.cuonLenDau();
  }

  /// Khi nhấn nút Thêm sách
  void _khiNhanThemSach() {
    final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach();
    luongManHinh?.themManHinh(manHinh: mhSach);
  }

  /// Khi nhấn nút Tìm kiếm
  void _khiNhanTimKiem() {
    final DieuKhienManHinhTimKiem mhTimKiem = DieuKhienManHinhTimKiem();
    luongManHinh?.themManHinh(manHinh: mhTimKiem);
  }

    /// Khi không có máy ảnh
  void _khiKhongCoMayAnh() {
    HopThoai.hienThiHopThoaiThongBao(
      noiDung: Vbht.tuKhoa(TK.khongCoMayAnh, dem: _boDemVbht),
      nhanCacNut: [Vbht.tuKhoa(TK.dong, dem: _boDemVbht)]
    );
  }

  /// Khi nhấn nút quét mã vạch
  void _khiNhanQuet() async {
    final String? maISBN = await HeThongMay.duyNhat.quetMaISBN().onError((error, stackTrace) {
      _khiKhongCoMayAnh();
      return;
    });
    if (maISBN != null) {
      int? maSach = await CoSoDuLieu().timSachTheoISBN(maISBN);
      if (maSach != null) {
        final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach(maSach: maSach);
        luongManHinh?.themManHinh(manHinh: mhSach);
      } else {
        HopThoai.hienThiHopThoaiThongBao(
          noiDung: Vbht.tuKhoa(TK.sachKhongTonTai, dem: _boDemVbht),
          nhanCacNut: [Vbht.tuKhoa(TK.dong, dem: _boDemVbht)]
        );
      }
    }
  }

  /// Khi nhấn vào 1 dòng sách
  void _khiNhanSach(Sach sach) {
    final DieuKhienManHinhSach mhSach = DieuKhienManHinhSach(maSach: sach.maSo);
    luongManHinh?.themManHinh(manHinh: mhSach);
  }

  void _khiNhanXoaDanhDau(int stt) {
    final Sach sach = nguonDuLieu.dsDanhDau[stt];
    HopThoai.hienThiHopThoaiThongBao(
      noiDung: Vbht.tuKhoa(TK.xoaNoiDung, dem: _boDemVbht, ts: [sach.danhDau.first.noiDung]),
      nhanCacNut: [Vbht.tuKhoa(TK.xoa, dem: _boDemVbht), Vbht.tuKhoa(TK.dong, dem: _boDemVbht)],
      cacNutCanChuY: [0],
      khiDong: (nut, _) {
        if (nut == 0) {
          nguonDuLieu.xoaDanhDau(stt).then((_) => trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this));
        }
      },
    );
  }

  /// Khi nhấn Giới thiệu
  void _khiNhanGioiThieu() {
    MainApp.luongMHGoc.themManHinh(manHinh: DieuKhienManHinhHuongDan(kieu: KieuHuongDan.gioiThieu));
  }

  void _khiNhanChuanHoaAnh() {
    luongManHinh?.themManHinh(manHinh: DieuKhienManHinhChuanHoaAnh());
  }

}

class _ManHinhMoDau extends StatelessWidget {

  final DieuKhienManHinhMoDau dkMh;

  const _ManHinhMoDau({required this.dkMh});

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(TK.sachCuaT),
      khiNhanTieuDe: dkMh._khiNhanTieuDeManHinh,
      nutTrai: dkMh.nguonDuLieu.tongSoSach > 0 ? NutBamBieuTuong(
        bieuTuong: Icons.add,
        thuocThanhDieuHuong: true,
        khiNhan: dkMh._khiNhanThemSach
      ) : null,
      nutPhai: [TruongNutBamThanhDieuHuong(dieuKhien: dkMh._dkNutPhai)],
      noiDung: _NoiDungManHinhMoDau(dieuKhienManHinh: dkMh)
    );
  }

}

class _NoiDungManHinhMoDau extends WidgetCuaDieuKhienManHinh<DieuKhienManHinhMoDau> {

  _NoiDungManHinhMoDau({required super.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhMoDau();

}

class _TrangThaiManHinhMoDau extends TrangThaiWidgetCuaDieuKhien<_NoiDungManHinhMoDau> with ListViewTheoPhanDoan {

  @override
  void capNhatGiaoDienCuaManHinh({required DieuKhienManHinh dieuKhienManHinh, ThamSoDieuKhienWidgetManHinh? duLieuDinhKem}) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => xayDungListView(context, scrollCtrl: widget.dieuKhienManHinh._dkCuon.dkCuon);

  /// Xây dựng màn hình lần đầu
  Widget _xayDungManHinhLanDau() {
    final DieuKhienManHinhMoDau dkMh = widget.dieuKhienManHinh;
    return SizedBox(height: 100, child: Column(
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
    ));
  }

  @override
  double? khoangCachPhiaDuoi(int doan, int dong) {
    return switch (_PhanDoanManHinhMoDau.khoiTao(doan)) {
      _PhanDoanManHinhMoDau.gioiThieu => dong == 1 ? 50.0 : null, // TODO: xem bên dưới (áp dụng với dòng cuối cùng)
      _ => null
    };
  }

  @override
  double? khoangCachPhiaTren(int doan, int dong) {
    return null;
  }

  @override
  int soLuongPhanDoan() {
    if (widget.dieuKhienManHinh.nguonDuLieu.tongSoSach > 0) {
      return _PhanDoanManHinhMoDau.tongSo();
    }
    return 2;
  }

  @override
  int soMucCuaPhanDoan(int doan) {
    if (widget.dieuKhienManHinh.nguonDuLieu.tongSoSach > 0) {
      return switch(_PhanDoanManHinhMoDau.khoiTao(doan)) {
        _PhanDoanManHinhMoDau.danhDau => widget.dieuKhienManHinh.nguonDuLieu.dsDanhDau.length,
        _PhanDoanManHinhMoDau.ganDay => widget.dieuKhienManHinh.nguonDuLieu.dsGanDay.length,
        _PhanDoanManHinhMoDau.gioiThieu => 2, // TODO: 2 để ẩn dòng Chuẩn hoá ảnh, 3 để hiện
        _ => 0
      };
    }
    return 1;
  }

  @override
  TruongTieuDe? tieuDeChoDoan(int doan) {
    if (widget.dieuKhienManHinh.nguonDuLieu.tongSoSach > 0) {
      return switch(_PhanDoanManHinhMoDau.khoiTao(doan)) {
        _PhanDoanManHinhMoDau.danhDau => _xayDungTruongTieuDe(TK.danhDau),
        _PhanDoanManHinhMoDau.ganDay => _xayDungTruongTieuDe(TK.ganDay),
        _PhanDoanManHinhMoDau.gioiThieu => _xayDungTruongTieuDe(
          TK.gioiThieu,
          phu: Vbht.tuKhoa(
            TK.tongSoSach,
            dem: widget.dieuKhienManHinh._boDemVbht,
            ts: [widget.dieuKhienManHinh.nguonDuLieu.tongSoSach.toString()]
          )
        ),
        _ => null
      };
    } else if (doan == 1) {
      return _xayDungTruongTieuDe(TK.gioiThieu);
    }
    return null;
  }

  TruongTieuDe _xayDungTruongTieuDe(TK tk, {Vbht? phu}) => TruongTieuDe(
    tieuDeChinh: Vbht.tuKhoa(tk, dem: widget.dieuKhienManHinh._boDemVbht),
    tieuDePhu: phu,
  );

  @override
  Widget? widgetCuaMuc(int doan, int dong) {
    final DieuKhienManHinhMoDau dkMh = widget.dieuKhienManHinh;
    if (widget.dieuKhienManHinh.nguonDuLieu.tongSoSach > 0) {
      return switch(_PhanDoanManHinhMoDau.khoiTao(doan)) {
        _PhanDoanManHinhMoDau.danhDau => _xayDungDanhDau(dong),
        _PhanDoanManHinhMoDau.ganDay => _xayDungTruongSach(dkMh.nguonDuLieu.dsGanDay[dong], false),
        _PhanDoanManHinhMoDau.gioiThieu => switch (dong) {
          0 => _xayDuongTruongKhoiLuongDuLieu(),
          1 => _xayDuongTruongGioiThieu(),
          3 => _xayDuongTruongChuanHoaAnh(),
          _ => null
        },
        _ => null
      };
    }
    return switch(doan) {
      0 => _xayDungManHinhLanDau(),
      1 => _xayDuongTruongGioiThieu(),
      _ => null
    };
  }

  Widget _xayDuongTruongGioiThieu() => TruongNutBam(
    khiNhan: widget.dieuKhienManHinh._khiNhanGioiThieu,
    tieuDe: widget.dieuKhienManHinh.phienBan,
    icon: Icons.help_outline
  );

  Widget _xayDuongTruongKhoiLuongDuLieu() => VbhtWidget(
    text: Vbht.trucTiep(LinhTinh.dinhDangKichThuocTep(widget.dieuKhienManHinh._khoiLuongDuLieu)),
    coChu: CoChu.nho
  );

  Widget _xayDuongTruongChuanHoaAnh() => TruongNutBam(
    khiNhan: widget.dieuKhienManHinh._khiNhanChuanHoaAnh,
    tieuDe: Vbht.trucTiep("Chuẩn hoá ảnh"),
    icon: Icons.image
  );

  Widget _xayDungTruongSach(Sach sach, bool hienThiDanhDau) {
    List<ThongTinHienThiTruongSach> dsHienThi = TruongSach.thongTinMacDinh();
    if (hienThiDanhDau) {
      dsHienThi.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.danhDau));
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.dieuKhienManHinh._khiNhanSach(sach),
      child: TruongSach(sach: sach, thongTinCanHienThi: dsHienThi)
    );
  }

  Widget _xayDungDanhDau(int stt) {
    return Row(
      children: [
        Expanded(child: _xayDungTruongSach(widget.dieuKhienManHinh.nguonDuLieu.dsDanhDau[stt], true)),
        NutBamBieuTuong(
          bieuTuong: Icons.delete_outline,
          thuocThanhDieuHuong: false,
          khiNhan: () => widget.dieuKhienManHinh._khiNhanXoaDanhDau(stt),
        )
      ],
    );
  }

  @override
  List<Widget>? widgetsCuaCaDoan(int doan) => null;

}
