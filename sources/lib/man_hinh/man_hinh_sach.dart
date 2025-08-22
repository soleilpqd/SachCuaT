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
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/models/vov.dart';
import 'package:sach_cua_t/models/vtv.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/mot_mau_giao_dien.dart';
import 'package:sach_cua_t/views/truong_bat_tat.dart';
import 'package:sach_cua_t/views/truong_hinh_anh.dart';
import 'package:sach_cua_t/views/truong_nut_bam.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

class _DieuKhienManHinhSach {

  late BuildContext context;
  DieuKhienMotMauGiaoDien<bool> dkNutLuu = DieuKhienMotMauGiaoDien<bool>(giaTri: false);
  List<String> dsNxb = [];
  _TrangThaiManHinhSoanThaoSach? phanNoiDung;

}

/// Màn hình hiển thị và chỉnh sửa thông tin sách
class ManHinhSach extends StatelessWidget with KhuonMauQuanLyManHinh {

  static const String maManHinh = "ManHinhSach";
  final _DieuKhienManHinhSach _dieuKhien = _DieuKhienManHinhSach();
  final int? maSach;
  final BoDemVbht demVbht = BoDemVbht();

  @override
  String get tenManHinh => ManHinhSach.maManHinh;

  ManHinhSach({super.key, this.maSach}) {
    CoSoDuLieu().truyVanDSNxb().then((value) => _dieuKhien.dsNxb = value);
    if (maSach == null) {
      _dieuKhien.dkNutLuu.giaTri = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _dieuKhien.context = context;
    builder(ctx, value) {
        return IconButton(
          onPressed: value ? _khiNhanLuu : null,
          icon: Icon(Icons.save, color: value ? Colors.white : Colors.grey)
        );
    }
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(maSach == null ? TK.sachMoi : TK.thongTinSach, dem: demVbht),
      khiNhanQuayLai: () => pop(),
      nutPhai: MotMauGiaoDien(dieuKhien: _dieuKhien.dkNutLuu, builder: builder),
      noiDung: _ManHinhSoanThaoSach(maSach: maSach, manHinh: this)
    );
  }

  @override
  BuildContext get context => _dieuKhien.context;

  void _khiNhanLuu() {
    _dieuKhien.phanNoiDung?._khiNhanLuu();
  }

}

class _ManHinhSoanThaoSach extends StatefulWidget {

  final int? maSach;
  final ManHinhSach manHinh;

