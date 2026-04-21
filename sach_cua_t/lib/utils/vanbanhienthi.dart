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
import 'package:sach_cua_t/utils/common.dart';

/// Từ khoá văn bản hiển thị
enum TK {
  /// Sách của T
  sachCuaT,
  /// Lưu chiểu
  luuChieu,
  /// Đăng ký xuất bản
  dkxb,
  /// Đã đọc xong
  daDocXong,
  /// Tên sách
  tenSach,
  /// Đóng
  dong,
  /// Không có kết quả
  khongCoKetQua,
  /// Máy ảnh không khả dụng hoặc không có quyền truy cập
  khongCoMayAnh,
  /// Thông tin sách
  thongTinSach,
  /// Hướng dẫn sử dụng ảnh: 1 chạm để chụp ảnh, 2 chạm để xoá ảnh
  hdsdAnh,
  /// Sách mới
  sachMoi,
  /// Tra cứu lưu chiểu
  traCuuLuuChieu,
  /// Tra cứu Đăng ký xuất bản
  traCuuDKXB,
  /// ISBN
  isbn,
  /// Tác giả
  tacGia,
  /// Dịch giả
  dichGia,
  /// Vị trí
  viTri,
  /// Đơn vị phát hành
  dvPhatHanh,
  /// Thông tin sách cơ bản
  thongTinSachCoBan,
  /// Giải thích thông tin sách cơ bản: Các thông tin sau có thể gồm nhiều mục, các mục cùng loại thông tin không được lặp lại. Có thể nhập các mục chung 1 dòng và phân cách bằng ';' (app tự động phân chia khi nhập xong).
  giaiThichThongTinCoBan,
  /// Giải thích vị trí: Mỗi vị trí tương ứng với 1 quyển sách vật lý (1 cuốn sách có thể có nhiều quyển để cùng 1 chỗ - vị trí có thể lặp lại). Có thể nhập các mục chung 1 dòng và phân cách bằng ';' (app tự động phân chia khi nhập xong).
  giaiThichViTri,
  /// Tiêu đề sách nhiều tập
  tieuDeSachNhieuTap,
  /// Giải thích phần sách nhiều tập
  giaiThichSachNhieuTap,
  /// Tiêu đề nhãn
  tieuDeNhan,
  /// Giải thích nhãn
  giaiThichNhan,
  /// Tiêu đề đánh dấu
  tieuDeDanhDau,
  /// Giải thích đánh dấu
  giaiThichDanhDau,
  /// Tiêu đề đánh dấu (từng mục)
  danhDau,
  /// Lỗi lưu sách (không thể lưu)
  loiKhongLuuSach,
  /// Lỗi lưu sách (cần xem lại)
  loiXemLaiTruocKhiLuuSach,
  /// Cứ lưu
  cuLuu,
  /// Thiếu thông tin
  thieuThongTin,
  /// Tên sách đã tồn tại
  tenSachDaTonTai,
  /// Sách không tồn tại
  sachKhongTonTai,
  /// Lưu
  luu,
  /// Xác nhận lưu sách khi quay lại
  xacNhanLuu,
  /// Chọn sách để lập nhóm/chuỗi chuỗchuỗi
  chonSachLapChuoi,
  /// Xoá sách khỏi chuỗi
  roiChuoi,
  /// Tập số # trong chuỗi sách # tập
  namTrongChuoi,
  /// Ghi chú chuỗi sách
  ghiChuChuoi,
  /// Tập còn thiếu (Các tập còn thiếu: #_)
  tapConThieu,
  /// Luôn hiển thị
  luonHienThi,
  /// Tập số
  tapSo,
  /// Hiển thị danh sách tập đầy đủ (Hiển thị đầy đủ #_ tập)
  hienThiDSTapDayDu,
  /// Tìm kiếm,
  timKiem,
  /// Số lượng kết quả (Số lượng kết quả: #_)
  soLuongKetQua,
  /// Thống kê
  thongKe,
  /// Tên nhãn
  tenNhan,
  /// Giá trị nhãn
  giaTriNhan,
  /// Lọc theo tác giả (Tác giả: #_)
  locTacGia,
  /// Lọc theo dịch giả (Dịch giả: #_)
  locDichGia,
  /// Lọc theo đơn vị phát hành (Phát hành: #_)
  locNxb,
  /// Lọc theo vị trí sách (Vị trí: #_)
  locViTri,
  /// Lọc theo tên nhãn (Nhãn `#_` có giá trị)
  locTenNhan,
  /// Lọc theo tên và giá trị nhãn (Nhãn `#_`=`#_`)
  locGiaTriNhan,
  /// Lọc theo nhiều tập (Chuỗi sách: #_)
  locNhieuTap,
  /// Xoá sách
  xoaSach,
  /// Xác nhận xoá
  xacNhanXoa,
  /// Chưa có sách nào
  chuaCoSach,
  /// Hướng dẫn
  huongDan,
  /// Giới thiệu
  gioiThieu,
  /// Gần đây
  ganDay
  ;
}

/// Văn bản hiển thị
class Vbht {

  /// Từ khoá
  final String tuKhoa;
  /// Văn bản hiển thị
  String _vanBan = "";
  /// Văn bản hiển thị
  String get vanBan => _vanBan;

  /// Xử lý khi nạp xong
  Function(String)? khiXong;
  /// Bộ đệm
  final BoDemVbht? dem;
  /// Tham số
  final List<String>? thamSo;

