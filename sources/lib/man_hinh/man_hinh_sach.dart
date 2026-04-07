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
import 'package:man_hinh_ung_dung/luong_man_hinh.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tim_kiem.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_web.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/dulieu.dart';
import 'package:sach_cua_t/models/goiycsdl.dart';
import 'package:sach_cua_t/models/goiynhan.dart';
import 'package:sach_cua_t/models/luutrucauhinh.dart';
import 'package:sach_cua_t/models/native.dart';
import 'package:sach_cua_t/models/operations/thao_tac_luu_sach.dart';
import 'package:sach_cua_t/models/operations/thao_tac_nap_sach.dart';
import 'package:sach_cua_t/models/operations/thao_tac_so_sanh_sach.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/danh_sach_hien_thi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/nut_bam_tieu_de.dart';
import 'package:sach_cua_t/views/truong_bat_tat.dart';
import 'package:sach_cua_t/views/truong_hinh_anh.dart';
import 'package:sach_cua_t/views/truong_nut_bam.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/views/truong_sach.dart';
import 'package:sach_cua_t/views/truong_tieu_de.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Phân đoạn màn hình Sách
enum _PhanDoanManHinhSach {
  /// Chung (ảnh, tên)
  chung,
  /// Cơ bản (tác giả, dịch giả, nxb)
  coBan,
  /// Vị trí
  viTri,
  /// Đánh dấu
  danhDau,
  /// Nhãn
  nhan,
  /// Nhiều tập
  nhieuTap,
  /// Chân trang
  chanTrang;

  /// Khởi tạo từ giá trị thô [tho]
  static _PhanDoanManHinhSach? khoiTao(int tho) {
    return switch (tho) {
      0 => chung,
      1 => coBan,
      2 => viTri,
      3 => danhDau,
      4 => nhan,
      5 => nhieuTap,
      6 => chanTrang,
      _ => null,
    };
  }

  static int tongSo() => values.length;

}

/// Điều khiển màn hình hiển thị và chỉnh sửa thông tin sách
class DieuKhienManHinhSach extends DieuKhienManHinh with TheoDoiDieuKhienCoSo {

  /// Mã sách gán từ màn hình trước.
  /// Null là tạo sách mới.
  final int? maSach;
  final bool chiDoc;
  /// Bộ đệm Vbht cho toàn màn hình
  final BoDemVbht _demVbht = BoDemVbht();
  /// Điều khiển nút Lưu (bên phải Top bar)
  final DieuKhienCoSo _dkNutLuu = DieuKhienCoSo(khaDung: true);
  /// Điều khiển nút Quay lại (bên trái Top bar)
  final DieuKhienCoSo _dkNutQuayLai = DieuKhienCoSo();
  /// Công cụ nạp thông tin sách từ CSDL
  ThaoTacNapThongTinSach? _thaoTacNap;
  final DieuKhienCoSo _dkLuuChieu = DieuKhienCoSo();
  final DieuKhienCoSo _dkDkXuatBan = DieuKhienCoSo();
  final DieuKhienTruongBatTat _dkDaDocXong = DieuKhienTruongBatTat();
  final DieuKhienTruongHinhAnh _dkHinhAnh = DieuKhienTruongHinhAnh();
  final DieuKhienTruongVanBan _dkTenSach = DieuKhienTruongVanBan(goiYNoiDung: GoiYCSDL(bang: CoSoDuLieu.BANG_SACH));
  final DieuKhienTruongVanBan _dkISBN = DieuKhienTruongVanBan();
  final List<DieuKhienTruongVanBan> _dsDkTacGia = [];
  final List<DieuKhienTruongVanBan> _dsDkDichGia = [];
  final List<DieuKhienTruongVanBan> _dsDkNxb = [];
  final List<DieuKhienTruongVanBan> _dsDkViTri = [];
  final List<DieuKhienTruongVanBan> _dsDkDanhDau = [];
  final DieuKhienCoSo _dkSuaTap = DieuKhienCoSo();
  final DieuKhienTruongBatTat _dkHienThiDSTapDayDu = DieuKhienTruongBatTat();
  final DieuKhienTruongVanBan _dkGhiChuTap = DieuKhienTruongVanBan();
  final DieuKhienTruongVanBan _dkSoTap = DieuKhienTruongVanBan();
  final List<DieuKhienTruongVanBan> _dsDkNhan = [];

  final GoiYCSDL _goiYTg = GoiYCSDL(bang: CoSoDuLieu.BANG_TAC_GIA);
  final GoiYCSDL _goiYDg = GoiYCSDL(bang: CoSoDuLieu.BANG_DICH_GIA);
  final GoiYCSDL _goiYNxb = GoiYCSDL(bang: CoSoDuLieu.BANG_NXB);
  final GoiYCSDL _goiYViTri = GoiYCSDL(bang: CoSoDuLieu.BANG_VI_TRI);
  final GoiYCSDL _goiYTenNhan = GoiYCSDL(bang: CoSoDuLieu.BANG_NHAN);
  final GoiYNhan _goiYGiaTriNhan = GoiYNhan();

  DieuKhienTruongVanBan? _dkVbHienTai;
  void Function()? _choKetThucSoanThao;

  List<String> _dsNhanLuonHien = [];
  List<Sach> _dsCacTap = [Sach()];
  List<int> _tapConThieu = [];

  /// Danh sách NXB có sẵn trong CSDL (dùng để xác định đơn vị phát hành đối tác khi nhập dữ liệu từ web Lưu chiểu)
  List<String> _dsNxb = [];

  // --- Vòng đời

  /// Constructor
  DieuKhienManHinhSach({this.maSach, this.chiDoc = false}) {
    widgetCuaManHinh = _ManHinhSach(dkMh: this);
    CoSoDuLieu().truyVanDSNxb().then((value) => _dsNxb = value);
    LuuTruCauHinh().layHienThiDSTapDayDu().then((value) => _dkHienThiDSTapDayDu.giaTri = value ?? false);
    if (maSach != null) {
      Sach sach = Sach();
      sach.maSo = maSach;
      _thaoTacNap = ThaoTacNapThongTinSach(sach);
      CoSoDuLieu().luuVuaXem(CoSoDuLieu.BANG_SACH, maSach!);
    }
    _dkISBN.themTheoDoi(this);
    _dkTenSach.themTheoDoi(this);
    _dkGhiChuTap.themTheoDoi(this);
    _dkSoTap.themTheoDoi(this);
    _dkHienThiDSTapDayDu.themTheoDoi(this);
    _goiYGiaTriNhan.layTenNhan = () {
      if (_dkVbHienTai != null && _dsDkNhan.contains(_dkVbHienTai)) {
        return _dkVbHienTai!.vbTieuDe;
      }
      return "";
    };

  }

