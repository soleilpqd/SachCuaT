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

/// Theo dõi điều khiển cơ sở
mixin TheoDoiDieuKhienCoSo {

  /// Điều khiển cơ sở thay đổi thuộc tính.
  /// - [nguon] điều khiển gửi thông báo.
  /// - [cacGiaTri] các giá trị thay đổi.
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {}

}

/// Thuộc tính điều khiển cơ sở
enum ThuocTinhDkCoSo {
  /// Khả dụng
  khaDung;
}

extension ThuocTinhEnum on List<Enum> {

  /// Chuyển đổi sang danh sách String
  /// đính kèm thêm [khac] nếu có
  List<String> chuyenDoiSangDS({List<String>? khac}) {
    List<String> ketQua = khac ?? [];
    ketQua.addAll(map((e) => e.name));
    return ketQua;
  }

  /// Tìm case theo tên trong danh sách
  Enum? timThuocTinh(String giaTriTho) => firstWhere((element) => element.name == giaTriTho);

}

/// Điều khiển cơ sở
class DieuKhienCoSo {

  /// Thuộc tính gốc, dùng trong `daThayDoi`
  final Map<String, dynamic> thuocTinhGoc = {};
  /// Danh sách các thuộc tính
  final Map<String, dynamic> cacThuocTinh = {};
  /// Bộ lưu trữ tạm thuộc tính khi thay đổi giữa `batDauSua` và `ketThucSua`
  final Map<String, dynamic> _thuocTinhTam = {};
  bool _dangSua = false;
  /// Các đối tượng theo dõi thay đổi
  final List<TheoDoiDieuKhienCoSo> _dsTheoDoi = [];
  /// Trường thông tin này là tạo mới hay sửa lại.
  final bool laDieuKhienMoi;

  /// Khả dụng
  bool get khaDung => this[ThuocTinhDkCoSo.khaDung.name] ?? true;
  /// Khả dụng
  set khaDung(bool gt) => this[ThuocTinhDkCoSo.khaDung.name] = gt;

  /// CONSTRUCTOR
  DieuKhienCoSo({
    this.laDieuKhienMoi = false,
    Map<String, dynamic> thuocTinhBanDau = const {},
    bool khaDung = true
  }) {
    for (final muc in thuocTinhBanDau.keys) {
      cacThuocTinh[muc] = thuocTinhBanDau[muc];
    }
    cacThuocTinh[ThuocTinhDkCoSo.khaDung.name] = khaDung;
    for (final muc in cacThuocTinh.keys) {
      thuocTinhGoc[muc] = cacThuocTinh[muc];
    }
  }

  /// DESTRUCTOR
  void dispose() {
    cacThuocTinh.clear();
    _thuocTinhTam.clear();
    _dsTheoDoi.clear();
  }

  /// Để subclass: danh sách các thuộc tính để kiểm tra trong `daThayDoi`
  List<String> dsThuocTinhGiaTri() => [];
  /// DS thuộc tính mà điều khiển này xử lý
  List<String> dsThuocTinh() => ThuocTinhDkCoSo.values.chuyenDoiSangDS();
  /// Lọc các giá trị thuộc tính mà điều khiển này xử lý
  Map<String, dynamic> locCacThuocTinh(Map<String, dynamic> nguon) {
    Map<String, dynamic> ketQua = {};
    List<String> cacThuocTinh = dsThuocTinh();
    for (final muc in nguon.keys) {
      if (cacThuocTinh.isEmpty || cacThuocTinh.contains(muc)) {
        ketQua[muc] = nguon[muc];
      }
    }
    return ketQua;
  }

  /// Đã thay đổi
  bool get daThayDoi {
    assert(!_dangSua, "Đang chỉnh sửa (không dùng `daThayDoi` giữa `batDauSua` và `ketThucSua`)");
    List<String> dsThuocTinh = dsThuocTinhGiaTri();
    if (dsThuocTinh.isEmpty) {
      dsThuocTinh.addAll(thuocTinhGoc.keys);
    }
    for (final muc in cacThuocTinh.keys) {
      if (!dsThuocTinh.contains(muc)) {
        dsThuocTinh.add(muc);
      }
    }
    for (final muc in dsThuocTinh) {
      if (muc == ThuocTinhDkCoSo.khaDung.name) {
        continue;
      }
      if (thuocTinhGoc[muc] != cacThuocTinh[muc]) {
        return true;
      }
    }
    return false;
  }

  dynamic operator[](String tenThuocTinh) {
    return cacThuocTinh[tenThuocTinh];
  }

