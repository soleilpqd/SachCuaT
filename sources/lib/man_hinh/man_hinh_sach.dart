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
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_web.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/models/operations/thao_tac_luu_sach.dart';
import 'package:sach_cua_t/models/operations/thao_tac_nap_sach.dart';
import 'package:sach_cua_t/models/operations/thao_tac_so_sanh_sach.dart';
import 'package:sach_cua_t/models/vtv.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/truong_bat_tat.dart';
import 'package:sach_cua_t/views/truong_hinh_anh.dart';
import 'package:sach_cua_t/views/truong_nut_bam.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

/// Điều khiển màn hình thông tin sách
class _DieuKhienManHinhSach {

  ThaoTacNapThongTinSach? thaoTacNap;
  late BuildContext context;
  /// Điều khiển nút Lưu (bên phải Top bar)
  final DieuKhienCoSo dkNutLuu = DieuKhienCoSo(khaDung: true);
  /// Điều khiển nút Quay lại (bên trái Top bar)
  final DieuKhienCoSo dkNutQuayLai = DieuKhienCoSo();
  /// Bộ đệm Vbht cho toàn màn hình
  final BoDemVbht demVbht = BoDemVbht();
  /// Hàm xử lý khi nhấn Lưu (gán bởi State của phần view nội dung)
  void Function()? khiNhanLuu;
  /// Hàm xử lý khi nhấn Quay lại (gán bởi State của phần view nội dung)
  void Function()? khiNhanQuayLai;
  /// Hàm xử lý để chuyển sang màn hình mới (gán bởi màn hình chính, gọi bởi phần view nội dung)
  void Function(String, Widget)? push;
  /// Hàm xử lý khi quay lại (gán bởi màn hình chính, gọi bởi phần view nội dung)
  void Function()? pop;

  /// Danh sách NXB có sẵn trong CSDL (dùng để xác định đơn vị phát hành đối tác khi nhập dữ liệu từ web Lưu chiểu)
  List<String> dsNxb = [];

}

/// Màn hình hiển thị và chỉnh sửa thông tin sách
class ManHinhSach extends StatelessWidget with KhuonMauQuanLyManHinh {

  static const String maManHinh = "ManHinhSach";
  /// Điều khiển chính
  final _DieuKhienManHinhSach _dieuKhien = _DieuKhienManHinhSach();
  /// Mã sách gán từ màn hình trước.
  /// Null là tạo sách mới.
  final int? maSach;

  /// KhuonMauQuanLyManHinh
  @override
  String get tenManHinh => ManHinhSach.maManHinh;

  /// Constructor
  ManHinhSach({super.key, this.maSach}) {
    CoSoDuLieu().truyVanDSNxb().then((value) => _dieuKhien.dsNxb = value);
    _dieuKhien.push = push;
    _dieuKhien.pop = pop;
    if (maSach != null) {
      Sach sach = Sach();
      sach.maSo = maSach;
      _dieuKhien.thaoTacNap = ThaoTacNapThongTinSach(sach);
    }
  }

  @override
  Widget build(BuildContext context) {
    _dieuKhien.context = context;
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(maSach == null ? TK.sachMoi : TK.thongTinSach, dem: _dieuKhien.demVbht),
      khiNhanQuayLai: _khiNhanQuayLai,
      dkNutQuayLai: _dieuKhien.dkNutQuayLai,
      nutPhai: NutBamBieuTuong(icon: Icons.save, khiNhan: _khiNhanLuu, dieuKhien: _dieuKhien.dkNutLuu),
      noiDung: _ManHinhSoanThaoSach(maSach: maSach, dkManHinh: _dieuKhien)
    );
  }

  /// KhuonMauQuanLyManHinh
  @override
  BuildContext get context => _dieuKhien.context;

  /// Khi nhấn lưu
  void _khiNhanLuu() {
    _dieuKhien.khiNhanLuu?.call();
  }

  /// Khi nhấn quay lại
  void _khiNhanQuayLai() {
    _dieuKhien.khiNhanQuayLai?.call();
  }

}

/// Phần nội dung màn hình sách (phần dưới Top bar)
class _ManHinhSoanThaoSach extends StatefulWidget {

  final int? maSach;
  final _DieuKhienManHinhSach dkManHinh;