  @override
  void manHinhDuocThemVaoLuong() {
    super.manHinhDuocThemVaoLuong();
    _khoiTaoDuLieu();
  }

  /// Dispose
  @override
  void manHinhBiLoaiBoKhoiLuong() {
    super.manHinhBiLoaiBoKhoiLuong();
    _lamSachTatCaDauVao();
    _dkLuuChieu.dispose();
    _dkDkXuatBan.dispose();
    _dkSuaTap.dispose();
    _dkTenSach.dispose();
    _dkISBN.dispose();
    _dkDaDocXong.dispose();
    _dkHinhAnh.dispose();
    _dkGhiChuTap.dispose();
    _dkSoTap.dispose();
    _dkHienThiDSTapDayDu.dispose();
    _goiYGiaTriNhan.dispose();
  }

  // --- UI

  @override
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {
    super.dieuKhienCoSoThayDoiThuocTinh(nguon, cacGiaTri);
    if (cacGiaTri.keys.contains(ThuocTinhTruongVanBan.trangThaiNhap.name)) {
      _truongVanBanThayDoiFocus(nguon as DieuKhienTruongVanBan);
    }
    if (nguon == _dkHienThiDSTapDayDu) {
      _khiThayDoiHienThiDSTapDayDu();
    }
  }

  /// Khi nhấn nút Quay lại
  void _khiNhanQuayLai() {
    if (_thaoTacNap?.thongTinSach != null) {
      Sach thongTinTrenManHinh = _thongTinSachTuGiaoDien();
      final ThaoTacSoSanhSach soSanh = ThaoTacSoSanhSach(
        thongTin1: _thaoTacNap!.thongTinSach,
        thongTin2: thongTinTrenManHinh
      );
      bool ketQuaSoSanh = soSanh.soSanh();
      if (ketQuaSoSanh) {
        for (final muc in _dsNhanLuonHien) {
          if (!thongTinTrenManHinh.nhanLuonHien.contains(muc)) {
            ketQuaSoSanh = false;
            break;
          }
        }
      }
      if (!ketQuaSoSanh) {
        HopThoai.hienThiHopThoaiThongBao(
          noiDung: Vbht.tuKhoa(TK.xacNhanLuu, dem: _demVbht),
          nhanCacNut: [
            Vbht.tuKhoa(TK.luu, dem: _demVbht),
            Vbht.tuKhoa(TK.dong, dem: _demVbht)
          ],
          khiDong: (stt, _) {
            if (stt == 0) {
              _khiNhanLuu();
            } else {
              luongManHinh?.loaiManHinh(manHinh: this);
            }
        });
        return;
      }
    }
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  /// Khi nhấn nút Lưu
  void _khiNhanLuu() {
    _asyncDungNhapVanBan(() async {
      int coTheLuu = 0;
      if (_dkTenSach.vanBan.isEmpty) {
        _dkTenSach.thongBaoLoi = Vbht.tuKhoa(TK.thieuThongTin);
        coTheLuu = 1;
      } else if (maSach == null) {
        final daTonTai = await CoSoDuLieu().kiemTraTenSach(_dkTenSach.vanBan);
        if (daTonTai) {
          _dkTenSach.thongBaoLoi = Vbht.tuKhoa(TK.tenSachDaTonTai);
          coTheLuu = 1;
        } else {
          _dkTenSach.thongBaoLoi = null;
        }
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
          HopThoai.hienThiHopThoaiThongBao(
            noiDung: Vbht.tuKhoa(TK.loiXemLaiTruocKhiLuuSach, dem: _demVbht),
            nhanCacNut: [
              Vbht.tuKhoa(TK.cuLuu, dem: _demVbht),
              Vbht.tuKhoa(TK.dong, dem: _demVbht)
            ],
            khiDong: (nut, tieuDe) {
              if (nut == 0) {
                _luuSach();
              }
            }
          );
        case 2:
          HopThoai.hienThiHopThoaiThongBao(
            noiDung: Vbht.tuKhoa(TK.loiKhongLuuSach, dem: _demVbht),
            nhanCacNut: [Vbht.tuKhoa(TK.dong, dem: _demVbht)]
          );
          break;
        default:
          _luuSach();
      }
    });
  }

  /// Khi nhấn loại bỏ trường văn bản
  void _khiNhanLoaiBoDauVao(DieuKhienTruongVanBan muc) {
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
    } else if (_dsDkDanhDau.contains(muc)) {
      _dsDkDanhDau.remove(muc);
      muc.dispose();
    } else if (_dsDkNhan.contains(muc)) {
      _dsDkNhan.remove(muc);
      muc.dispose();
    }
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  /// Khi không có máy ảnh
  void _khiKhongCoMayAnh() {
    HopThoai.hienThiHopThoaiThongBao(
      noiDung: Vbht.tuKhoa(TK.khongCoMayAnh, dem: _demVbht),
      nhanCacNut: [Vbht.tuKhoa(TK.dong, dem: _demVbht)]
    );
  }

  /// Khi nhấn nút quét ISBN
  void _khiNhanNutQuetISBN() async {
    LinhTinh.dungNhapVanBan();
    final String? maISBN = await HeThongMay.duyNhat.quetMaISBN().onError((error, stackTrace) {
      _khiKhongCoMayAnh();
      return null;
    });
    if (maISBN != null) {
      _dkISBN.vanBan = maISBN;
    }
  }

  /// Khi nhấn nút Tra cứu lưu chiểu
  void _khiNhanTraCuuLuuChieu() {
    _moWebCucXuatBan(url: HangSo.urlLuuChieu, tieuDe: TK.luuChieu);
  }

  /// Khi nhấn nút Tra cứu lưu chiểu
  void _khiNhanTraCuuDKXB() {
    _moWebCucXuatBan(url: HangSo.urlDKXuatBan, tieuDe: TK.dkxb);
  }

  void _moWebCucXuatBan({required String url, required TK tieuDe}) {
    String urlCuoi = url;
    if (_dkTenSach.vanBan.isNotEmpty) {
      urlCuoi += "?query=${Uri.encodeComponent(_dkTenSach.vanBan)}";
    }
    final DieuKhienManHinhWeb dkMhWeb = DieuKhienManHinhWeb(
      url: urlCuoi,
      tieuDe: Vbht.tuKhoa(tieuDe, dem: _demVbht),
      khiChonSach: _khiChonSachTuLuuChieu
    );
    luongManHinh?.themManHinh(manHinh: dkMhWeb);
  }

  /// Khi nhấn vào sửa tập
  void _khiNhanSuaTap() {
    // widget.dkManHinh.push?.call(
    //   ManHinhTimKiem.maManHinh,
    //   ManHinhTimKiem(
    //     cheDo: CheDoManHinhTimKiem.chonSachLapChuoi,
    //     khiChonSach: _khiChonSachLapChuoi
    //   )
    // );
  }

  void _khiChonSachLapChuoi(Sach doiTuong) {

  }

  /// Khi nhấn vào Rời chuỗi
  void _khiNhanRoiChuoi() {
    _dsCacTap.clear();
    _tapConThieu.clear();
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  void _khiThayDoiHienThiDSTapDayDu() {
    LuuTruCauHinh().luuHienThiDSTapDayDu(_dkHienThiDSTapDayDu.giaTri);
    trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
  }

  // --- Xử lý

  void _khoiTaoDuLieu() {
    // TODO: remove
    // for (int so = 1; so <= 10; so += 1) {
    //   final Sach sach = Sach.taoDuLieuGia(chiSo: so);
    //   _dsCacTap.add(sach);
    //   if (so == 3 || so == 6) {
    //     so += 1;
    //   }
    // }
    // _kiemTraTinhLienTucCacTap();

    _khoiTaoDSNhan().then((_) {
      if (maSach != null) {
        _thaoTacNap?.napThongTin().then((value) {
          if (value) {
            _khoiTaoManHinhTheoThongTinSach();
            trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
          } else {
            trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
            HopThoai.hienThiHopThoaiThongBao(
              noiDung: Vbht.tuKhoa(TK.sachKhongTonTai, dem: _demVbht),
              nhanCacNut: [Vbht.tuKhoa(TK.dong, dem: _demVbht)],
              khiDong: (stt, nhan) {
                luongManHinh?.loaiManHinh(manHinh: this);
              }
            );
          }
        });
      } else {
        if (_dsNhanLuonHien.isNotEmpty) {
          int dem = 0;
          for (final muc in _dsNhanLuonHien) {
            DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(goiYNoiDung: _goiYGiaTriNhan, goiYTieuDe: _goiYTenNhan, luonHienThi: true);
            dkVb.debugInfo = "NN $dem";
            dkVb.vanBan = "";
            dkVb.vbTieuDe = muc;
            dkVb.trangThaiNutBenPhai = null;
            dkVb.themTheoDoi(this);
            _dsDkNhan.add(dkVb);
            dem += 1;
          }
        }
        _cauHinhLaiDauVao();
        trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
      }
    });
  }

  Future<void> _khoiTaoDSNhan() async {
    _dsNhanLuonHien = await CoSoDuLieu().layDSNhanLuonHien();
  }

  /// Làm sạch tất cả đầu vào: xoá các trường văn bản, hình ảnh
  void _lamSachTatCaDauVao() {
    _dkVbHienTai = null;
    _dkDaDocXong.giaTri = false;
    _dkHinhAnh.hinhAnh = null;
    _dkTenSach.thongBaoLoi = null;
    _dkISBN.thongBaoLoi = null;
    _dkGhiChuTap.thongBaoLoi = null;
    _dkSoTap.thongBaoLoi = null;
    _lamSachDSDauvao(_dsDkTacGia, tatCa: true);
    _lamSachDSDauvao(_dsDkDichGia, tatCa: true);
    _lamSachDSDauvao(_dsDkNxb, tatCa: true);
    _lamSachDSDauvao(_dsDkViTri, tatCa: true);
    _lamSachDSDauvao(_dsDkDanhDau, tatCa: true);
    _lamSachDSDauvao(_dsDkNhan, tatCa: true);
  }

  /// Cấu hình lại nhóm các trường văn bản có chứa [nguon]
  /// hoặc tất cả các nhóm nếu [nguon] là `null`
  void _cauHinhLaiDauVao({DieuKhienTruongVanBan? nguon}) {
    if (nguon == null || _dsDkTacGia.contains(nguon)) {
      _lamSachDSDauvao(_dsDkTacGia, tatCa: false, debugInfo: "TG", goiYNoiDung: _goiYTg);
    }
    if (nguon == null || _dsDkDichGia.contains(nguon)) {
      _lamSachDSDauvao(_dsDkDichGia, tatCa: false, debugInfo: "DG", goiYNoiDung: _goiYDg);
    }
    if (nguon == null || _dsDkNxb.contains(nguon)) {
      _lamSachDSDauvao(_dsDkNxb, tatCa: false, debugInfo: "NXB", goiYNoiDung: _goiYNxb);
    }
    if (nguon == null || _dsDkViTri.contains(nguon)) {
      _lamSachDSDauvao(_dsDkViTri, tatCa: false, khongLap: false, debugInfo: "VT", goiYNoiDung: _goiYViTri);
    }
    if (nguon == null || _dsDkDanhDau.contains(nguon)) {
      _lamSachDSDauvao(_dsDkDanhDau, tatCa: false, debugInfo: "DD");
    }
    if (nguon == null || _dsDkNhan.contains(nguon)) {
      _lamSachDSDauvao(_dsDkNhan, tatCa: false, debugInfo: "Nhan", goiYNoiDung: _goiYGiaTriNhan, goiYTieuDe: _goiYTenNhan);
    }
  }

  /// Làm sạch trường văn bản:
  /// Loại bỏ các điều khiển văn bản trống ([tatCa] = false) hoặc tất cả các điều khiển ([tatCa] = true).
  /// `[khongLap] = true` thì loại bỏ các điều khiển trùng lặp trong dánh sách.
  void _lamSachDSDauvao(
    List<DieuKhienTruongVanBan> danhSach,
    {
      required bool tatCa,
      bool khongLap = true,
      String debugInfo = "",
      GoiYVanBan? goiYNoiDung,
      GoiYVanBan? goiYTieuDe
    }
  ) {
    final bool coTheSuaTieuDe = danhSach == _dsDkNhan;
    final bool coTheTuDongChiaDong = !coTheSuaTieuDe;
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
        if (coTheTuDongChiaDong) {
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
                  DieuKhienTruongVanBan dkDoan = DieuKhienTruongVanBan(goiYNoiDung: goiYNoiDung, goiYTieuDe: goiYTieuDe);
                  dkDoan.debugInfo = "$debugInfo $dem";
                  dkDoan.vanBan = doan;
                  dkDoan.trangThaiNutBenPhai = 0;
                  dkDoan.themTheoDoi(this);
                  boDem.add(dkDoan);
                  dem += 1;
                }
              }
            }
          }
        }
        if (coTheSuaTieuDe) {
          String tieuDe = muc.vbTieuDe.trim();
          if (vanBan.isEmpty && tieuDe.isEmpty) {
            if (dkRong == null) {
              dkRong = muc;
            } else {
              if (muc == _dkVbHienTai) {
                _dkVbHienTai = null;
              }
              muc.dispose();
            }
          } else {
            muc.trangThaiNutBenPhai = 0;
            muc.vanBan = vanBan;
            muc.vbTieuDe = tieuDe;
            muc.debugInfo = "$debugInfo $dem";
            boDem.add(muc);
            dem += 1;
          }
        }
      }
    }
    danhSach.clear();
    if (!tatCa) {
      if (dkRong == null) {
        dkRong = DieuKhienTruongVanBan(goiYNoiDung: goiYNoiDung, goiYTieuDe: goiYTieuDe);
        dkRong.themTheoDoi(this);
      }
      dkRong.debugInfo = "$debugInfo $dem";
      dkRong.vanBan = "";
      dkRong.trangThaiNutBenPhai = null;
      boDem.add(dkRong);
      danhSach.addAll(boDem);
    }
  }

  /// Khởi tạo màn hình theo thông tin sách (chế độ sửa)
  void _khoiTaoManHinhTheoThongTinSach() {
    _dkLuuChieu.khaDung = !chiDoc;
    _dkDkXuatBan.khaDung = !chiDoc;
    _dkGhiChuTap.khaDung = !chiDoc;
    _dkSuaTap.khaDung = !chiDoc;
    _dkSoTap.khaDung = !chiDoc;
    _dkHienThiDSTapDayDu.khaDung = !chiDoc;
    Sach sach = _thaoTacNap!.thongTinSach;
    _dkDaDocXong.giaTri = sach.daHoanThanh;
    _dkDaDocXong.khaDung = !chiDoc;
    _dkHinhAnh.hinhAnh = sach.hinhAnh;
    _dkHinhAnh.khaDung = !chiDoc;
    _dkTenSach.vanBan = sach.ten;
    _dkTenSach.khaDung = !chiDoc;
    _dkISBN.vanBan = sach.isbn;
    _dkISBN.khaDung = !chiDoc;

    int dem = 0;
    for (final muc in sach.tacGia) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(khaDung: !chiDoc);
      dkVb.debugInfo = "TG $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      dkVb.themTheoDoi(this);
      _dsDkTacGia.add(dkVb);
      dem += 1;
    }
    DieuKhienTruongVanBan dkRong = DieuKhienTruongVanBan(khaDung: !chiDoc);
    dkRong.debugInfo = "TG $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    dkRong.themTheoDoi(this);
    _dsDkTacGia.add(dkRong);

    dem = 0;
    for (final muc in sach.dichGia) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(khaDung: !chiDoc);
      dkVb.debugInfo = "DG $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      dkVb.themTheoDoi(this);
      _dsDkDichGia.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan(khaDung: !chiDoc);
    dkRong.debugInfo = "DG $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    dkRong.themTheoDoi(this);
    _dsDkDichGia.add(dkRong);

    dem = 0;
    for (final muc in sach.nhaXuatBan) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(khaDung: !chiDoc);
      dkVb.debugInfo = "NXB $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      dkVb.themTheoDoi(this);
      _dsDkNxb.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan(khaDung: !chiDoc);
    dkRong.debugInfo = "NXB $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    dkRong.themTheoDoi(this);
    _dsDkNxb.add(dkRong);

    dem = 0;
    for (final muc in sach.viTri) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(goiYNoiDung: _goiYViTri, khaDung: !chiDoc);
      dkVb.debugInfo = "VT $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      dkVb.themTheoDoi(this);
      _dsDkViTri.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan(goiYNoiDung: _goiYViTri, khaDung: !chiDoc);
    dkRong.debugInfo = "VT $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    dkRong.themTheoDoi(this);
    _dsDkViTri.add(dkRong);

    dem = 0;
    for (final muc in sach.nhan.keys) {
      final String giaTriMuc = sach.nhan[muc] ?? "";
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(
        goiYNoiDung: _goiYGiaTriNhan,
        goiYTieuDe: _goiYTenNhan,
        luonHienThi: sach.nhanLuonHien.contains(muc),
        khaDung: !chiDoc
      );
      dkVb.debugInfo = "Nhan $dem";
      dkVb.vanBan = giaTriMuc;
      dkVb.vbTieuDe = muc;
      dkVb.trangThaiNutBenPhai = null;
      dkVb.themTheoDoi(this);
      dkVb.khaDung = !chiDoc;
      _dsDkNhan.add(dkVb);
      dem += 1;
    }
    for (final muc in _dsNhanLuonHien) {
      if (!sach.nhanLuonHien.contains(muc)) {
        DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(
          goiYNoiDung: _goiYGiaTriNhan,
          goiYTieuDe: _goiYTenNhan,
          luonHienThi: true,
          khaDung: !chiDoc
        );
        dkVb.debugInfo = "Nhan $dem";
        dkVb.vanBan = "";
        dkVb.vbTieuDe = muc;
        dkVb.trangThaiNutBenPhai = null;
        dkVb.themTheoDoi(this);
        dkVb.khaDung = !chiDoc;
        _dsDkNhan.add(dkVb);
        dem += 1;
      }
    }
    dkRong = DieuKhienTruongVanBan(
      goiYNoiDung: _goiYGiaTriNhan,
      goiYTieuDe: _goiYTenNhan,
      khaDung: !chiDoc
    );
    dkRong.debugInfo = "Nhan $dem";
    dkRong.vanBan = "";
    dkRong.vbTieuDe = "";
    dkRong.trangThaiNutBenPhai = null;
    dkRong.themTheoDoi(this);
    _dsDkNhan.add(dkRong);

    dem = 0;
    for (final muc in sach.danhDau) {
      DieuKhienTruongVanBan dkVb = DieuKhienTruongVanBan(khaDung: !chiDoc);
      dkVb.debugInfo = "DD $dem";
      dkVb.vanBan = muc;
      dkVb.trangThaiNutBenPhai = 0;
      dkVb.themTheoDoi(this);
      _dsDkDanhDau.add(dkVb);
      dem += 1;
    }
    dkRong = DieuKhienTruongVanBan(khaDung: !chiDoc);
    dkRong.debugInfo = "DD $dem";
    dkRong.vanBan = "";
    dkRong.trangThaiNutBenPhai = null;
    dkRong.themTheoDoi(this);
    _dsDkDanhDau.add(dkRong);

    // TODO: tap
  }

  /// Sắp xếp lại thứ tự tập
  void _sapXepLaiThuTuTap() {
    if (_dsCacTap.length < 2) {
      return;
    }
    int tapHt = 0;
    try {
      tapHt = int.parse(_dkSoTap.vanBan);
    } catch (_) {}
    _dsCacTap.sort((s1, s2) {
      final int tap1 = s1.maSo == null ? tapHt : (s1.tap ?? 0);
      final int tap2 = s2.maSo == null ? tapHt : (s2.tap ?? 0);
      if (tap1 == tap2) {
        if (s1.maSo == null) {
          return -1;
        }
        if (s2.maSo == null) {
          return 1;
        }
      }
      return tap1.compareTo(tap2);
    });
  }

  void _kiemTraTinhLienTucCacTap() {
    _tapConThieu.clear();
    if (_dsCacTap.isEmpty) { return; }
    int tapCanKiemTra = 1;
    for (final muc in _dsCacTap) {
      final int tap = muc.tap ?? 0;
      while (tapCanKiemTra < tap) {
        _tapConThieu.add(tapCanKiemTra);
        tapCanKiemTra += 1;
      }
      if (tapCanKiemTra == tap) {
        tapCanKiemTra += 1;
      }
    }
    if (_dkSoTap.vanBan.isNotEmpty) {
      try {
        final int soTap = int.parse(_dkSoTap.vanBan);
        _tapConThieu.remove(soTap);
      } catch (_) {}
    }
  }

  /// Khoá (Disable) toàn màn hình
  void _khoaManHinh() {
    List<DieuKhienCoSo> tatCaDieuKhien = [
      _dkLuuChieu,
      _dkDkXuatBan,
      _dkTenSach,
      _dkISBN,
      _dkHinhAnh,
      _dkDaDocXong,
      _dkSuaTap,
      _dkGhiChuTap,
      _dkSoTap,
      _dkHienThiDSTapDayDu,
      _dkNutLuu,
      _dkNutQuayLai
    ];
    tatCaDieuKhien.addAll(_dsDkTacGia);
    tatCaDieuKhien.addAll(_dsDkDichGia);
    tatCaDieuKhien.addAll(_dsDkNxb);
    tatCaDieuKhien.addAll(_dsDkViTri);
    tatCaDieuKhien.addAll(_dsDkDanhDau);
    tatCaDieuKhien.addAll(_dsDkNhan);
    for (final muc in tatCaDieuKhien) {
      muc.khaDung = false;
    }
  }

  /// Nạp lại màn hình không đồng bộ
  /// (gọi từ các hàm listen ChangeNotif)
  void _asyncNapLaiDanhSachManHinh(void Function() action) {
    Future.delayed(const Duration(milliseconds: 1)).then((_) {
      action.call();
      trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
    });
  }

  /// Dừng nhập văn bản
  /// Delay 1 khoảng để đảm bảo xử lý event dừng
  void _asyncDungNhapVanBan(void Function() action) {
    _choKetThucSoanThao = null;
    if (_dkVbHienTai != null)  {
      _choKetThucSoanThao = action;
      _dkVbHienTai?.trangThaiNhap = TrangThaiNhapVanBan.khong;
      _dkVbHienTai = null;
    } else {
      action.call();
    }
  }

  /// Trường văn bản thay đổi focus
  void _truongVanBanThayDoiFocus(DieuKhienTruongVanBan muc) {
    // print("FOCUS CHANGE ${muc.debugInfo} ${muc.trangThaiNhap}");
    if (muc.trangThaiNhap == TrangThaiNhapVanBan.khong && _dkVbHienTai == muc) {
      _dkVbHienTai = null;
    } else if (muc.dangTrongTrangThaiNhap()) {
      _dkVbHienTai = muc;
    }
    if (muc.trangThaiNhap == TrangThaiNhapVanBan.khong) {
      muc.vanBan = muc.vanBan.trim();
      if (muc.vanBan.isNotEmpty) {
        muc.thongBaoLoi = null;
      }
      bool canThemOTrong = _dsDkTacGia.contains(muc) || _dsDkDichGia.contains(muc) || _dsDkNxb.contains(muc) || _dsDkViTri.contains(muc) || _dsDkDanhDau.contains(muc) || _dsDkNhan.contains(muc);
      // print("TRANG THAI NHAP TEN SACH ${muc.focus} $canThemOTrong");
      if (canThemOTrong) {
        // Hàm hiện tại nằm trong notifier của `DieuKhienTruongVanBan`.
        // Delay ra để thành 1 xử lý riêng biệt.
        void Function()? action;
        if (_choKetThucSoanThao != null) {
          action = _choKetThucSoanThao;
          _choKetThucSoanThao = null;
        }
        _asyncNapLaiDanhSachManHinh(() {
          _cauHinhLaiDauVao(nguon: muc);
          action?.call();
        });
      }
      if (muc == _dkSoTap) {
        _sapXepLaiThuTuTap();
        _kiemTraTinhLienTucCacTap();
        trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
      }
    }
    if (_choKetThucSoanThao != null) {
      _choKetThucSoanThao?.call();
      _choKetThucSoanThao = null;
    }
  }

  /// Khi chọn sách từ lưu chiểu
  void _khiChonSachTuLuuChieu(Map<String, String> duLieu) {
    // print("DEBUG $duLieu\n${widget.dkManHinh.dsNxb}");
    String isbn = duLieu["ISBN"] ?? "";
    String ten = duLieu["ten"] ?? "";
    String tacGia = duLieu["TG"] ?? "";
    String nxb = duLieu["NXB"] ?? "";
    String doiTac = (duLieu["DT"] ?? "").toUpperCase();
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
    for (final muc in _dsNxb) {
      if (muc != nxb && doiTac.contains(muc.toUpperCase())) {
        dkNxb = DieuKhienTruongVanBan();
        dkNxb.vanBan = muc;
        _dsDkNxb.add(dkNxb);
        break;
      }
    }
    _khoiTaoDSNhan().then((_) {
      _cauHinhLaiDauVao();
      trangThaiWidgetManHinh?.capNhatGiaoDienCuaManHinh(dieuKhienManHinh: this);
    });
  }

  Sach _thongTinSachTuGiaoDien() {
    final Sach thongTinSach = Sach();
    thongTinSach.maSo = maSach;
    thongTinSach.ten = _dkTenSach.vanBan;
    thongTinSach.isbn = _dkISBN.vanBan;
    thongTinSach.daHoanThanh = _dkDaDocXong.giaTri;
    thongTinSach.hinhAnh = _dkHinhAnh.hinhAnh;
    thongTinSach.tacGia = _dsDkTacGia.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.dichGia = _dsDkDichGia.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.nhaXuatBan = _dsDkNxb.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.viTri = _dsDkViTri.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    thongTinSach.danhDau = _dsDkDanhDau.where((element) => element.vanBan.isNotEmpty).map((e) => e.vanBan).toList();
    List<String> nhanLuonHien = [];
    Map<String, String> nhan = {};
    for (final DieuKhienTruongVanBan dk in _dsDkNhan) {
      if (dk.vanBan.isNotEmpty && dk.vbTieuDe.isNotEmpty) {
        nhan[dk.vbTieuDe] = dk.vanBan;
      }
      if (dk.vbTieuDe.isNotEmpty && dk.luonHienThi) {
        nhanLuonHien.add(dk.vbTieuDe);
      }
    }
    thongTinSach.nhan = nhan;
    thongTinSach.nhanLuonHien = nhanLuonHien;
    return thongTinSach;
  }

  /// Tiến hành lưu thông tin vào CSDL
  void _luuSach() {
    _khoaManHinh();
    final Sach thongTinSach = _thongTinSachTuGiaoDien();
    thongTinSach.inThongTinChiTiet();
    // return;
    // TODO: nhieu tap
    final ThaoTacLuuThongTinSach thaoTac = ThaoTacLuuThongTinSach(thongTinSach);
    thaoTac.luuThongTin().then((value) => luongManHinh?.loaiManHinh(manHinh: this));
  }

}

