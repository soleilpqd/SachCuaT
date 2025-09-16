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

/// Văn bản nổi bật
class VanBanNoiBat {

  /// Văn bản đầy đủ
  final String vanBanDayDu;
  /// Văn bản nổi bật
  final String vanBanNoiBat;
  /// Thời điểm đã chọn
  final int? daChon;
  /// Danh sách vị trí văn bản nổi bật trong văn bản đầy đủ
  /// chính xác
  final List<int> dsViTriCx = [];
  /// Danh sách vị trí văn bản nổi bật trong văn bản đầy đủ
  /// Không dấu
  final List<int> dsViTriKd = [];

  /// Xây dựng vị trí của văn bản nổi bật trong văn bản đầy đủ
  static List<int> xayDungViTriNoiBat(String vbDayDu, String vbNoiBat) {
    String dem = vbDayDu;
    List<int> ketQua = [];
    int vtHt = 0;
    while (dem.isNotEmpty) {
      final int vt = dem.indexOf(vbNoiBat);
      if (vt >= 0) {
        vtHt += vt;
        ketQua.add(vtHt);
        vtHt += vbNoiBat.length;
        dem = dem.substring(vt + vbNoiBat.length);
      } else {
        dem = "";
      }
    }
    return ketQua;
  }

  VanBanNoiBat({required this.vanBanDayDu, required this.vanBanNoiBat, this.daChon}) {
    dsViTriCx.addAll(VanBanNoiBat.xayDungViTriNoiBat(vanBanDayDu, vanBanNoiBat));
    final String vbDd = LinhTinh.loaiBoDautiengViet(vanBanDayDu);
    final String vbNb = LinhTinh.loaiBoDautiengViet(vanBanNoiBat);
    if (vbDd == vanBanDayDu && vbNb == vanBanNoiBat) {
      dsViTriKd.addAll(dsViTriCx);
    } else {
      dsViTriKd.addAll(VanBanNoiBat.xayDungViTriNoiBat(vbDd, vbNb));
    }
  }

}

/// Sắp xếp danh sách văn bản nổi bật
extension SapXepDSVbNoiBat on List<VanBanNoiBat> {

  int _soSanh2ViTri(List<int> dsvt1, List<int> dsvt2) {
    int cmp = 0;
    if (dsvt1.isNotEmpty && dsvt2.isNotEmpty) {
      final int vt1 = dsvt1.first;
      final int vt2 = dsvt2.first;
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
      cmp = dsvt1[idx].compareTo(dsvt2[idx]);
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