  /// Constructor
  const _ManHinhSoanThaoSach({this.maSach, required this.dkManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhSoanThaoSach();

}

/// Quản lý State của phần màn hình nội dung sách
class _TrangThaiManHinhSoanThaoSach extends State<_ManHinhSoanThaoSach> with TheoDoiDieuKhienCoSo {

  final DieuKhienCoSo _dkLuuChieu = DieuKhienCoSo();
  final DieuKhienTruongBatTat _dkDaDocXong = DieuKhienTruongBatTat();
  final DieuKhienTruongHinhAnh _dkHinhAnh = DieuKhienTruongHinhAnh();
  final DieuKhienTruongVanBan _dkTenSach = DieuKhienTruongVanBan();
  final DieuKhienTruongVanBan _dkISBN = DieuKhienTruongVanBan();
  final List<DieuKhienTruongVanBan> _dsDkTacGia = [];
  final List<DieuKhienTruongVanBan> _dsDkDichGia = [];
  final List<DieuKhienTruongVanBan> _dsDkNxb = [];
  final List<DieuKhienTruongVanBan> _dsDkViTri = [];
  final DieuKhienTruongBatTat _dkThayDoiViTriTap = DieuKhienTruongBatTat();
  final DieuKhienCoSo _dkChonTapSach = DieuKhienCoSo();
  final DieuKhienCoSo _dkNhanBanDeThemTapSach = DieuKhienCoSo();
  final DieuKhienCoSo _dkXoaTapSach = DieuKhienCoSo();
  final DieuKhienCoSo _dkThemNhan = DieuKhienCoSo();
  final DieuKhienCoSo _dkThemDanhDau = DieuKhienCoSo();

  DieuKhienTruongVanBan? _dkVbHienTai;
  void Function()? _choKetThucSoanThao;

// TODO: nhãn (tag), nhiều tập
  final List<DieuKhienTruongVanBan> _dsDkNhan = [];
  int? _chuoiSach;

  @override
  void initState() {
    super.initState();
    widget.dkManHinh.khiNhanLuu = _khiNhanLuu;
    widget.dkManHinh.khiNhanQuayLai = _khiNhanQuayLai;
    _dkISBN.themTheoDoi(this);
    _dkTenSach.themTheoDoi(this);
    _dkThayDoiViTriTap.themTheoDoi(this);

    if (widget.maSach != null) {
      widget.dkManHinh.thaoTacNap?.napThongTin().then((value) {
      if (value) {
        setState(() {
          _khoiTaoManHinhTheoThongTinSach();
        });
      } else {
        HopThoai.hienThiThongBao(
          context,
          noiDung: Vbht.tuKhoa(TK.sachKhongTonTai, dem: widget.dkManHinh.demVbht),
          nhanNut: Vbht.tuKhoa(TK.dong, dem: widget.dkManHinh.demVbht),
          khiDong: (_) => widget.dkManHinh.pop?.call()
        );
      }
    });
    } else {
      _cauHinhLaiDauVao();
    }
  }

  @override
  void didUpdateWidget(covariant _ManHinhSoanThaoSach oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.dkManHinh.khiNhanLuu = null;
    oldWidget.dkManHinh.khiNhanQuayLai = null;
    widget.dkManHinh.khiNhanLuu = _khiNhanLuu;
    widget.dkManHinh.khiNhanQuayLai = _khiNhanQuayLai;
  }

  /// Làm sạch tất cả đầu vào: xoá các trường văn bản, hình ảnh
  void _lamSachTatCaDauVao() {
    _dkVbHienTai = null;
    _dkDaDocXong.giaTri = false;
    _dkHinhAnh.hinhAnh = null;
    _dkTenSach.thongBaoLoi = null;
    _dkISBN.thongBaoLoi = null;
    _lamSachDSDauvao(_dsDkTacGia, tatCa: true);
    _lamSachDSDauvao(_dsDkTacGia, tatCa: true);
    _lamSachDSDauvao(_dsDkDichGia, tatCa: true);
    _lamSachDSDauvao(_dsDkNxb, tatCa: true);
    _lamSachDSDauvao(_dsDkViTri, tatCa: true);
  }

  /// Destructor
  @override
  void dispose() {
    super.dispose();
    _dkThayDoiViTriTap.boTheoDoi(this);
    _lamSachTatCaDauVao();
    _dkLuuChieu.dispose();
    _dkTenSach.dispose();
    _dkISBN.dispose();
    _dkDaDocXong.dispose();
    _dkHinhAnh.dispose();
    _dkThayDoiViTriTap.dispose();
    widget.dkManHinh.khiNhanLuu = null;
    widget.dkManHinh.khiNhanQuayLai = null;
    _dkChonTapSach.dispose();
    _dkNhanBanDeThemTapSach.dispose();
    _dkXoaTapSach.dispose();
    _dkThemNhan.dispose();
    _dkThemDanhDau.dispose();
  }

  /// Cấu hình lại nhóm các trường văn bản có chứa [nguon]
  /// hoặc tất cả các nhóm nếu [nguon] là `null`
  void _cauHinhLaiDauVao({DieuKhienTruongVanBan? nguon}) {
    if (nguon == null || _dsDkTacGia.contains(nguon)) {
      _lamSachDSDauvao(_dsDkTacGia, tatCa: false, debugInfo: "TG");
    }
    if (nguon == null || _dsDkDichGia.contains(nguon)) {
      _lamSachDSDauvao(_dsDkDichGia, tatCa: false, debugInfo: "DG");
    }
    if (nguon == null || _dsDkNxb.contains(nguon)) {
      _lamSachDSDauvao(_dsDkNxb, tatCa: false, debugInfo: "NXB");
    }
    if (nguon == null || _dsDkViTri.contains(nguon)) {
      _lamSachDSDauvao(_dsDkViTri, tatCa: false, khongLap: false, debugInfo: "VT");
    }
    // TODO: nhãn, đánh dấu
  }

  // TODO: goi y
  /// Làm sạch trường văn bản:
  /// Loại bỏ các điều khiển văn bản trống ([tatCa] = false) hoặc tất cả các điều khiển ([tatCa] = true).
  /// `[khongLap] = true` thì loại bỏ các điều khiển trùng lặp trong dánh sách.
  void _lamSachDSDauvao(List<DieuKhienTruongVanBan> danhSach, {required bool tatCa, bool khongLap = true, String debugInfo = ""}) {
    List<DieuKhienTruongVanBan> boDem = [];
    DieuKhienTruongVanBan? dkRong;
    int dem = 0;
    for (final muc in danhSach) {
      muc.thongBaoLoi = null;
      if (tatCa) {
        if (muc == _dkVbHienTai) {
          _dkVbHienTai = null;
        }
        muc.dispose();
      } else {
        String vanBan = muc.vanBan.trim();
        if (vanBan.isEmpty) {
          if (dkRong == null) {
            dkRong = muc;
          } else {
            if (muc == _dkVbHienTai) {
              _dkVbHienTai = null;
            }
            muc.dispose();
          }
        } else {
          List<String> cacDoan = LinhTinh.phanChiaTextTheoKyTuDacBiet(vanBan);
          if (cacDoan.length > 1) {
            muc.vanBan = cacDoan.first;
          } else {
            muc.vanBan = vanBan;
          }
          muc.trangThaiNutBenPhai = 0;
          if (khongLap && boDem.indexWhere((mucDem) => mucDem.vanBan == muc.vanBan) >= 0) {
            if (dkRong == null) {
              dkRong = muc;
            } else {
              if (muc == _dkVbHienTai) {
                _dkVbHienTai = null;
              }
              muc.dispose();
            }
          } else {
            muc.debugInfo = "$debugInfo $dem";
            boDem.add(muc);
            dem += 1;
          }
          if (cacDoan.length > 1) {
            for (int so = 1; so < cacDoan.length; so += 1) {
              String doan = cacDoan[so];
              if (khongLap && boDem.indexWhere((mucDem) => mucDem.vanBan == doan) >= 0) {
                // Do nothing
              } else {
                DieuKhienTruongVanBan dkDoan = DieuKhienTruongVanBan();
                dkDoan.debugInfo = "$debugInfo $dem";
                dkDoan.vanBan = doan;
                dkDoan.trangThaiNutBenPhai = 0;
                boDem.add(dkDoan);
                dem += 1;
              }
            }
          }
        }
      }
    }
    danhSach.clear();
    if (!tatCa) {
      if (dkRong == null) {
        dkRong = DieuKhienTruongVanBan();
        dkRong.themTheoDoi(this);
        dkRong.debugInfo = "$debugInfo $dem";
      }
      dkRong.vanBan = "";
      dkRong.trangThaiNutBenPhai = null;
      boDem.add(dkRong);
      danhSach.addAll(boDem);
    }
  }

  /// Khởi tạo màn hình theo thông tin sách (chế độ sửa)
  void _khoiTaoManHinhTheoThongTinSach() {
    Sach sach = widget.dkManHinh.thaoTacNap!.thongTinSach;
    _dkDaDocXong.giaTri = sach.daHoanThanh;
    _dkHinhAnh.hinhAnh = sach.hinhAnh;
    _dkTenSach.vanBan = sach.ten;
    _dkISBN.vanBan = sach.isbn;

    int dem = 0;
    for (final muc in sach.tacGia) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan();
      dkVb.debugInfo = "TG $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      _dsDkTacGia.add(dkVb);
      dem += 1;
    }
    DieuKhienTruongVanBan dkRong = DieuKhienTruongVanBan();
    dkRong.debugInfo = "TG $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    _dsDkTacGia.add(dkRong);

    dem = 0;
    for (final muc in sach.dichGia) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan();
      dkVb.debugInfo = "DG $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      _dsDkDichGia.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan();
    dkRong.debugInfo = "DG $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    _dsDkDichGia.add(dkRong);

    dem = 0;
    for (final muc in sach.nhaXuatBan) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan();
      dkVb.debugInfo = "NXB $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      _dsDkNxb.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan();
    dkRong.debugInfo = "NXB $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    _dsDkNxb.add(dkRong);

    dem = 0;
    for (final muc in sach.viTri) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan();
      dkVb.debugInfo = "VT $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      _dsDkViTri.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan();
    dkRong.debugInfo = "VT $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    _dsDkViTri.add(dkRong);
  }

  /// Khi nhấn loại bỏ trường văn bản
  void _khiNhanLoaiBoDauVao(DieuKhienTruongVanBan muc) {
    setState(() {
      if (_dsDkTacGia.contains(muc)) {
        _dsDkTacGia.remove(muc);
        muc.dispose();
      } else if (_dsDkDichGia.contains(muc)) {
        _dsDkDichGia.remove(muc);
        muc.dispose();
      } else if (_dsDkNxb.contains(muc)) {
        _dsDkNxb.remove(muc);
        muc.dispose();
      } else if (_dsDkViTri.contains(muc)) {
        _dsDkViTri.remove(muc);
        muc.dispose();
      }
    });
  }

  /// Khoá (Disable) toàn màn hình
  void _khoaManHinh() {
    List<DieuKhienCoSo> tatCaDieuKhien = [
      _dkLuuChieu,
      _dkTenSach,
      _dkISBN,
      _dkHinhAnh,
      _dkDaDocXong,
      _dkThayDoiViTriTap,
      _dkChonTapSach,
      _dkNhanBanDeThemTapSach,
      _dkXoaTapSach,
      _dkThemNhan,
      _dkThemDanhDau,
      widget.dkManHinh.dkNutLuu,
      widget.dkManHinh.dkNutQuayLai
    ];
    tatCaDieuKhien.addAll(_dsDkTacGia);
    tatCaDieuKhien.addAll(_dsDkDichGia);
    tatCaDieuKhien.addAll(_dsDkNxb);
    tatCaDieuKhien.addAll(_dsDkViTri);
    // TODO: nhan, danh dau
    for (final muc in tatCaDieuKhien) {
      muc.khaDung = false;
    }
  }

  @override
  void setState(void Function() action) {
    DieuKhienTruongVanBan? tam = _dkVbHienTai;
    tam?.focus = false;
    super.setState(action);
    // Khôi phục lại trường văn bản đang focus trước khi refresh lại state
    if (tam != null) {
      Future.delayed(const Duration(milliseconds: 100)).then((value) {
        tam.focus = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.maSach != null && !widget.dkManHinh.thaoTacNap!.daXong) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    }
    const SizedBox spacing = SizedBox(height: 10,);
    List<Widget> children = [];
    if (widget.maSach == null) {
      children.add(
        // Tra cứu lưu chiểu
        TruongNutBam(
          khiNhan: _khiNhanTraCuuLuuChieu,
          tieuDe: Vbht.tuKhoa(TK.traCuuLuuChieu, dem: widget.dkManHinh.demVbht),
          icon: Icons.arrow_forward,
          dieuKhien: _dkLuuChieu,
        )
      );
    }
    children.addAll([
      // Đã đọc xong
      TruongBatTat(tieuDe: Vbht.tuKhoa(TK.daDocXong, dem: widget.dkManHinh.demVbht), trinhDieuKhien: _dkDaDocXong),
      // Hình chụp
      TruongHinhAnh(
        trinhDieuKhien: _dkHinhAnh,
        khiKhongCoMayAnh: _khiKhongCoMayAnh,
        dem: widget.dkManHinh.demVbht,
      ),
      spacing,
      // Tên sách
      TruongVanBan(tieuDe: Vbht.tuKhoa(TK.tenSach, dem: widget.dkManHinh.demVbht), trinhDieuKhien: _dkTenSach),
      spacing,
      // Mã ISBN
      TruongVanBan(
        tieuDe: Vbht.tuKhoa(TK.isbn, dem: widget.dkManHinh.demVbht),
        trinhDieuKhien: _dkISBN,
        kieuBanPhim: TextInputType.number,
        kiemSoatNhapLieu: [FilteringTextInputFormatter.digitsOnly],
        soKyTuToiDa: 13,
        xayDungNutBenPhai: (_, khaDung) => IconButton(
          onPressed: khaDung ? _khiNhanNutQuetISBN : null,
          icon: Icon(Icons.camera_alt_outlined, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
        ),
      ),
      TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.thongTinSachCoBan, dem: widget.dkManHinh.demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichThongTinCoBan, dem: widget.dkManHinh.demVbht)
      ),
      spacing
    ]);
    // DS tác giả
    for (final muc in _dsDkTacGia) {
      children.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.tacGia, dem: widget.dkManHinh.demVbht),
          trinhDieuKhien: muc,
          xayDungNutBenPhai: (danhDau, khaDung) => danhDau == null ? null : IconButton(
            onPressed: !khaDung ? null : () {
              _khiNhanLoaiBoDauVao(muc);
            }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
          ),
        )
      );
      children.add(spacing);
    }
    // DS dịch giả
    for (final muc in _dsDkDichGia) {
      children.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.dichGia, dem: widget.dkManHinh.demVbht),
          trinhDieuKhien: muc,
          xayDungNutBenPhai: (danhDau, khaDung) => danhDau == null ? null : IconButton(
            onPressed: !khaDung ? null : () {
              _khiNhanLoaiBoDauVao(muc);
            }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
          ),
        )
      );
      children.add(spacing);
    }
    // DS đơn vị phát hành
    for (final muc in _dsDkNxb) {
      children.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.dvPhatHanh, dem: widget.dkManHinh.demVbht),
          trinhDieuKhien: muc,
          xayDungNutBenPhai: (danhDau, khaDung) => danhDau == null ? null : IconButton(
            onPressed: !khaDung ? null : () {
              _khiNhanLoaiBoDauVao(muc);
            }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
          ),
        )
      );
      children.add(spacing);
    }
    // DS Vị trí
    children.add(TruongTieuDe(
      tieuDeChinh: Vbht.tuKhoa(TK.viTri, dem: widget.dkManHinh.demVbht),
      tieuDePhu: Vbht.tuKhoa(TK.giaiThichViTri, dem: widget.dkManHinh.demVbht)
    ));
    children.add(spacing);
    for (final muc in _dsDkViTri) {
      children.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.viTri, dem: widget.dkManHinh.demVbht),
          trinhDieuKhien: muc,
          xayDungNutBenPhai: (danhDau, khaDung) => danhDau == null ? null : IconButton(
            onPressed: !khaDung ? null : () {
              _khiNhanLoaiBoDauVao(muc);
            }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
          ),
        )
      );
      children.add(spacing);
    }
    // children.add(
    //   TruongTieuDe(
    //     tieuDeChinh: Vbht.tuKhoa(TK.tieuDeSachNhieuTap, dem: widget.dkManHinh.demVbht),
    //     tieuDePhu: Vbht.tuKhoa(TK.giaiThichSachNhieuTap, dem: widget.dkManHinh.demVbht)
    //   )
    // );
    // children.add(
    //   TruongBatTat(
    //     tieuDe: Vbht.tuKhoa(TK.thayDoiViTriSachNhieuTap, dem: widget.dkManHinh.demVbht),
    //     trinhDieuKhien: _dkThayDoiViTriTap
    //   )
    // );
    // children.add(
    //   TruongNutBam(
    //     khiNhan: _khiNhanChonTap,
    //     tieuDe: Vbht.tuKhoa(TK.chonTapSach, dem: widget.dkManHinh.demVbht),
    //     icon: Icons.add_circle_outline,
    //     dieuKhien: _dkChonTapSach
    //   )
    // );
    // children.add(
    //   TruongNutBam(
    //     khiNhan: _khiNhanThemTapMoi,
    //     tieuDe: Vbht.tuKhoa(TK.themTapSach, dem: widget.dkManHinh.demVbht),
    //     icon: Icons.copy,
    //     dieuKhien: _dkNhanBanDeThemTapSach
    //   )
    // );
    // children.add(
    //   TruongNutBam(
    //     khiNhan: _khiNhanXoaTap,
    //     tieuDe: Vbht.tuKhoa(TK.xoaTap, dem: widget.dkManHinh.demVbht),
    //     icon: Icons.remove_circle_outline,
    //     dieuKhien: _dkXoaTapSach
    //   )
    // );
    // children.add(
    //   TruongTieuDe(
    //     tieuDeChinh: Vbht.tuKhoa(TK.tieuDeNhan, dem: widget.dkManHinh.demVbht),
    //     tieuDePhu: Vbht.tuKhoa(TK.giaiThichNhan, dem: widget.dkManHinh.demVbht)
    //   )
    // );
    // children.add(
    //   TruongNutBam(
    //     khiNhan: _khiNhanThemNhan,
    //     tieuDe: Vbht.tuKhoa(TK.themNhan, dem: widget.dkManHinh.demVbht),
    //     icon: Icons.add_circle_outline,
    //     dieuKhien: _dkThemNhan
    //   )
    // );
    // children.add(
    //   TruongTieuDe(
    //     tieuDeChinh: Vbht.tuKhoa(TK.tieuDeDanhDau, dem: widget.dkManHinh.demVbht),
    //     tieuDePhu: Vbht.tuKhoa(TK.giaiThichDanhDau, dem: widget.dkManHinh.demVbht)
    //   )
    // );
    // children.add(
    //   TruongNutBam(
    //     khiNhan: _khiNhanThemDanhDau,
    //     tieuDe: Vbht.tuKhoa(TK.themDanhDau, dem: widget.dkManHinh.demVbht),
    //     icon: Icons.add_circle_outline,
    //     dieuKhien: _dkThemDanhDau
    //   )
    // );
    children.add(const SizedBox(height: 54));
    return ListView(
        padding: const EdgeInsets.all(5),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: children,
      );
  }

  /// Gọi SetState không đồng bộ
  /// (gọi từ các hàm listen ChangeNotif)
  void asyncSetState(void Function() action) {
    Future.delayed(const Duration(milliseconds: 1)).then((value) => setState(action));
  }

  /// Dừng nhập văn bản
  /// Delay 1 khoảng để đảm bảo xử lý event dừng
  void asyncDungNhapVanBan(void Function() action) {
    _choKetThucSoanThao = null;
    if (_dkVbHienTai != null)  {
      _choKetThucSoanThao = action;
      _dkVbHienTai?.focus = false;
      _dkVbHienTai = null;
    } else {
      action.call();
    }
  }

  /// Điều khiển cơ sở thay đổi thuộc tính
  /// (`mixin TheoDoiDieuKhienCoSo`)
  @override
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {
    super.dieuKhienCoSoThayDoiThuocTinh(nguon, cacGiaTri);
    if (nguon == _dkThayDoiViTriTap) {
      if (cacGiaTri.keys.contains(ThuocTinhTruongBatTat.giaTri.name)) {
        _khiThayDoiViTriTap();
      }
    }
    if (cacGiaTri.keys.contains(ThuocTinhTruongVanBan.focus.name)) {
      truongVanBanThayDoiFocus(nguon as DieuKhienTruongVanBan);
    }
  }

  /// Trường văn bản thay đổi focus
  void truongVanBanThayDoiFocus(DieuKhienTruongVanBan muc) {
    if (!muc.focus && _dkVbHienTai == muc) {
      _dkVbHienTai = null;
    } else if (muc.focus) {
      _dkVbHienTai = muc;
    }
    if (!muc.focus) {
      muc.vanBan = muc.vanBan.trim();
      if (muc.vanBan.isNotEmpty) {
        muc.thongBaoLoi = null;
      }
      bool canThemOTrong = _dsDkTacGia.contains(muc) || _dsDkDichGia.contains(muc) || _dsDkNxb.contains(muc) || _dsDkViTri.contains(muc);
      // print("TRANG THAI NHAP TEN SACH ${muc.focus} $canThemOTrong");
      if (canThemOTrong) {
        // Hàm hiện tại nằm trong notifier của `DieuKhienTruongVanBan`.
        // Delay ra để thành 1 xử lý riêng biệt.
        void Function()? action;
        if (_choKetThucSoanThao != null) {
          action = _choKetThucSoanThao;
          _choKetThucSoanThao = null;
        }
        asyncSetState(() {
          _cauHinhLaiDauVao(nguon: muc);
          action?.call();
        });
      }
    }
    if (_choKetThucSoanThao != null) {
      _choKetThucSoanThao?.call();
      _choKetThucSoanThao = null;
    }
  }

  /// Khi không có máy ảnh
  void _khiKhongCoMayAnh(BuildContext context) {
    HopThoai.hienThiThongBao(
      context,
      noiDung: Vbht.tuKhoa(TK.khongCoMayAnh, dem: widget.dkManHinh.demVbht),
      nhanNut: Vbht.tuKhoa(TK.dong, dem: widget.dkManHinh.demVbht)
    );
  }

  /// Khi nhấn nút quét ISBN
  void _khiNhanNutQuetISBN() async {
    LinhTinh.dungNhapVanBan();
    final String? maISBN = await HeThongMay.duyNhat.quetMaISBN().onError((error, stackTrace) {
      _khiKhongCoMayAnh(context);
      return null;
    });
    if (maISBN != null) {
      _dkISBN.vanBan = maISBN;
    }
  }

  /// Khi nhấn nút Tra cứu lưu chiểu
  void _khiNhanTraCuuLuuChieu() {
    widget.dkManHinh.push?.call(
      ManHinhWeb.maManHinh,
      ManHinhWeb(tieuDe: Vbht.tuKhoa(TK.luuChieu, dem: widget.dkManHinh.demVbht), url: HangSo.urlLuuChieu, khiChonSach: _khiChonSachTuLuuChieu)
    );
  }

  /// Khi chọn sách từ lưu chiểu
  void _khiChonSachTuLuuChieu(Map<String, String> duLieu) {
    // print("DEBUG $duLieu\n${widget.dkManHinh.dsNxb}");
    String isbn = duLieu["ISBN"] ?? "";
    String ten = duLieu["ten"] ?? "";
    String tacGia = duLieu["TG"] ?? "";
    String nxb = duLieu["NXB"] ?? "";
    String doiTac = (duLieu["DT"] ?? "").toUpperCase();
    setState(() {
      _lamSachTatCaDauVao();
      _dkHinhAnh.hinhAnh = null;
      _dkISBN.vanBan = isbn;
      _dkTenSach.vanBan = ten;
      DieuKhienTruongVanBan dkTg = DieuKhienTruongVanBan();
      dkTg.vanBan = tacGia;
      _dsDkTacGia.add(dkTg);
      DieuKhienTruongVanBan dkNxb = DieuKhienTruongVanBan();
      dkNxb.vanBan = nxb;
      _dsDkNxb.add(dkNxb);
      for (final muc in widget.dkManHinh.dsNxb) {
        if (muc != nxb && doiTac.contains(muc.toUpperCase())) {
          dkNxb = DieuKhienTruongVanBan();
          dkNxb.vanBan = muc;
          _dsDkNxb.add(dkNxb);
          break;
        }
      }
      _cauHinhLaiDauVao();
    });
  }

  /// Khi thay đổi vị trí tập (bật tắt checkbox vị trí tập)
  void _khiThayDoiViTriTap() {
    print("GIA TRI Episode ${_dkThayDoiViTriTap.giaTri}");
  }

  /// Khi nhấn chọn tập
  void _khiNhanChonTap() {

  }

  /// Khi nhấn nhân bản thành tập mới
  void _khiNhanThemTapMoi() {

  }

  /// Khi nhấn xoá tập
  void _khiNhanXoaTap() {

  }

  /// Khi nhấn thêm nhãn
  void _khiNhanThemNhan() {

  }

  /// Khi nhấn thêm đánh dấu
  void _khiNhanThemDanhDau() {

  }

  /// Khi nhấn quay lại
  void _khiNhanQuayLai() {
    if (widget.dkManHinh.thaoTacNap?.thongTinSach != null) {
      final ThaoTacSoSanhSach soSanh = ThaoTacSoSanhSach(
        thongTin1: widget.dkManHinh.thaoTacNap!.thongTinSach,
        thongTin2: _thongTinSachTuGiaoDien()
      );
      if (!soSanh.soSanh()) {
        HopThoai.hienThiThongBaoNhieuNut(
          context,
          noiDung: Vbht.tuKhoa(TK.xacNhanLuu, dem: widget.dkManHinh.demVbht),
          nhanCacNut: [
            Vbht.tuKhoa(TK.luu, dem: widget.dkManHinh.demVbht),
            Vbht.tuKhoa(TK.dong, dem: widget.dkManHinh.demVbht)
          ],
          khiDong: (ctx, stt, _) {
            if (stt == 0) {
              _khiNhanLuu();
            } else {
              widget.dkManHinh.pop?.call();
            }
        });
        return;
      }
    }
    widget.dkManHinh.pop?.call();
  }

  /// Khi nhấn lưu
  void _khiNhanLuu() {
    asyncDungNhapVanBan(() {
      int coTheLuu = 0;
      if (_dkTenSach.vanBan.isEmpty) {
        _dkTenSach.thongBaoLoi = Vbht.tuKhoa(TK.thieuThongTin);
        coTheLuu = 1;
      } else {
        _dkTenSach.thongBaoLoi = null;
      }
      if (_dkISBN.vanBan.isEmpty) {
        _dkISBN.thongBaoLoi = Vbht.tuKhoa(TK.thieuThongTin);
        coTheLuu = 1;
      } else {
        _dkISBN.thongBaoLoi = null;
      }
      if (_dkTenSach.vanBan.isEmpty && _dkISBN.vanBan.isEmpty) {
        coTheLuu = 2;
      }
      for (final muc in _dsDkViTri) {
        muc.thongBaoLoi = null;
      }
      if (_dsDkViTri.length == 1 && _dsDkViTri.first.vanBan.isEmpty) {
        _dsDkViTri.first.thongBaoLoi = Vbht.tuKhoa(TK.thieuThongTin);
        if (coTheLuu != 2) {
          coTheLuu = 1;
        }
      }
      switch (coTheLuu) {
        case 1:
          HopThoai.hienThiThongBaoNhieuNut(
            context,
            noiDung: Vbht.tuKhoa(TK.loiLuuSach),
            nhanCacNut: [Vbht.tuKhoa(TK.cuLuu), Vbht.tuKhoa(TK.dong)],
            khiDong: (ctx, nut, tieuDe) {
              if (nut == 0) {
                _luuSach();
              }
            }
          );
        case 2:
          HopThoai.hienThiThongBao(context, noiDung: Vbht.tuKhoa(TK.loiLuuSach), nhanNut: Vbht.tuKhoa(TK.dong));
        default:
          _luuSach();
      }
    });
  }

  Sach _thongTinSachTuGiaoDien() {
    final Sach thongTinSach = Sach();
    thongTinSach.maSo = widget.maSach;
    thongTinSach.ten = _dkTenSach.vanBan;
    thongTinSach.isbn = _dkISBN.vanBan;
    thongTinSach.daHoanThanh = _dkDaDocXong.giaTri;
    thongTinSach.hinhAnh = _dkHinhAnh.hinhAnh;
    thongTinSach.tacGia = _dsDkTacGia.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.dichGia = _dsDkDichGia.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.nhaXuatBan = _dsDkNxb.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.viTri = _dsDkViTri.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    return thongTinSach;
  }

  /// Tiến hành lưu thông tin vào CSDL
  void _luuSach() {
    _khoaManHinh();
    final Sach thongTinSach = _thongTinSachTuGiaoDien();
    // TODO: nhan, danh dau, nhieu tap
    final ThaoTacLuuThongTinSach thaoTac = ThaoTacLuuThongTinSach(thongTinSach);
    thaoTac.luuThongTin().then((value) => widget.dkManHinh.pop?.call());
  }

}