class _ManHinhSach extends StatelessWidget {

  final DieuKhienManHinhSach dkMh;

  const _ManHinhSach({required this.dkMh});

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: Vbht.tuKhoa(dkMh.maSach == null ? TK.sachMoi : TK.thongTinSach, dem: dkMh._demVbht),
      khiNhanQuayLai: dkMh._khiNhanQuayLai,
      dkNutQuayLai: dkMh._dkNutQuayLai,
      nutPhai: dkMh.chiDoc && dkMh.maSach != null ? null : NutBamBieuTuong(icon: Icons.save, khiNhan: dkMh._khiNhanLuu, dieuKhien: dkMh._dkNutLuu),
      noiDung: _NoiDungManHinhSach(dieuKhienManHinh: dkMh)
    );
  }

}

class _NoiDungManHinhSach extends WidgetCuaDieuKhienManHinh<DieuKhienManHinhSach> {

  const _NoiDungManHinhSach({required super.dieuKhienManHinh});

  @override
  State<StatefulWidget> createState() => _TrangThaiNoiDungManHinhSach();

}

class _TrangThaiNoiDungManHinhSach extends TrangThaiWidgetCuaDieuKhien<_NoiDungManHinhSach> {

  late DieuKhienDanhSachHienThi _dkDanhSachManHinh;