  const _ManHinhSoanThaoSach({this.maSach, required this.manHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhSoanThaoSach();

}

class _TrangThaiManHinhSoanThaoSach extends State<_ManHinhSoanThaoSach> with TheoDoiDieuKhienCoSo {

  final DieuKhienTruongVanBan _dkTenSach = DieuKhienTruongVanBan();
  final DieuKhienTruongVanBan _dkISBN = DieuKhienTruongVanBan();
  final List<DieuKhienTruongVanBan> _dsDkTacGia = [];
  final List<DieuKhienTruongVanBan> _dsDkDichGia = [];
  final List<DieuKhienTruongVanBan> _dsDkNxb = [];
  final List<DieuKhienTruongVanBan> _dsDkViTri = [];
  final DieuKhienTruongBatTat _dkDaDocXong = DieuKhienTruongBatTat();
  final DieuKhienTruongBatTat _dkThayDoiViTriTap = DieuKhienTruongBatTat();
  final DieuKhienTruongHinhAnh _dkHinhAnh = DieuKhienTruongHinhAnh();
  DieuKhienTruongVanBan? _dkVbHienTai;

// TODO: nhãn (tag), nhiều tập
  final List<DieuKhienTruongVanBan> _dsDkNhan = [];
  int? _chuoiSach;

  @override
  void initState() {
    super.initState();
    widget.manHinh._dieuKhien.phanNoiDung = this;
    _dkISBN.themTheoDoi(this);
    _dkTenSach.themTheoDoi(this);
    _dkThayDoiViTriTap.themTheoDoi(this);
    _cauHinhLaiDauVao();
  }

  @override
  void didUpdateWidget(covariant _ManHinhSoanThaoSach oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.manHinh._dieuKhien.phanNoiDung = null;
    widget.manHinh._dieuKhien.phanNoiDung = this;
  }

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

  @override
  void dispose() {
    super.dispose();
    _dkThayDoiViTriTap.boTheoDoi(this);
    _lamSachTatCaDauVao();
    widget.manHinh._dieuKhien.phanNoiDung = null;
    _dkTenSach.dispose();
    _dkISBN.dispose();
    _dkDaDocXong.dispose();
    _dkHinhAnh.dispose();
    _dkThayDoiViTriTap.dispose();
  }

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
    // _dsDkNhan.add(DieuKhienTruongVanBan());
  }

  // TODO: goi y
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

  @override
  void setState(void Function() action) {
    DieuKhienTruongVanBan? tam = _dkVbHienTai;
    tam?.focus = false;
    super.setState(action);
    if (tam != null) {
      Future.delayed(const Duration(milliseconds: 100)).then((value) {
        tam.focus = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox spacing = SizedBox(height: 10,);
    List<Widget> children = [
      // Tra cứu lưu chiểu
      TruongNutBam(
        khiNhan: _khiNhanTraCuuLuuChieu,
        tieuDe: Vbht.tuKhoa(TK.traCuuLuuChieu, dem: widget.manHinh.demVbht),
        icon: Icons.arrow_forward
      ),
      // Đã đọc xong
      TruongBatTat(tieuDe: Vbht.tuKhoa(TK.daDocXong, dem: widget.manHinh.demVbht), trinhDieuKhien: _dkDaDocXong),
      // Hình chụp
      TruongHinhAnh(
        trinhDieuKhien: _dkHinhAnh,
        khiKhongCoMayAnh: _khiKhongCoMayAnh,
        dem: widget.manHinh.demVbht,
      ),
      spacing,
      // Tên sách
      TruongVanBan(tieuDe: Vbht.tuKhoa(TK.tenSach, dem: widget.manHinh.demVbht), dieuKhien: _dkTenSach),
      spacing,
      // Mã ISBN
      TruongVanBan(
        tieuDe: Vbht.tuKhoa(TK.isbn, dem: widget.manHinh.demVbht),
        dieuKhien: _dkISBN,
        kieuBanPhim: TextInputType.number,
        kiemSoatNhapLieu: [FilteringTextInputFormatter.digitsOnly],
        soKyTuToiDa: 13,
        xayDungNutBenPhai: (_, khaDung) => IconButton(
          onPressed: khaDung ? _khiNhatNutQuetISBN : null,
          icon: Icon(Icons.camera_alt_outlined, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
        ),
      ),
      TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.thongTinSachCoBan, dem: widget.manHinh.demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichThongTinCoBan, dem: widget.manHinh.demVbht)
      ),
      spacing
    ];
    // DS tác giả
    for (final muc in _dsDkTacGia) {
      children.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.tacGia, dem: widget.manHinh.demVbht),
          dieuKhien: muc,
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
          tieuDe: Vbht.tuKhoa(TK.dichGia, dem: widget.manHinh.demVbht),
          dieuKhien: muc,
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
          tieuDe: Vbht.tuKhoa(TK.dvPhatHanh, dem: widget.manHinh.demVbht),
          dieuKhien: muc,
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
      tieuDeChinh: Vbht.tuKhoa(TK.viTri, dem: widget.manHinh.demVbht),
      tieuDePhu: Vbht.tuKhoa(TK.giaiThichViTri, dem: widget.manHinh.demVbht)
    ));
    children.add(spacing);
    for (final muc in _dsDkViTri) {
      children.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.viTri, dem: widget.manHinh.demVbht),
          dieuKhien: muc,
          xayDungNutBenPhai: (danhDau, khaDung) => danhDau == null ? null : IconButton(
            onPressed: !khaDung ? null : () {
              _khiNhanLoaiBoDauVao(muc);
            }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
          ),
        )
      );
      children.add(spacing);
    }
    children.add(
      TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.tieuDeSachNhieuTap, dem: widget.manHinh.demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichSachNhieuTap, dem: widget.manHinh.demVbht)
      )
    );
    children.add(
      TruongBatTat(tieuDe: Vbht.tuKhoa(TK.thayDoiViTriSachNhieuTap, dem: widget.manHinh.demVbht), trinhDieuKhien: _dkThayDoiViTriTap)
    );
    children.add(
      TruongNutBam(khiNhan: _khiNhanChonTap, tieuDe: Vbht.tuKhoa(TK.chonTapSach, dem: widget.manHinh.demVbht), icon: Icons.add_circle_outline)
    );
    children.add(
      TruongNutBam(khiNhan: _khiNhanThemTapMoi, tieuDe: Vbht.tuKhoa(TK.themTapSach, dem: widget.manHinh.demVbht), icon: Icons.copy)
    );
    children.add(
      TruongNutBam(khiNhan: _khiNhanXoaTap, tieuDe: Vbht.tuKhoa(TK.xoaTap, dem: widget.manHinh.demVbht), icon: Icons.remove_circle_outline)
    );
    children.add(
      TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.tieuDeNhan, dem: widget.manHinh.demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichNhan, dem: widget.manHinh.demVbht)
      )
    );
    children.add(
      TruongNutBam(khiNhan: _khiNhanThemNhan, tieuDe: Vbht.tuKhoa(TK.themNhan, dem: widget.manHinh.demVbht), icon: Icons.add_circle_outline)
    );
    children.add(
      TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.tieuDeDanhDau, dem: widget.manHinh.demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichDanhDau, dem: widget.manHinh.demVbht)
      )
    );
    children.add(
      TruongNutBam(khiNhan: _khiNhanThemDanhDau, tieuDe: Vbht.tuKhoa(TK.themDanhDau, dem: widget.manHinh.demVbht), icon: Icons.add_circle_outline)
    );
    children.add(const SizedBox(height: 54));
    return ListView(
        padding: const EdgeInsets.all(5),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: children,
      );
  }

  void asyncSetState(void Function() action) {
    Future.delayed(const Duration(milliseconds: 1)).then((value) => setState(action));
  }

  // Xử lý tác nhân người dùng
  // @override
  // void truongVanBanThayDoiNoiDung(DieuKhienTruongVanBan muc) {
  //   print("TEXT INPUT ${muc.debugInfo}: ${muc.vanBan}");
  // }

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
        asyncSetState(() => _cauHinhLaiDauVao(nguon: muc));
      }
    }
  }

  void _khiKhongCoMayAnh(BuildContext context) {
    HopThoai.hienThiThongBao(context, noiDung: Vbht.tuKhoa(TK.khongCoMayAnh, dem: widget.manHinh.demVbht), nhanNut: Vbht.tuKhoa(TK.dong, dem: widget.manHinh.demVbht));
  }

  void _khiNhatNutQuetISBN() async {
    LinhTinh.dungNhapVanBan();
    final String? maISBN = await HeThongMay.duyNhat.quetMaISBN().onError((error, stackTrace) {
      _khiKhongCoMayAnh(context);
      return null;
    });
    if (maISBN != null) {
      _dkISBN.vanBan = maISBN;
    }
  }

  void _khiNhanTraCuuLuuChieu() {
    widget.manHinh.push(
      ManHinhWeb.maManHinh,
      ManHinhWeb(tieuDe: Vbht.tuKhoa(TK.luuChieu, dem: widget.manHinh.demVbht), url: HangSo.urlLuuChieu, khiChonSach: _khiChonSachTuLuuChieu)
    );
  }

  void _khiChonSachTuLuuChieu(Map<String, String> duLieu) {
    print("DEBUG $duLieu\n${widget.manHinh._dieuKhien.dsNxb}");
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
      for (final muc in widget.manHinh._dieuKhien.dsNxb) {
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

  void _khiThayDoiViTriTap() {
    print("GIA TRI Episode ${_dkThayDoiViTriTap.giaTri}");
  }

  void _khiNhanChonTap() {

  }

  void _khiNhanThemTapMoi() {

  }

  void _khiNhanXoaTap() {

  }

  void _khiNhanThemNhan() {

  }

  void _khiNhanThemDanhDau() {

  }

  void _khiNhanLuu() {
    _dkVbHienTai?.focus = false;
    _dkVbHienTai = null;
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
  }

  void _luuSach() {
    widget.manHinh._dieuKhien.dkNutLuu.giaTri = false;
    _luuThongTinChung();
    _luuTacGiaSach();
    _luuDichGiaSach();
    _luuDvPhatHanh();
    _luuViTri();
    _luuNhieuTap();
    _luuNhan();
    _luuDanhDau();
  }

  void _luuThongTinChung() {
    if (widget.manHinh.maSach != null) {

    } else {

    }
  }

  void _luuTacGiaSach() {

  }

  void _luuDichGiaSach() {

  }

  void _luuDvPhatHanh() {

  }

  void _luuViTri() {

  }

  void _luuNhieuTap() {

  }

  void _luuNhan() {

  }

  void _luuDanhDau() {

  }

}
