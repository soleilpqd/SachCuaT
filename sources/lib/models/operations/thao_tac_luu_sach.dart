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

import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/dulieu.dart';

/// Thao tác lưu thông tin sách
class ThaoTacLuuThongTinSach {

  /// Thông tin để lưu
  final Sach thongTinSach;
  /// Sách cùng bộ
  final List<Sach> sachCungBo;

  /// Constructor
  ThaoTacLuuThongTinSach({required this.thongTinSach, required this.sachCungBo});

  /// Lưu thông tin
  Future<void> luuThongTin() async {
    await _luuThongTinChung();
    await _luuAnhSach();
    await _luuTacGiaSach();
    await _luuDichGiaSach();
    await _luuDvPhatHanh();
    await _luuViTri();
    await _luuNhan();
    await _luuDanhDau();
    await _luuNhieuTap();
  }

  /// Lưu thông tin chung
  Future<void> _luuThongTinChung() async {
    if (thongTinSach.maSo == null) {
      await CoSoDuLieu().taoMoiSach(thongTinSach);
    } else {
      await CoSoDuLieu().capNhatSach(thongTinSach);
    }
  }

  /// Lưu ảnh sách
  Future<void> _luuAnhSach() async {
    return CoSoDuLieu().luuAnhSach(thongTinSach);
  }

  /// Đồng bộ dữ liệu giữa các đối tượng hiện tại [dsHienTai] và danh sách tên [dsThayDoi].
  /// Trả về (
  ///   danh sách tên mới - tên trong [dsThayDoi] nhưng ko có trong [dsHienTai],
  ///   danh sách các đối tượng cũ - đối tượng trong [dsHienTai] ko có trong [dsThayDoi])
  (List<String>, List<T>) _dongBoDuLieu<T extends DuLieuCoso>(
    List<T> dsHienTai,
    List<String> dsThayDoi
  ) {
    List<String> dsMoi = [];
    List<T> dsKhongDoi = [];
    List<T> dsCu = [];
    for (final ten in dsThayDoi) {
      bool timThay = false;
      for (final hientai in dsHienTai) {
        if (hientai.ten == ten) {
          timThay = true;
          dsKhongDoi.add(hientai);
        }
      }
      if (!timThay) {
        dsMoi.add(ten);
      }
    }
    List<T> dsHt = dsHienTai;
    for (final muc in dsKhongDoi) {
      dsHt.remove(muc);
    }
    for (final muc in dsHt) {
      if (!dsThayDoi.contains(muc.ten)) {
        dsCu.add(muc);
      }
    }
    return (dsMoi, dsCu);
  }

  /// Lưu tác giả
  Future<void> _luuTacGiaSach() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    List<TacGia> dsTgHienTai = await csdl.layDsTacGiaCuaSach(thongTinSach);
    final ketQua = _dongBoDuLieu(dsTgHienTai, thongTinSach.tacGia);
    final List<String> dsTgMoi = ketQua.$1;
    final List<TacGia> dsTgCu = ketQua.$2;

    List<TacGia> dsTgMoi2 = [];
    for (final ten in dsTgMoi) {
      TacGia? tacGia = await csdl.timTacGia(ten);
      if (tacGia == null) {
        tacGia = TacGia();
        tacGia.ten = ten;
        await csdl.themTacGia(tacGia);
      }
      dsTgMoi2.add(tacGia);
    }
    for (final TacGia tg in dsTgMoi2) {
      await csdl.themTacGiaCuaSach(thongTinSach, tg);
    }