  bool _canHienThiTienTrinh() => widget.dieuKhienManHinh.maSach != null && !widget.dieuKhienManHinh._thaoTacNap!.daXong;
  bool _sachTonTai() => (widget.dieuKhienManHinh.maSach != null && widget.dieuKhienManHinh._thaoTacNap!.thanhCong) || widget.dieuKhienManHinh.maSach == null;
  bool _hienThiTienTrinh = false;
  bool _coLoi = false;

  @override
  void initState() {
    super.initState();
    _hienThiTienTrinh = _canHienThiTienTrinh();
    _coLoi = !_sachTonTai();
    _dkDanhSachManHinh = DieuKhienDanhSachHienThi(
      soLuongPhanDoan: _soPhanDoan,
      soMucCuaPhanDoan: _soMucCuaPhanDoan,
      tieuDeChoDoan: _tieuDeChoDoan,
      widgetsCuaCaDoan: _xayDungToanBoWidgetsCuaDoan,
      widgetCuaMuc: _xayDungWidgetCuaMuc,
      khoangCachPhiaTren: _khoangTrongTrenChoMuc,
      khoangCachPhiaDuoi: _khoangTrongDuoiChoMuc
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dkDanhSachManHinh.dispose();
  }

  @override
  void capNhatGiaoDienCuaManHinh({required DieuKhienManHinh dieuKhienManHinh, ThamSoDieuKhienWidgetManHinh? duLieuDinhKem}) {
    bool hienThiTienTrinh = _canHienThiTienTrinh();
    bool coLoi = !_sachTonTai();
    if ((hienThiTienTrinh != _hienThiTienTrinh) || (coLoi != _coLoi) ) {
      setState(() {
        _coLoi = coLoi;
        _hienThiTienTrinh = hienThiTienTrinh;
      });
    }
    _napLaiDanhSachManHinh();
  }

  @override
  Widget build(BuildContext context) {
    if (_hienThiTienTrinh) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    }
    if (_coLoi) {
      return Container(); // Hiển thị nền trống cho thông báo lỗi
    }
    return DanhSachHienThi(dieuKhien: _dkDanhSachManHinh);
  }

