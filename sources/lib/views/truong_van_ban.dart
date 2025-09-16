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
import 'package:sach_cua_t/models/vanbannoibat.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_noi_bat.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Gợi ý văn bản cơ sở
abstract class GoiYVanBan {

  static double get chieuCaoHienThiGoiY => 125;

  /// Trả lại danh sách các vị trí (index) của danh sách gợi ý
  Future<List<String>> timKiemGoiY(String dauVao, TruongVanBan widget) async => [];

  /// Tiếp tục gợi ý sau khi đã chọn
  bool tiepTucGoiY(String dauVao, TruongVanBan widget) => false;

  /// Lấy văn bản nổi bật (đã cache) để hiển thị
  VanBanNoiBat? layVanBanNoiBat(String dayDu, String noiBat) => null;

  /// User đã chọn 1 gợi ý
  void daChonGoiY(String tuKhoa) {}

}

/// Thuộc tính trường văn bản
enum ThuocTinhTruongVanBan {
  /// Văn bản
  vanBan,
  /// Thông báo lỗi
  thongBaoLoi,
  /// Focus (con trỏ văn bản)
  focus,
  /// Trạng thái nút bên phải
  nutBenPhai;
}

/// Điều khiển trường văn bản
class DieuKhienTruongVanBan extends DieuKhienCoSo {

  String debugInfo = "";

  /// Đối tượng tạo danh sách gợi ý
  final GoiYVanBan? goiY;
  /// Quản lý focus
  final FocusNode focusNode = FocusNode();
  /// Quản lý nhập liệu
  final TextEditingController textEditingController = TextEditingController();
  /// Văn bản ban đầu
  final String vanBanBanDau;

  /// Đã thay đổi
  @override
  bool get daThayDoi {
    return vanBanBanDau != vanBan;
  }

  /// Khả dụng
  @override
  set khaDung(bool gt) {
    if (!khaDung) {
      focusNode.unfocus();
      focusNode.canRequestFocus = false;
    } else {
      focusNode.canRequestFocus = true;
    }
    super.khaDung = gt;
  }

  /// CONSTRUCTOR
  DieuKhienTruongVanBan({this.vanBanBanDau = "", this.goiY, super.khaDung, super.laDieuKhienMoi}) {
    textEditingController.text = vanBanBanDau;
    focusNode.addListener(_khiFocusThayDoi);
    textEditingController.addListener(_khiVanBanThayDoi);
    focusNode.unfocus();
    focusNode.canRequestFocus = khaDung;
  }

  /// DESTRUCTOR
  @override
  void dispose() {
    super.dispose();
    focusNode.removeListener(_khiFocusThayDoi);
    textEditingController.removeListener(_khiVanBanThayDoi);
    focusNode.dispose();
    textEditingController.dispose();
  }

  /// Xử lý nội bộ
  bool _coTheTheoDoiThayDoiVanBan = true;
  /// Văn bản
  String get vanBan => textEditingController.text;
  /// Văn bản
  set vanBan(String value) {
    textEditingController.text = value;
  }

  /// Focus (con trỏ văn bản)
  bool get focus => focusNode.hasFocus;
  /// Focus (con trỏ văn bản)
  set focus(bool newValue) {
    if (newValue) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
  }

  /// Thông báo lỗi
  Vbht? get thongBaoLoi => this[ThuocTinhTruongVanBan.thongBaoLoi.name];
  /// Thông báo lỗi
  set thongBaoLoi(Vbht? giaTri) => this[ThuocTinhTruongVanBan.thongBaoLoi.name] = giaTri;

  /// Trạng thái nút bên phải
  int? get trangThaiNutBenPhai => this[ThuocTinhTruongVanBan.nutBenPhai.name];
  /// Trạng thái nút bên phải
  set trangThaiNutBenPhai(int? giaTri) => this[ThuocTinhTruongVanBan.nutBenPhai.name] = giaTri;

  /// Xử lý khi văn bản thay đổi
  void _khiVanBanThayDoi() {
    if (_coTheTheoDoiThayDoiVanBan) {
      thongBao({ThuocTinhTruongVanBan.vanBan.name: vanBan});
    }
  }

