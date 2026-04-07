/*
  Sách của T - Quản lý sách cá nhân
  Copyright © 2026 SoleilPQD

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

/// Thao tác tìm kiếm
class ThaoTacTimKiem {

  /// Danh sách mã sách loại trừ khỏi kết quả
  List<int>? dsLoaiTru;
  /// Bộ đếm công việc
  int _boDem = 0;
  /// Khi hoàn thành 1 công việc
  void Function()? _khiHoanThanh1Viec;
  /// Khi hoàn thành tất cả công việc
  void Function()? _khiHoanThanhTatCa;

  /// Bắt đầu tìm kiếm
  void batDauTimKiem({required void Function() khiXong1Viec, required void Function() khiXongTatCa}) {
    _khiHoanThanhTatCa = khiXongTatCa;
    _khiHoanThanh1Viec = khiXong1Viec;
    _boDem = 0;
  }

  /// Kiểm tra hoàn tất toàn bộ các công việc
  /// Công việc khi bắt đầu thì tăng bộ đếm lên 1, hoàn thành thì lại giảm 1.
  /// Bộ đếm về 0 thì là hoàn tất toàn bộ.
  void _kiemTraHoanTatToanBo() {
    _boDem -= 1;
    _khiHoanThanh1Viec?.call();
    if (_boDem == 0) {
      _khiHoanThanhTatCa?.call();
      _khiHoanThanhTatCa = null;
      _khiHoanThanh1Viec = null;
    }
  }

  Future<void> _napThongTinSach(List<Sach> danhSach) async {
    for (final Sach muc in danhSach) {
      final ThaoTacNapThongTinSach nap = ThaoTacNapThongTinSach(muc);
      await nap.napThongTin();
    }
  }

  void _tongHopKetQuaTimSach(List<Sach> dsTong, List<Sach> dsCon) {
    if (dsLoaiTru != null && dsLoaiTru!.isNotEmpty) {
      dsCon.removeWhere((muc) => dsLoaiTru!.contains(muc.maSo));
    }
    for (final Sach muc in dsCon) {
      final int stt = dsTong.indexWhere((element) => element.maSo == muc.maSo);
      if (stt < 0) {
        dsTong.add(muc);
      }
    }
  }

  /// Tìm kiếm sách theo tên (hoặc các điều kiện khác)
  Future<List<List<Sach>>> timKiemSach({
    required String tuKhoa,
    List<TacGia>? tacGia,
    List<DichGia>? dichGia,
    List<NhaXuatBan>? nxb,
    List<ViTriSach>? viTri,
    List<NhanSach>? nhan,
    SachNhieuTap? nhieuTap
  }) async {
    _boDem += 1;
    List<Sach> ketQuaSach = await CoSoDuLieu().timKiemSach(
      tuKhoa: tuKhoa,
      tacGia: tacGia?.map((e) => e.maSo).toList(),
      dichGia: dichGia?.map((e) => e.maSo).toList(),
      nxb: nxb?.map((e) => e.maSo).toList(),
      viTri: viTri?.map((e) => e.maSo).toList(),
      nhan: nhan,
      nhieuTap: nhieuTap?.maSo
    );
    List<Sach> ketQuaISBN = await CoSoDuLieu().timKiemSachTheoISBN(
      tuKhoa: tuKhoa,
      tacGia: tacGia?.map((e) => e.maSo).toList(),
      dichGia: dichGia?.map((e) => e.maSo).toList(),
      nxb: nxb?.map((e) => e.maSo).toList(),
      viTri: viTri?.map((e) => e.maSo).toList(),
      nhan: nhan,
      nhieuTap: nhieuTap?.maSo
    );
    List<Sach> ketQuaDanhDau = await CoSoDuLieu().timKiemSachTheoDanhDau(
      tuKhoa: tuKhoa,
      tacGia: tacGia?.map((e) => e.maSo).toList(),
      dichGia: dichGia?.map((e) => e.maSo).toList(),
      nxb: nxb?.map((e) => e.maSo).toList(),
      viTri: viTri?.map((e) => e.maSo).toList(),
      nhan: nhan,
      nhieuTap: nhieuTap?.maSo
    );
    final List<Sach> dsTongHop = [];
    _tongHopKetQuaTimSach(dsTongHop, ketQuaSach);
    _tongHopKetQuaTimSach(dsTongHop, ketQuaISBN);
    _tongHopKetQuaTimSach(dsTongHop, ketQuaDanhDau);
    _napThongTinSach(dsTongHop);
    List<Sach> kqSach = [];
    List<Sach> kqIsbn = [];
    List<Sach> kqDanhDau = [];
    for (final Sach muc in ketQuaSach) {
      kqSach.add(dsTongHop.firstWhere((element) => element.maSo == muc.maSo));
    }
    for (final Sach muc in ketQuaISBN) {
      kqIsbn.add(dsTongHop.firstWhere((element) => element.maSo == muc.maSo));
    }
    for (final Sach muc in ketQuaDanhDau) {
      kqDanhDau.add(dsTongHop.firstWhere((element) => element.maSo == muc.maSo));
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return [kqSach, kqIsbn, kqDanhDau];
  }

  /// Tìm kiếm tác giả
  Future<List<TacGia>> timKiemTacGia({
    required String tuKhoa,
    required List<TacGia> daCo
  }) async {
    _boDem += 1;
    List<TacGia> ketQua = [];
    if (tuKhoa.isNotEmpty) {
      // ketQua.add(TacGia.taoDuLieuGia(chiSo: 1));
      // ketQua.add(TacGia.taoDuLieuGia(chiSo: 2));
      ketQua = await CoSoDuLieu().timKiemTacGia(tuKhoa);
    }
    List<TacGia> ketQuaCuoi = [];
    for (final TacGia tg in ketQua) {
      final int stt = daCo.indexWhere((element) => element.maSo == tg.maSo);
      if (stt < 0) {
        ketQuaCuoi.add(tg);
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQuaCuoi;
  }

  /// Tìm kiếm dịch giả
  Future<List<DichGia>> timKiemDichGia({
    required String tuKhoa,
    required List<DichGia> daCo
  }) async {
    _boDem += 1;
    List<DichGia> ketQua = [];
    if (tuKhoa.isNotEmpty) {
      // ketQua.add(DichGia.taoDuLieuGia(chiSo: 1));
      // ketQua.add(DichGia.taoDuLieuGia(chiSo: 2));
      ketQua = await CoSoDuLieu().timKiemDichGia(tuKhoa);
    }

    List<DichGia> ketQuaCuoi = [];
    for (final DichGia dg in ketQua) {
      final int stt = daCo.indexWhere((element) => element.maSo == dg.maSo);
      if (stt < 0) {
        ketQuaCuoi.add(dg);
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQuaCuoi;
  }

  /// Tìm kiếm nhà xuất bản
  Future<List<NhaXuatBan>> timKiemNXB({
    required String tuKhoa,
    required List<NhaXuatBan> daCo
  }) async {
    _boDem += 1;
    List<NhaXuatBan> ketQua = [];
    if (tuKhoa.isNotEmpty) {
      // ketQua.add(NhaXuatBan.taoDuLieuGia(chiSo: 1));
      // ketQua.add(NhaXuatBan.taoDuLieuGia(chiSo: 2));
      ketQua = await CoSoDuLieu().timKiemNXB(tuKhoa);
    }

    List<NhaXuatBan> ketQuaCuoi = [];
    for (final NhaXuatBan nxb in ketQua) {
      final int stt = daCo.indexWhere((element) => element.maSo == nxb.maSo);
      if (stt < 0) {
        ketQuaCuoi.add(nxb);
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQuaCuoi;
  }

  /// Tìm kiếm vị trí sách
  Future<List<ViTriSach>> timKiemViTri({
    required String tuKhoa,
    required List<ViTriSach> daCo
  }) async {
    _boDem += 1;
    List<ViTriSach> ketQua = [];
    if (tuKhoa.isNotEmpty) {
      // ketQua.add(ViTriSach.taoDuLieuGia(chiSo: 1));
      // ketQua.add(ViTriSach.taoDuLieuGia(chiSo: 2));
      ketQua = await CoSoDuLieu().timKiemViTriSach(tuKhoa);
    }
    List<ViTriSach> ketQuaCuoi = [];
    for (final ViTriSach vt in ketQua) {
      final int stt = daCo.indexWhere((element) => element.maSo == vt.maSo);
      if (stt < 0) {
        ketQuaCuoi.add(vt);
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQuaCuoi;
  }

  /// Tìm kiếm tên nhãn
  Future<List<NhanSach>> timKiemTenNhan({
    required String tuKhoa,
    required List<NhanSach> daCo
  }) async {
    _boDem += 1;
    List<NhanSach> ketQua = [];
    if (tuKhoa.isNotEmpty) {
      // ketQua.add(NhanSach.taoDuLieuGia(chiSo: 1));
      // ketQua.add(NhanSach.taoDuLieuGia(chiSo: 2));
      ketQua = await CoSoDuLieu().timKiemTenNhan(tuKhoa);
    }
    List<NhanSach> ketQuaCuoi = [];
    for (final NhanSach nhan in ketQua) {
      final int stt = daCo.indexWhere((element) => element.maSo == nhan.maSo);
      if (stt < 0) {
        ketQuaCuoi.add(nhan);
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQuaCuoi;
  }

  /// Tìm kiếm các giá trị nhãn theo tên nhãn đã chọn
  Future<List<String>> timKiemGtNhan({
    required String tuKhoa,
    required NhanSach tenNhan
  }) async {
    _boDem += 1;
    List<String> ketQua = [];
    // ketQua.add("Gia tri nhan 01");
    // ketQua.add("Gia tri nhan 02");
    ketQua = await CoSoDuLieu().timKiemGtNhan(tuKhoa, tenNhan);
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQua;
  }

  /// Tìm kiếm chuỗi sách nhiều tập
  Future<List<SachNhieuTap>> timKiemNhieuTap({
    required String tuKhoa
  }) async {
    _boDem += 1;
    List<SachNhieuTap> ketQua = [];
    if (tuKhoa.isNotEmpty) {
      // ketQua.add(SachNhieuTap.taoDuLieuGia(chiSo: 1));
      // ketQua.add(SachNhieuTap.taoDuLieuGia(chiSo: 2));
      ketQua = await CoSoDuLieu().timKiemSachNhieuTap(tuKhoa);
    }
    Future.delayed(const Duration(milliseconds: 100)).then((_) => _kiemTraHoanTatToanBo());
    return ketQua;
  }

}