  /// Áp dụng tham số
  void _apDungThamSo() {
    if (thamSo != null && thamSo!.isNotEmpty) {
      final String tmp = _vanBan;
      _vanBan = LinhTinh.dienVaoChoTrong(_vanBan, thamSo!);
      if (tmp == tmp) {
        _vanBan += " ${thamSo!}";
      }
    }
  }

  /// CONSTRUCTOR
  /// Nếu [trucTiep] = true thì [vanBan] là [tuKhoa].
  /// [trucTiep] = false thì dùng [tuKhoa] để nạp nội dung từ `VanBanHienThi`, sau đó chạy [khiXong]
  Vbht({required this.tuKhoa, bool trucTiep = true, this.dem, this.thamSo, Future<String?>? nguon}) {
    _vanBan = tuKhoa;
    if (!trucTiep) {
      String? vbDem = dem?[tuKhoa];
      if (vbDem != null) {
        _vanBan = vbDem;
        _apDungThamSo();
      } else {
        VanBanHienThi().napVanBanHienThi(tuKhoa).then((value) {
          _vanBan = value;
          dem?[tuKhoa] = value;
          _apDungThamSo();
          khiXong?.call(value);
        });
      }
    } else if (nguon != null) {
      nguon.then((giaTri) {
        _vanBan = giaTri ?? "";
        _apDungThamSo();
        khiXong?.call(_vanBan);
      });
    }
  }

  /// CONVENIENCE CONSTRUCTOR: văn bản trực tiếp
  Vbht.trucTiep(String tk) : this(tuKhoa: "", trucTiep: true);
  /// CONVENIENCE CONSTRUCTOR: văn bản gián tiếp từ nguồn khác
  Vbht.gianTiep(Future<String?> tk) : this(tuKhoa: "", trucTiep: true, nguon: tk);
  /// CONVENIENCE CONSTRUCTOR: văn bản cần nạp từ CSDL thông qua từ khoá
  Vbht.tuKhoa(TK tk, {BoDemVbht? dem, List<String>? ts}) : this(tuKhoa: tk.name, trucTiep: false, dem: dem, thamSo: ts);

}

/// Danh sách văn bản hiển thị
/// CHƯA/KHÔNG DÙNG ĐẾN
class DsVbht {

  Map<String, String> _dsVanBanHienThi = {};
  Function()? khiXong;

  DsVbht(List<TK> dsTuKhoa) {
    for (final muc in dsTuKhoa) {
      _dsVanBanHienThi[muc.name] = muc.name;
    }
    VanBanHienThi().napDSVanBanHienThi(_dsVanBanHienThi).then((value) {
      _dsVanBanHienThi = value;
      khiXong?.call();
    });
  }

  String operator [](TK tuKhoa) {
    String? ketQua = _dsVanBanHienThi[tuKhoa.name];
    assert(ketQua != null, "`${tuKhoa.name}` chưa được khai báo.");
    return ketQua!;
  }

}

/// Bộ đệm Văn bản hiển thị
/// (lưu các văn bản đã nạp từ CSDL, dùng chung cho các VbhtWidget trong cùng 1 màn hình tránh việc truy vấn CSDL nhiều lần khi update state)
class BoDemVbht {

  final Map<String, String> _dsVanBanHienThi = {};

  String? operator[](String tuKhoa) {
    return _dsVanBanHienThi[tuKhoa];
  }

  void operator[]=(String tuKhoa, String giaTri) {
    _dsVanBanHienThi[tuKhoa] = giaTri;
  }

  /// Khởi tạo lại
  void khoiTaoLai() {
    _dsVanBanHienThi.clear();
  }

}

/// Bộ quản lý văn bản hiện thị (nạp văn bản từ CSDL)
class VanBanHienThi {

  VanBanHienThi._internal();
  static final VanBanHienThi _duyNhat = VanBanHienThi._internal();
  factory VanBanHienThi() { return _duyNhat; }

  List<String> phanLoai = ["vi"];

  /// In ra tất cả các từ khoá -> hỗ trợ tạo tệp CSV
  void printAll() {
    for (final muc in TK.values) {
      print("${muc.name},$phanLoai,");
    }
  }

  /// Nạp văn bản hiển thị từ CSDL
  Future<String> napVanBanHienThi(String tuKhoa) async {
    for (final pl in phanLoai) {
      final ketQua = await CoSoDuLieu().truyVanVanBanHienThi(tuKhoa, pl);
      if (ketQua != null && ketQua.isNotEmpty) {
        return ketQua;
      }
    }
    return tuKhoa;
  }

  /// Nạp 1 loạt văn bản hiển thị từ CSDL
  Future<Map<String, String>> napDSVanBanHienThi(Map<String, String> dsTuKhoa) async {
    Map<String, String> ketQua = {};
    for (final tuKhoa in dsTuKhoa.keys) {
      ketQua[tuKhoa] = await napVanBanHienThi(tuKhoa);
    }
    return ketQua;
  }

  /// Khởi tạo List<String> thành Map<String, String> với giá trị của map là chính từ khoá.
  static Map<String, String> khoiTaoDSTuKhoa(List<String> dsTuKhoa) {
    Map<String, String> ketQua = {};
    for (final muc in dsTuKhoa) {
      ketQua[muc] = muc;
    }
    return ketQua;
  }

}