  /// Xử lý khi focus thay đổi
  void _khiFocusThayDoi() {
    thongBao({ThuocTinhTruongVanBan.focus.name: focus});
  }

  @override
  void apDungVaThongBao(Map<String, dynamic> cacGiaTri) {
    Map<String, dynamic> dem = cacGiaTri;
    // Xử lý các thuộc tính ko lưu thông qua Map mặc định
    if (dem.containsKey(ThuocTinhTruongVanBan.focus.name)) {
      final dynamic gt = dem[ThuocTinhTruongVanBan.focus.name];
      if (gt != null && gt is bool) {
        dem.remove(ThuocTinhTruongVanBan.focus.name);
        focus = gt;
      }
    }
    if (dem.containsKey(ThuocTinhTruongVanBan.vanBan.name)) {
      final dynamic gt = dem[ThuocTinhTruongVanBan.focus.name];
      if (gt != null && gt is String) {
        dem.remove(ThuocTinhTruongVanBan.vanBan.name);
        vanBan = gt;
      }
    }
    super.apDungVaThongBao(dem);
  }

}

/// Trường văn bản
class TruongVanBan extends GiaoDienCoSo<DieuKhienTruongVanBan> {

  /// Tiêu đề
  final Vbht tieuDe;
  /// Kiểu bàn phím
  final TextInputType kieuBanPhim;
  /// Số ký tự tối đa
  final int? soKyTuToiDa;
  /// Kiểm soát ký tự nhập vào
  final List<TextInputFormatter>? kiemSoatNhapLieu;
  /// Hàm xây dựng nút bên phải theo trạng thái
  final Widget? Function(int? giaTri, bool khaDung)? xayDungNutBenPhai;

  /// CONSTRUCTOR
  TruongVanBan({
    required this.tieuDe,
    required DieuKhienTruongVanBan trinhDieuKhien,
    this.kieuBanPhim = TextInputType.text,
    this.soKyTuToiDa,
    this.kiemSoatNhapLieu,
    this.xayDungNutBenPhai,
  }) : super(key: GlobalKey(), dieuKhien: trinhDieuKhien);

  @override
  State<StatefulWidget> createState() => _TrangThaiTruongVanBan();

  Rect? timViTriCuaToi() {
    final GlobalKey? gKey = (key as GlobalKey?);
    return gKey?.timViTriCuaWidget();
  }

}

/// Trạng thái trường văn bản
class _TrangThaiTruongVanBan extends TrangThaiCoSo<TruongVanBan> {

  /// Điều khiển cơ sở thay đổi thuộc tính (`TheoDoiDieuKhienCoSo`)
  @override
  void dieuKhienCoSoThayDoiThuocTinh(DieuKhienCoSo nguon, Map<String, dynamic> cacGiaTri) {
    if (nguon == widget.dieuKhien) {
      if (
        cacGiaTri.keys.contains(ThuocTinhTruongVanBan.nutBenPhai.name) ||
        cacGiaTri.keys.contains(ThuocTinhTruongVanBan.thongBaoLoi.name) ||
        cacGiaTri.keys.contains(ThuocTinhDkCoSo.khaDung.name)
      ) {
        setState(() {});
      }
    }
  }

  /// Tìm gợi ý
  Future<List<String>> _timGoiY({int dem = 0}) async {
    final text = widget.dieuKhien?.vanBan ?? "";
    List<String> ketQua = await widget.dieuKhien!.goiY?.timKiemGoiY(text, widget) ?? [];
    if (widget.dieuKhien?.vanBan != text) { // Văn bản thay đổi trong khi tìm kiếm gợi ý
      if (dem > 1) { // Giới hạn số lần gọi lồng nhau
        ketQua = [];
      } else {
        ketQua = await _timGoiY(dem: dem + 1);
      }
    }
    return ketQua;
  }

  /// Lấy văn bản nổi bật để hiển thị
  VanBanNoiBat _layVanBanNoiBat(String dayDu, String noiBat) => widget.dieuKhien?.goiY?.layVanBanNoiBat(dayDu, noiBat) ?? VanBanNoiBat(vanBanDayDu: dayDu, vanBanNoiBat: noiBat);

