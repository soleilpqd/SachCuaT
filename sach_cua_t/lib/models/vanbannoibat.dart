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

import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/vonglapgioihan.dart';

/// Văn bản nổi bật
class VanBanNoiBat {

  /// Văn bản đầy đủ
  final String vanBanDayDu;
  /// Văn bản nổi bật
  final List<String> vanBanNoiBat;
  /// Thời điểm đã chọn
  final int? daChon;
  /// Danh sách vị trí văn bản nổi bật trong văn bản đầy đủ
  /// chính xác
  final List<(int, int)> dsViTriCx = [];
  /// Danh sách vị trí văn bản nổi bật trong văn bản đầy đủ
  /// Không dấu
  final List<(int, int)> dsViTriKd = [];
  /// Dữ liệu đính kèm (dùng sắp xếp kết quả tìm kiếm)
  final dynamic duLieuDinhKem;

  static (int, int) _timViTriNoiBatNhoNhat(String vbDayDu, List<String> vbNoiBat) {
    (int, int) ketQua = (-1, -1);
    int stt = 0;
    for (final String vbNb in vbNoiBat) {
      if (vbNb.isEmpty) {
        continue;
      }
      final int vt = vbDayDu.indexOf(vbNb);
      if (vt >= 0) {
        if (ketQua.$1 < 0 || ketQua.$1 > vt) {
          ketQua = (vt, stt);
        }
      }
      stt += 1;
    }
    return ketQua;
  }

  /// Xây dựng vị trí của văn bản nổi bật trong văn bản đầy đủ
  static List<(int, int)> xayDungViTriNoiBat(String vbDayDu, List<String> vbNoiBat) {
    String dem = vbDayDu;
    List<(int, int)> ketQua = [];
    if (vbDayDu.isEmpty || vbNoiBat.isEmpty) {
      return ketQua;
    }
    int vtHt = 0;
    VongLapGioiHan.lap((_) {
      if (dem.isEmpty) { return false; }
      final (int, int) vt = _timViTriNoiBatNhoNhat(dem, vbNoiBat);
      if (vt.$1 >= 0) {
        vtHt += vt.$1;
        final String vbNb = vbNoiBat[vt.$2];
        ketQua.add((vtHt, vbNb.length));
        vtHt += vbNb.length;
        dem = dem.substring(vt.$1 + vbNb.length);
      } else {
        dem = "";
        return false;
      }
      return true;
    });
    return ketQua;
  }

  VanBanNoiBat({required this.vanBanDayDu, required this.vanBanNoiBat, this.daChon, this.duLieuDinhKem}) {
    dsViTriCx.addAll(VanBanNoiBat.xayDungViTriNoiBat(vanBanDayDu, vanBanNoiBat));
    final String vbDd = LinhTinh.loaiBoDautiengViet(vanBanDayDu);
    final List<String> vbNb = vanBanNoiBat.map((e) => LinhTinh.loaiBoDautiengViet(e)).toList();
    bool vbNbLaKd = true;
    for (int stt = 0; stt < vbNb.length; stt += 1) {
      if (vbNb[stt] != vanBanNoiBat[stt]) {
        vbNbLaKd = false;
        break;
      }
    }
    if (vbDd == vanBanDayDu && vbNbLaKd) {
      dsViTriKd.addAll(dsViTriCx);
    } else {
      dsViTriKd.addAll(VanBanNoiBat.xayDungViTriNoiBat(vbDd, vbNb));
    }
  }

}

/// Sắp xếp danh sách văn bản nổi bật
extension SapXepDSVbNoiBat on List<VanBanNoiBat> {

  int _soSanh2ViTri(List<(int, int)> dsvt1, List<(int, int)> dsvt2) {
    int cmp = 0;
    if (dsvt1.isNotEmpty && dsvt2.isNotEmpty) {
      final int vt1 = dsvt1.first.$1;
      final int vt2 = dsvt2.first.$1;
      cmp = vt1.compareTo(vt2);
      if (cmp != 0) {
        return cmp;
      }
    }
    cmp = dsvt1.length.compareTo(dsvt2.length);
    if (cmp != 0) {
      return -cmp;
    }
    for (int idx = 0; idx < dsvt1.length; idx += 1) {
      cmp = dsvt1[idx].$1.compareTo(dsvt2[idx].$1);
      if (cmp != 0) {
        return cmp;
      }
    }
    return cmp;
  }

  /// Sắp xếp danh sách theo tiêu chí:
  /// - Thời điểm đã chọn: số lớn nhất lên trên (gần đây nhất)
  /// - So sánh các vị trí nổi bật (so sánh vị trí chính xác trước rồi đến vị trí không dấu)
  ///   - Vị trí văn bản nổi bật đầu tiên nhỏ hơn.
  ///   - (Cùng vị trí đầu tiên) Số lượng văn bản nội bật (nhiều hơn lên trên).
  ///   - (Cùng vị trí đầu tiên, cùng số lượng): so sánh từng vị trí, cái nào nhỏ hơn lên trên.
  /// - So sánh văn bản đầy đủ (theo thứ tự chữ cái).
  void sapXep() {
    if (length < 2) {
      return;
    }
    sort((one, two) {
      final int chon1 = one.daChon ?? -1;
      final int chon2 = two.daChon ?? -1;
      int cmp = chon1.compareTo(chon2);
      if (cmp != 0) {
        return -cmp;
      }
      cmp = _soSanh2ViTri(one.dsViTriCx, two.dsViTriCx);
      if (cmp != 0) {
        return cmp;
      }
      cmp = _soSanh2ViTri(one.dsViTriKd, two.dsViTriKd);
      if (cmp != 0) {
        return cmp;
      }
      return one.vanBanDayDu.compareTo(two.vanBanDayDu);
    });
  }

}
