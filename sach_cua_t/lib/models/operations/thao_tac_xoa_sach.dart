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
import 'package:sach_cua_t/models/operations/thao_tac_nap_sach.dart';

/// Thao tác xoá thông tin sách
class ThaoTacXoaThongTinSach {

  final int maSach;

  ThaoTacXoaThongTinSach(this.maSach);

  Future<void> xoa() async {
    final CoSoDuLieu csdl = CoSoDuLieu();
    await csdl.xoaTatCaDanhDauCuaSach(maSach);
    final Sach sach = Sach();
    sach.maSo = maSach;
    final ThaoTacNapThongTinSach nap = ThaoTacNapThongTinSach(sach);
    await nap.napThongTin();
    await csdl.xoaAnhCuaSach(maSach);
    await csdl.xoaTatCaNxbCuaSach(maSach);
    List<TacGia> dsTacGia = await csdl.layDsTacGiaCuaSach(sach);
    await csdl.xoaTatCaTacGiaCuaSach(maSach);
    for (final TacGia tg in dsTacGia) {
      final int soSach = await csdl.demSoSachCuaTacGia(tg);
      if (soSach == 0) {
        await csdl.xoaTacGia(tg);
      }
    }
    List<DichGia> dsDichGia = await csdl.layDsDichGiaCuaSach(sach);
    await csdl.xoaTatCaDichGiaCuaSach(maSach);
    for (final DichGia dg in dsDichGia) {
      final int soSach = await csdl.demSoSachCuaDichGia(dg);
      if (soSach == 0) {
        await csdl.xoaDichGia(dg);
      }
    }
    List<ViTriSach> dsViTri = await csdl.layDsViTriCuaSach(sach);
    await csdl.xoaTatCaViTriCuaSach(maSach);
    for (final ViTriSach vt in dsViTri) {
      final int soSach = await csdl.demSoSachCuaViTri(vt);
      if (soSach == 0) {
        await csdl.xoaViTri(vt);
      }
    }
    List<NhanSach> dsNhan = await csdl.layDSNhanCuaSach(sach);
    await csdl.xoaTatCaNhanChoSach(maSach);
    for (final NhanSach nhan in dsNhan) {
      final int soSach = await csdl.demSoGiaTriCuaNhan(nhan);
      if (soSach == 0) {
        await csdl.xoaNhan(nhan);
      }
    }
    int? maNhieuTap = sach.maNhieuTap;
    await csdl.xoaSach(maSach);
    if (maNhieuTap != null) {
      int soSach = await csdl.demSoSachChuoiNhieuTap(maNhieuTap);
      if (soSach < 2) {
        await csdl.xoaHetSachKhoiChuoi(maNhieuTap);
        await csdl.xoaChuoiSachNhieuTap(maNhieuTap);
      }
    }
  }

}