  @override
  Widget build(BuildContext context) {
    final Vbht? tbLoi = widget.dieuKhien?.thongBaoLoi;
    List<Widget> mainChildren = [];
    // Tiêu đề
    mainChildren.add(VbhtWidget(text: widget.tieuDe, textAlign: TextAlign.left));
    // Text input
    mainChildren.add(
      RawAutocomplete<String>(
        focusNode: widget.dieuKhien!.focusNode,
        textEditingController: widget.dieuKhien!.textEditingController,
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return SizedBox(
            height: widget.soKyTuToiDa == null ? 30 : 50,
            child: TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: tbLoi != null ? Colors.red : Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor))
              ),
              keyboardType: widget.kieuBanPhim,
              controller: textEditingController,
              focusNode: focusNode,
              readOnly: !widget.dieuKhien!.khaDung,
              maxLength: widget.soKyTuToiDa,
              inputFormatters: widget.kiemSoatNhapLieu,
              onFieldSubmitted: (value) {
                // onFieldSubmitted();
              }
            )
          );
        },
        optionsBuilder: (value) async => await _timGoiY(),
        optionsViewBuilder: (context, onSelected, options) {
          double maxH = options.length * 50;
          double gioiHan = GoiYVanBan.chieuCaoHienThiGoiY;
          if (maxH > gioiHan) {
            maxH = gioiHan;
          }
          double maxW = double.infinity;
          final Rect? viTri = widget.timViTriCuaToi();
          if (viTri != null) {
            maxW = viTri.width;
          //   double h = MediaQuery.sizeOf(context).height - viTri.bottom;
          //   if (h < 100) {
          //     h = 100;
          //   }
          //   if (maxH > h) {
          //     maxH = h;
          //   }
          }
          // NOTE: có cần trừ chiều cao bàn phím?
          return Align(
            alignment: Alignment.topLeft,
            child: Container(
              // color: Color.fromARGB(255, 170, 170, 170),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(offset: Offset(5, 5), blurRadius: 5, color: Color.fromARGB(255, 200, 200, 200)),
                  BoxShadow(offset: Offset(-1, -1), blurRadius: 1, color: Color.fromARGB(255, 200, 200, 200))
                ]
              ),
              constraints: BoxConstraints(maxHeight: maxH, maxWidth: maxW),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (context, index) => SizedBox(height: 1, child: Container(color: Colors.grey)),
                itemBuilder: (context, index) {
                  final String opt = options.toList()[index];
                  return TextButton(
                    style: const ButtonStyle(
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))),
                      foregroundColor: MaterialStatePropertyAll(Colors.black),
                    ),
                    onPressed: () => onSelected(opt),
                    child: VanBanHienThiNoiBat(vanBan: _layVanBanNoiBat(opt, widget.dieuKhien!.vanBan))
                  );
                }
              )
            )
          );
        },
        onSelected: (option) {
          if (widget.dieuKhien!.goiY?.tiepTucGoiY(widget.dieuKhien!.vanBan, widget) ?? false) {
            widget.dieuKhien!._coTheTheoDoiThayDoiVanBan = false;
            widget.dieuKhien!.vanBan = "";
            widget.dieuKhien!.vanBan = option;
            widget.dieuKhien!._coTheTheoDoiThayDoiVanBan = true;
          }
          widget.dieuKhien?.goiY?.daChonGoiY(option);
        }
      )
    );
    // Thông báo lỗi
    if (tbLoi != null) {
      mainChildren.add(
        VbhtWidget(text: tbLoi, style: const TextStyle(color: Colors.red))
      );
    }
    List<Widget> rowChildren = [];
    rowChildren.add(
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mainChildren
      ))
    );
    Widget? nutBenPhai = widget.xayDungNutBenPhai?.call(widget.dieuKhien!.trangThaiNutBenPhai, widget.dieuKhien!.khaDung);
    if (nutBenPhai != null) {
      rowChildren.add(Column(
        children: [
          const SizedBox(height: 12),
          nutBenPhai
        ],
      ));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }

}