  void operator[]=(String tenThuocTinh, dynamic giaTri) {
    if (_dangSua) {
      _thuocTinhTam[tenThuocTinh] = giaTri;
    } else {
      apDungVaThongBao({tenThuocTinh: giaTri});
    }
  }

  /// Bắt đầu sửa. Không thông báo cho đến hàm `ketThucSua`
  void batDauSua() {
    _thuocTinhTam.clear();
    _dangSua = true;
  }

  /// Kết thúc sửa. Áp dụng thay đổi và thông báo.
  void ketThucSua() {
    _dangSua = false;
    apDungVaThongBao(_thuocTinhTam);
  }

  /// Thêm đối tượng theo dõi thông báo.
  void themTheoDoi(TheoDoiDieuKhienCoSo doiTuong) {
    if (!_dsTheoDoi.contains(doiTuong)) {
      _dsTheoDoi.add(doiTuong);
    }
  }

  /// Bỏ đối tượng theo dõi thông báo
  void boTheoDoi(TheoDoiDieuKhienCoSo doiTuong) {
    _dsTheoDoi.remove(doiTuong);
  }

  /// Áp dụng và thông báo các thay đổi.
  /// Dùng cho subclass. Không gọi trực tiếp.
  void apDungVaThongBao(Map<String, dynamic> cacGiaTri) {
    Map<String, dynamic> giaTriThayDoi = {};
    for (final muc in cacGiaTri.keys) {
      final dynamic giaTri = cacGiaTri[muc];
      final dynamic giaTriHienTai = cacThuocTinh[muc];
      if (giaTri != giaTriHienTai) {
        if (giaTri == null) {
          cacThuocTinh.remove(muc);
        } else {
          cacThuocTinh[muc] = giaTri;
        }
        giaTriThayDoi[muc] = giaTri;
      }
    }
    if (giaTriThayDoi.isEmpty) {
      return;
    }
    thongBao(giaTriThayDoi);
  }

  /// Chỉ gửi thông báo (dùng cho subclass, ko gọi trực tiếp)
  void thongBao(Map<String, dynamic> cacGiaTri) {
    for (final doiTuong in _dsTheoDoi) {
      doiTuong.dieuKhienCoSoThayDoiThuocTinh(this, cacGiaTri);
    }
  }

}

/// Điều khiển trung tâm: thay đổi thuộc tính 1 loạt các điều khiển con
class DieuKhienTrungTam {

  /// Danh sách điều khiển con
  final List<DieuKhienCoSo> dsDieuKhien;

  /// CONSTRUCTOR
  DieuKhienTrungTam(this.dsDieuKhien);

  /// DESTRUCTOR
  void dispose() {
    dsDieuKhien.clear();
  }

  /// Gửi thông báo
  void thongBao(Map<String, dynamic> cacGiaTri) {
    for (final muc in dsDieuKhien) {
      _thongBaoDK(cacGiaTri, muc);
    }
  }

  // Lọc ra các thuộc tính mà diều khiển xử lý
  // để gán giá trị và thông báo
  void _thongBaoDK(Map<String, dynamic> cacGiaTri, DieuKhienCoSo dk) {
    Map<String, dynamic> giaTriCuoi = dk.locCacThuocTinh(cacGiaTri);
    if (giaTriCuoi.isNotEmpty) {
      dk.apDungVaThongBao(giaTriCuoi);
    }
  }

}

/// StatefulWidget cơ sở: bao gồm 1 điều khiển
abstract class GiaoDienCoSo<T extends DieuKhienCoSo> extends StatefulWidget {

  /// Điều khiển
  final T? dieuKhien;

  /// CONSTRUCTOR
  const GiaoDienCoSo({super.key, this.dieuKhien});

}

/// State cơ sở bao gồm các hàm theo dõi thay đổi giá trị của điều khiển
abstract class TrangThaiCoSo<T extends GiaoDienCoSo> extends State<T> with TheoDoiDieuKhienCoSo {

  @override
  void initState() {
    super.initState();
    widget.dieuKhien?.themTheoDoi(this);
  }

  @override
  void dispose() {
    super.dispose();
    widget.dieuKhien?.boTheoDoi(this);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.dieuKhien?.boTheoDoi(this);
    widget.dieuKhien?.themTheoDoi(this);
  }

  /// Mặc định `setState` khi điều khiển thay đổi giá trị.
  /// Subclass có thể override nếu chỉ `setState` với 1 số thuộc tính.
  @override
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {
    if (nguon == widget.dieuKhien) {
      setState(() {});
    }
  }

}