    for (final TacGia tg in dsTgCu) {
      await csdl.xoaTacGiaCuaSach(thongTinSach, tg);
      int slSach = await csdl.demSoSachCuaTacGia(tg);
      if (slSach == 0) {
        await csdl.xoaTacGia(tg);
      }
    }
  }

  /// Lưu dịch giả
  Future<void> _luuDichGiaSach() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    List<DichGia> dsDgHienTai = await csdl.layDsDichGiaCuaSach(thongTinSach);
    final ketQua = _dongBoDuLieu(dsDgHienTai, thongTinSach.dichGia);
    final List<String> dsDgMoi = ketQua.$1;
    final List<DichGia> dsDgCu = ketQua.$2;

    List<DichGia> dsDgMoi2 = [];
    for (final ten in dsDgMoi) {
      DichGia? dichGia = await csdl.timDichGia(ten);
      if (dichGia == null) {
        dichGia = DichGia();
        dichGia.ten = ten;
        await csdl.themDichGia(dichGia);
      }
      dsDgMoi2.add(dichGia);
    }
    for (final dg in dsDgMoi2) {
      await csdl.themDichGiaCuaSach(thongTinSach, dg);
    }

    for (final dg in dsDgCu) {
      await csdl.xoaDichGiaCuaSach(thongTinSach, dg);
      int slSach = await csdl.demSoSachCuaDichGia(dg);
      if (slSach == 0) {
        await csdl.xoaDichGia(dg);
      }
    }
  }

  /// Lưu đơn vị phát hành
  Future<void> _luuDvPhatHanh() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    List<NhaXuatBan> dsNxbHienTai = await csdl.layDsNhaXuatBanCuaSach(thongTinSach);
    final ketQua = _dongBoDuLieu(dsNxbHienTai, thongTinSach.nhaXuatBan);
    final List<String> dsNxbMoi = ketQua.$1;
    final List<NhaXuatBan> dsNxbCu = ketQua.$2;

    List<NhaXuatBan> dsNxbMoi2 = [];
    for (final ten in dsNxbMoi) {
      NhaXuatBan? nxb = await csdl.timNhaXuatBan(ten);
      if (nxb == null) {
        nxb = NhaXuatBan();
        nxb.ten = ten;
        await csdl.themNhaXuatBan(nxb);
      }
      dsNxbMoi2.add(nxb);
    }
    for (final nxb in dsNxbMoi2) {
      await csdl.themNxbCuaSach(thongTinSach, nxb);
    }

    for (final nxb in dsNxbCu) {
      await csdl.xoaNxbCuaSach(thongTinSach, nxb);
      int slSach = await csdl.demSoSachCuaNXB(nxb);
      if (slSach == 0) {
        await csdl.xoaNxb(nxb);
      }
    }
  }

  /// Lưu vị trí
  Future<void> _luuViTri() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    List<ViTriSach> dsVtHienTai = await csdl.layDsViTriCuaSach(thongTinSach);
    final ketQua = _dongBoDuLieu(dsVtHienTai, thongTinSach.viTri);
    final List<String> dsVtMoi = ketQua.$1;
    final List<ViTriSach> dsVtCu = ketQua.$2;

    List<ViTriSach> dsVtMoi2 = [];
    for (final ten in dsVtMoi) {
      ViTriSach? vt = await csdl.timViTri(ten);
      if (vt == null) {
        vt = ViTriSach();
        vt.ten = ten;
        await csdl.themViTri(vt);
      }
      dsVtMoi2.add(vt);
    }
    for (final vt in dsVtMoi2) {
      await csdl.themViTriCuaSach(thongTinSach, vt);
    }

    for (final vt in dsVtCu) {
      await csdl.xoaViTriCuaSach(thongTinSach, vt);
      int slSach = await csdl.demSoSachCuaViTri(vt);
      if (slSach == 0) {
        await csdl.xoaViTri(vt);
      }
    }
  }

  Future<void> _lamSachNhieuTap(int maNhieuTap) async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    final int slSach = await csdl.demSoSachChuoiNhieuTap(maNhieuTap);
    if (slSach < 2) {
      await csdl.xoaHetSachKhoiChuoi(maNhieuTap);
      await csdl.xoaChuoiSachNhieuTap(maNhieuTap);
    }
  }

  /// Lưu thông tin tập
  Future<void> _luuNhieuTap() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    final Sach thongTinHt = Sach();
    thongTinHt.maSo = thongTinSach.maSo;
    await csdl.napThongTinSach(thongTinHt);

    if (sachCungBo.isEmpty) {
      await csdl.luuThongTinNhieuTapCuaSach(thongTinSach);
      if (thongTinHt.maNhieuTap != null) {
        await _lamSachNhieuTap(thongTinHt.maNhieuTap!);
      }
    } else {
      if (thongTinSach.maNhieuTap == null) {
        final SachNhieuTap chuoiMoi = SachNhieuTap();
        chuoiMoi.ten = thongTinSach.nhieuTap ?? "";
        await csdl.themChuoiSachNhieuTap(chuoiMoi);
        thongTinSach.maNhieuTap = chuoiMoi.maSo;
        for (final Sach sachTrongChuoi in sachCungBo) {
          sachTrongChuoi.maNhieuTap = chuoiMoi.maSo;
          await csdl.luuThongTinNhieuTapCuaSach(sachTrongChuoi);
        }
      } else {
        final SachNhieuTap chuoiCu = SachNhieuTap();
        chuoiCu.maSo = thongTinSach.maNhieuTap ?? 0;
        chuoiCu.ten = thongTinSach.nhieuTap ?? "";
        await csdl.suaChuoiSachNhieuTap(chuoiCu);
      }
      await csdl.luuThongTinNhieuTapCuaSach(thongTinSach);
      if (thongTinSach.maNhieuTap != thongTinHt.maNhieuTap && thongTinHt.maNhieuTap != null) {
        await _lamSachNhieuTap(thongTinHt.maNhieuTap!);
      }
    }
  }

  /// Lưu nhãn
  Future<void> _luuNhan() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    final List<String> dsTenNhanSach = thongTinSach.nhan.keys.toList();
    List<NhanSach> dsNhanHienCo = dsTenNhanSach.isEmpty ? [] : await csdl.layDSNhan(dsTenNhanSach);
    // Tạo bản ghi cho nhãn mới
    for (final String tenNhan in dsTenNhanSach) {
      final int stt = dsNhanHienCo.indexWhere((element) => element.ten == tenNhan);
      if (stt < 0) {
        final NhanSach nhanMoi = NhanSach();
        nhanMoi.ten = tenNhan;
        nhanMoi.giaTri = thongTinSach.nhan[tenNhan];
        await csdl.themNhan(nhanMoi);
        dsNhanHienCo.add(nhanMoi);
      } else {
        dsNhanHienCo[stt].giaTri = thongTinSach.nhan[tenNhan];
      }
    }
    // Cập nhật lại giá trị cho các nhãn sách đã có và tạo mới bản ghi nếu sách chưa có nhãn
    final List<NhanSach> dsNhanCuaSachHienCo = await csdl.layDSNhanCuaSach(thongTinSach);
    for (final NhanSach nhanMoi in dsNhanHienCo) {
      bool coNhanCu = false;
      for (final NhanSach nhanCu in dsNhanCuaSachHienCo) {
        if (nhanMoi.maSo == nhanCu.maSo) {
          coNhanCu = true;
          if (nhanMoi.giaTri != nhanCu.giaTri) {
            await csdl.capNhatNhanChoSach(thongTinSach, nhanMoi);
          }
          break;
        }
      }
      if (!coNhanCu) {
        await csdl.themNhanChoSach(thongTinSach, nhanMoi);
      }
    }
    // Xoá các bản ghi nhãn sách không còn
    for (final NhanSach nhanCu in dsNhanCuaSachHienCo) {
      final int stt = dsNhanHienCo.indexWhere((element) => element.maSo == nhanCu.maSo);
      if (stt < 0) {
        await csdl.xoaNhanChoSach(thongTinSach, nhanCu);
        final int slGt = await csdl.demSoGiaTriCuaNhan(nhanCu);
        if (slGt == 0) {
          await csdl.xoaNhan(nhanCu);
        }
      }
    }
    // Trạng thái luôn hiện của nhãn
    await csdl.datLaiLuonHienCuaNhan();
    if (thongTinSach.nhanLuonHien.isNotEmpty) {
      await csdl.datLuonHienCuaNhan(thongTinSach.nhanLuonHien);
    }
  }

  /// Lưu đánh dấu
  Future<void> _luuDanhDau() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    final List<DanhDauSach> dsDanhDauHt = await csdl.layDSDanhDauCuaSach(thongTinSach);
    for (final String danhDau in thongTinSach.danhDau) {
      final int stt = dsDanhDauHt.indexWhere((element) => element.noiDung == danhDau);
      if (stt < 0) {
        final DanhDauSach danhDauMoi = DanhDauSach();
        danhDauMoi.maSach = thongTinSach.maSo ?? 0;
        danhDauMoi.noiDung = danhDau;
        await csdl.themDanhDauChoSach(danhDauMoi);
      }
    }
    for (final DanhDauSach danhDauCu in dsDanhDauHt) {
      final int stt = thongTinSach.danhDau.indexWhere((element) => element == danhDauCu.noiDung);
      if (stt < 0) {
        await csdl.xoaDanhDau(danhDauCu);
      }
    }
  }

}
