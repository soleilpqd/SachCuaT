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

/// Vòng lặp giới hạn.
/// Ai cũng chắc chắn logic là đúng, cho đến khi gặp lỗi.
/// Công cụ của Dev, dùng thay thế cho while, tránh lỗi lặp vô hạn.
/// - [thucThi]: block cần lặp, trả về `false` để thoát khỏi vòng lặp. Tham số: [giaTriTraVe], thêm giá trị trả về vào List này. List này được trả về khi ra khỏi vòng lặp.
///   - `while (dk) { do_A }`: tương đương `do_A({ if (!dk) return false; do(); return true; })`
///   - `do { do_A } while (dk)`: tương đương `do_A({ do(); return dk; })`
/// - [gioiHan]: giới hạn số vòng lặp (mặc định theo giá trị `VongLapGioiHan.gioiHanMacDinh`).
/// - [suDungAssert]: `true` để kiểm tra bằng assert (throw/raise exception/error nếu vòng lặp vượt giới hạn), `false` thì kết thúc vòng lặp như là thành công.
class VongLapGioiHan {

  static int gioiHanMacDinh = 500;

  /// `while`
  static List<T> lap<T>(bool Function(List<T> giaTriTraVe) thucThi, {int? gioiHan, bool suDungAssert = true}) {
    bool tiepTuc = true;
    int dem = 0;
    int gh = gioiHan ?? gioiHanMacDinh;
    List<T> kq = List.empty();
    while (tiepTuc) {
      if (suDungAssert) {
        assert(dem <= gh, "Vòng lặp quá giới hạn, cần kiểm tra lại!");
      }
      tiepTuc = thucThi.call(kq);
      dem += 1;
      if (!suDungAssert) {
        if (dem > gh) {
          tiepTuc = false;
        }
      }
    }
    return kq;
  }

  /// `while` async
  static Future<List<T>> lapKoDB<T>(Future<bool> Function(List<T> giaTriTraVe) thucThi, {int? gioiHan, bool suDungAssert = true}) async {
    bool tiepTuc = true;
    int dem = 0;
    int gh = gioiHan ?? gioiHanMacDinh;
    List<T> kq = List.empty();
    while (tiepTuc) {
      if (suDungAssert) {
        assert(dem <= gh, "Vòng lặp quá giới hạn, cần kiểm tra lại!");
      }
      tiepTuc = await thucThi.call(kq);
      dem += 1;
      if (!suDungAssert) {
        if (dem > gh) {
          tiepTuc = false;
        }
      }
    }
    return kq;
  }

  final dynamic Function(VongLapGioiHan, List<dynamic>?)? thucThi;
  final Future<dynamic> Function(VongLapGioiHan, List<dynamic>?)? thucThiKoDB;
  final int _gioiHan;

  VongLapGioiHan.dongbo(this.thucThi, {int? gioiHan}) : thucThiKoDB = null, _gioiHan = gioiHan ?? gioiHanMacDinh;
  VongLapGioiHan.koDongBo(this.thucThiKoDB, {int? gioiHan}) : thucThi = null, _gioiHan = gioiHan ?? gioiHanMacDinh;

  int _dem = 0;

  /// Xử lý đệ quy
  /// Thay vì đệ quy vào chính hàm đó, đệ quy thông qua 1 đối tượng VongLapGioiHan
  dynamic tienHanh(List<dynamic>? thamSo) {
    assert(thucThi != null, "Thiếu tham số `thucThi`");
    assert(_dem <= _gioiHan, "Đệ quy quá giới hạn, cần kiểm tra lại!");
    final dynamic kq = thucThi?.call(this, thamSo);
    _dem += 1;
    return kq;
  }

  Future<dynamic> tienHanhKoDB(List<dynamic>? thamSo) async {
    assert(thucThiKoDB != null, "Thiếu tham số `thucThi`");
    assert(_dem <= _gioiHan, "Đệ quy quá giới hạn, cần kiểm tra lại!");
    final dynamic kq = await thucThiKoDB?.call(this, thamSo);
    _dem += 1;
    return kq;
  }

}