  // --- Cấu hình danh sách hiển thị
  void _napLaiDanhSachManHinh() {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    DieuKhienTruongVanBan? tam = dkMh._dkVbHienTai;
    TrangThaiNhapVanBan tamFocus = tam?.trangThaiNhap ?? TrangThaiNhapVanBan.khong;
    tam?.trangThaiNhap = TrangThaiNhapVanBan.khong;
    _dkDanhSachManHinh.napLaiDanhSach();
    // Khôi phục lại trường văn bản đang focus trước khi refresh lại state
    if (tam != null) {
      Future.delayed(const Duration(milliseconds: 100)).then((value) {
        tam.trangThaiNhap = tamFocus;
      });
    }
  }

  /// Số phân đoạn trên màn hình
  int _soPhanDoan() {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    if (dkMh.maSach != null && !dkMh._thaoTacNap!.daXong) {
      return 0;
    }
    return _PhanDoanManHinhSach.tongSo();
  }
  /// Số dòng của phần đoạn [doan]
  int _soMucCuaPhanDoan(int doan) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    final _PhanDoanManHinhSach? phanDoan = _PhanDoanManHinhSach.khoiTao(doan);
    return switch (phanDoan) {
      _PhanDoanManHinhSach.chung => 6,
      _PhanDoanManHinhSach.coBan => dkMh._dsDkTacGia.length + dkMh._dsDkDichGia.length + dkMh._dsDkNxb.length,
      _PhanDoanManHinhSach.viTri => dkMh._dsDkViTri.length,
      _PhanDoanManHinhSach.danhDau => dkMh._dsDkDanhDau.length,
      _PhanDoanManHinhSach.nhan => dkMh._dsDkNhan.length,
      _PhanDoanManHinhSach.chanTrang => 1,
      _ => 0,
    };
  }
  /// Dòng tiêu đề cho phân đoạn [doan]
  TruongTieuDe? _tieuDeChoDoan(int doan) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    final _PhanDoanManHinhSach? phanDoan = _PhanDoanManHinhSach.khoiTao(doan);
    return switch (phanDoan) {
      _PhanDoanManHinhSach.coBan => TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.thongTinSachCoBan, dem: dkMh._demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichThongTinCoBan, dem: dkMh._demVbht)
      ),
      _PhanDoanManHinhSach.viTri => TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.viTri, dem: dkMh._demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichViTri, dem: dkMh._demVbht)
      ),
      _PhanDoanManHinhSach.danhDau => TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.tieuDeDanhDau, dem: dkMh._demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichDanhDau, dem: dkMh._demVbht)
      ),
      _PhanDoanManHinhSach.nhan => TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.tieuDeNhan, dem: dkMh._demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichNhan, dem: dkMh._demVbht)
      ),
      _PhanDoanManHinhSach.nhieuTap => TruongTieuDe(
        tieuDeChinh: Vbht.tuKhoa(TK.tieuDeSachNhieuTap, dem: dkMh._demVbht),
        tieuDePhu: Vbht.tuKhoa(TK.giaiThichSachNhieuTap, dem: dkMh._demVbht)
      ),
      _ => null,
    };
  }

  Widget? _xayDungWidgetsMucChung(int dong) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    return switch (dong) {
      // Tra cứu lưu chiểu
      0 => TruongNutBam(
        khiNhan: dkMh._khiNhanTraCuuLuuChieu,
        tieuDe: Vbht.tuKhoa(TK.traCuuLuuChieu, dem: dkMh._demVbht),
        icon: Icons.arrow_forward,
        dieuKhien: dkMh._dkLuuChieu,
      ),
      // Đăng ký xuất bản
      1 => TruongNutBam(
        khiNhan: dkMh._khiNhanTraCuuDKXB,
        tieuDe: Vbht.tuKhoa(TK.traCuuDKXB, dem: dkMh._demVbht),
        icon: Icons.arrow_forward,
        dieuKhien: dkMh._dkDkXuatBan,
      ),
      // Đã đọc xong
      2 => TruongBatTat(tieuDe: Vbht.tuKhoa(TK.daDocXong, dem: dkMh._demVbht), trinhDieuKhien: dkMh._dkDaDocXong),
      // Hình chụp
      3 => TruongHinhAnh(
        trinhDieuKhien: dkMh._dkHinhAnh,
        khiKhongCoMayAnh: dkMh._khiKhongCoMayAnh,
        dem: dkMh._demVbht,
      ),
      // Tên sách
      4 => TruongVanBan(
        tieuDe: Vbht.tuKhoa(TK.tenSach, dem: dkMh._demVbht),
        trinhDieuKhien: dkMh._dkTenSach,
      ),
      // Mã ISBN
      5 => TruongVanBan(
        tieuDe: Vbht.tuKhoa(TK.isbn, dem: dkMh._demVbht),
        cauHinh: CauHinhTruongVanBan(
          kieuBanPhim: TextInputType.number,
          kiemSoatNhapLieu: [FilteringTextInputFormatter.digitsOnly],
          soKyTuToiDa: 13,
        ),
        trinhDieuKhien: dkMh._dkISBN,
        xayDungNutBenPhai: (_, khaDung) => NutBamBieuTuongTieuDe(
          onPressed: khaDung ? dkMh._khiNhanNutQuetISBN : null,
          icon: Icon(Icons.camera_alt_outlined, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
        ),
      ),
      _ => null,
    };
  }

  TruongVanBan _xayDungTruongVanBan(TK tieuDe, DieuKhienTruongVanBan dieuKhien) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    return TruongVanBan(
      tieuDe: Vbht.tuKhoa(tieuDe, dem: dkMh._demVbht),
      trinhDieuKhien: dieuKhien,
      xayDungNutBenPhai: (danhDau, khaDung) => danhDau == null ? null : NutBamBieuTuongTieuDe(
        onPressed: !khaDung ? null : () {
          dkMh._khiNhanLoaiBoDauVao(dieuKhien);
        }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
      ),
    );
  }

  Widget? _xayDungWidgetsMucCoBan(int dong) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    int soDong = dong;
    if (soDong < dkMh._dsDkTacGia.length) {
      DieuKhienTruongVanBan dieuKhien = dkMh._dsDkTacGia[soDong];
      return _xayDungTruongVanBan(TK.tacGia, dieuKhien);
    }
    soDong -= dkMh._dsDkTacGia.length;
    if (soDong < dkMh._dsDkDichGia.length) {
      DieuKhienTruongVanBan dieuKhien = dkMh._dsDkDichGia[soDong];
      return _xayDungTruongVanBan(TK.dichGia, dieuKhien);
    }
    soDong -= dkMh._dsDkDichGia.length;
    DieuKhienTruongVanBan dieuKhien = dkMh._dsDkNxb[soDong];
    return _xayDungTruongVanBan(TK.dvPhatHanh, dieuKhien);
  }

  Widget? _xayDungWidgetsMucViTri(int dong) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    return _xayDungTruongVanBan(TK.viTri, dkMh._dsDkViTri[dong]);
  }

  Widget? _xayDungWidgetsMucDanhDau(int dong) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    return _xayDungTruongVanBan(TK.danhDau, dkMh._dsDkDanhDau[dong]);
  }

  Widget? _xayDungWidgetsMucNhan(int dong) {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    final DieuKhienTruongVanBan dieuKhien = dkMh._dsDkNhan[dong];
    return TruongVanBan(
      cauHinhTieuDe: const CauHinhTruongVanBan(),
      batLuonHienThi: true,
      trinhDieuKhien: dieuKhien,
      demVbht: dkMh._demVbht,
      xayDungNutBenPhai: (coTheXoa, khaDung) => coTheXoa == null ? null : NutBamBieuTuongTieuDe(
          onPressed: !khaDung ? null : () {
            dkMh._khiNhanLoaiBoDauVao(dieuKhien);
          }, icon: Icon(Icons.delete_outline, color: khaDung ? Theme.of(context).primaryColor : Colors.grey)
        ),
    );
  }

  List<Widget> _xayDungWidgetsMucNhieuTap() {
    final DieuKhienManHinhSach dkMh = widget.dieuKhienManHinh;
    List<ThongTinHienThiTruongSach> dsTruongSach = TruongSach.thongTinMacDinh();
    dsTruongSach.add(ThongTinHienThiTruongSach(truong: ThongTinSachDeHienThi.soTap));
    List<Widget> ketQua = [];
    ketQua.add(
      TruongNutBam(
        khiNhan: dkMh._khiNhanSuaTap,
        tieuDe: Vbht.tuKhoa(TK.chonSachLapChuoi, dem: dkMh._demVbht),
        icon: Icons.layers,
        dieuKhien: dkMh._dkSuaTap,
      )
    );

    if (dkMh._dsCacTap.length > 1) {
      ketQua.add(
        TruongNutBam(
          khiNhan: dkMh._khiNhanRoiChuoi,
          tieuDe: Vbht.tuKhoa(TK.roiChuoi, dem: dkMh._demVbht),
          icon: Icons.layers_clear,
          dieuKhien: dkMh._dkSuaTap,
        )
      );
      ketQua.add(
        TruongVanBan(
          tieuDe: Vbht.tuKhoa(TK.ghiChuChuoi, dem: dkMh._demVbht),
          trinhDieuKhien: dkMh._dkGhiChuTap
        )
      );
      if (dkMh._tapConThieu.isNotEmpty) {
        ketQua.add(
          VbhtWidget(text: Vbht.tuKhoa(TK.tapConThieu, dem: dkMh._demVbht, ts: [dkMh._tapConThieu.join(", ")]))
        );
      }

      bool hienThiDayDu = dkMh._dkHienThiDSTapDayDu.giaTri;
      if (dkMh._dsCacTap.length > 3) {
        ketQua.add(
          TruongBatTat(tieuDe: Vbht.tuKhoa(TK.hienThiDSTapDayDu, dem: dkMh._demVbht, ts: ["${dkMh._dsCacTap.length}"]), trinhDieuKhien: dkMh._dkHienThiDSTapDayDu),
        );
      } else {
        hienThiDayDu = true;
      }

      if (hienThiDayDu) {
        for (final muc in dkMh._dsCacTap) {
          if (muc.maSo == null) {
            ketQua.add(
              TruongVanBan(
                tieuDe: Vbht.tuKhoa(TK.tapSo, dem: dkMh._demVbht),
                cauHinh: CauHinhTruongVanBan(
                  kieuBanPhim: TextInputType.number,
                  kiemSoatNhapLieu: [FilteringTextInputFormatter.digitsOnly]
                ),
                trinhDieuKhien: dkMh._dkSoTap
              )
            );
          } else {
            ketQua.add(
              TruongSach(sach: muc, thongTinCanHienThi: dsTruongSach)
            );
          }
        }
      } else {
        final int viTrisachHienTai = dkMh._dsCacTap.indexWhere((element) => element.maSo == null);
        if (viTrisachHienTai > 1) {
          ketQua.add(Container(
            padding: const EdgeInsets.all(5),
            color: Colors.grey,
            child: Text(
              "+${viTrisachHienTai - 1}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.white
              )
            ))
          );
        }
        if (viTrisachHienTai > 0) {
          ketQua.add(
            TruongSach(sach: dkMh._dsCacTap[viTrisachHienTai - 1], thongTinCanHienThi: dsTruongSach)
          );
        }
        ketQua.add(
          TruongVanBan(
            tieuDe: Vbht.tuKhoa(TK.tapSo, dem: dkMh._demVbht),
            cauHinh: CauHinhTruongVanBan(
              kieuBanPhim: TextInputType.number,
              kiemSoatNhapLieu: [FilteringTextInputFormatter.digitsOnly]
            ),
            trinhDieuKhien: dkMh._dkSoTap
          )
        );
        if (viTrisachHienTai < dkMh._dsCacTap.length - 1) {
          ketQua.add(
            TruongSach(sach: dkMh._dsCacTap[viTrisachHienTai + 1], thongTinCanHienThi: dsTruongSach)
          );
        }
        if (viTrisachHienTai < dkMh._dsCacTap.length - 2) {
          ketQua.add(Container(
            padding: const EdgeInsets.all(5),
            color: Colors.grey,
            child: Text(
              "+${dkMh._dsCacTap.length - viTrisachHienTai - 2}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.white
              )
            ))
          );
        }
      }
    }
    return ketQua;
  }

  List<Widget>? _xayDungToanBoWidgetsCuaDoan(int doan) {
    final _PhanDoanManHinhSach? phanDoan = _PhanDoanManHinhSach.khoiTao(doan);
    return switch (phanDoan) {
      _PhanDoanManHinhSach.nhieuTap => _xayDungWidgetsMucNhieuTap(),
      _ => null,
    };
  }

  /// Widget cho mục tại phân đoạn [doan] và dòng [dong]
  Widget? _xayDungWidgetCuaMuc(int doan, int dong) {
    final _PhanDoanManHinhSach? phanDoan = _PhanDoanManHinhSach.khoiTao(doan);
    return switch (phanDoan) {
      _PhanDoanManHinhSach.chung => _xayDungWidgetsMucChung(dong),
      _PhanDoanManHinhSach.coBan => _xayDungWidgetsMucCoBan(dong),
      _PhanDoanManHinhSach.viTri => _xayDungWidgetsMucViTri(dong),
      _PhanDoanManHinhSach.danhDau => _xayDungWidgetsMucDanhDau(dong),
      _PhanDoanManHinhSach.nhan => _xayDungWidgetsMucNhan(dong),
      _PhanDoanManHinhSach.chanTrang => Container(height: GoiYVanBan.chieuCaoHienThiGoiY),
      _ => null,
    };
  }
  /// Khoảng trống phía trên cho mục
  double? _khoangTrongTrenChoMuc(int doan, int dong) {
    if (doan > 0 && dong == 0) {
      return 10;
    }
    return null;
  }
  /// Khoảng trống phía dưới cho mục
  double? _khoangTrongDuoiChoMuc(int doan, int dong) {
    if (doan == 0 && dong == 0) {
      return null;
    }
    return 10;
  }

}
