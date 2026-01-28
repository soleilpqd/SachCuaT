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
import 'package:sach_cua_t/utils/vonglapgioihan.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/truong_bat_tat.dart';
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
  vbTieuDe,
  /// Thông báo lỗi
  thongBaoLoi,
  /// Focus (con trỏ văn bản)
  trangThaiNhap,
  /// Trạng thái nút bên phải
  nutBenPhai,
}

/// Trạng thái nhập văn bản (Focus)
enum TrangThaiNhapVanBan {
  /// Không
  khong,
  /// Focus vào ô tiêu đề
  tieuDe,
  /// Focus vào ô nội dung
  noiDung
}

/// Điều khiển trường văn bản
class DieuKhienTruongVanBan extends DieuKhienCoSo {

  String debugInfo = "";

  /// Đối tượng tạo danh sách gợi ý
  final GoiYVanBan? goiYTieuDe;
  final GoiYVanBan? goiYNoiDung;
  /// Quản lý focus
  final FocusNode dauMoiNhapTieuDe = FocusNode();
  final FocusNode dauMoiNhapNoiDung = FocusNode();
  /// Quản lý nhập liệu
  final TextEditingController quanLyNhapTieuDe = TextEditingController();
  final TextEditingController quanLyNhapNoiDung = TextEditingController();
  /// Văn bản ban đầu
  final String vanBanBanDau;
  final String tieuDeBanDau;
  /// Điều khiển ô kiểm Luôn hiển thị
  final DieuKhienTruongBatTat dkLuonHienThi = DieuKhienTruongBatTat();

  TrangThaiNhapVanBan _trangThaiCu = TrangThaiNhapVanBan.khong;

  /// Đã thay đổi
  @override
  bool get daThayDoi {
    return vanBanBanDau != vanBan || tieuDeBanDau != vbTieuDe;
  }

  /// Khả dụng
  @override
  set khaDung(bool gt) {
    if (!khaDung) {
      dauMoiNhapNoiDung.unfocus();
      dauMoiNhapTieuDe.unfocus();
      dauMoiNhapNoiDung.canRequestFocus = false;
      dauMoiNhapTieuDe.canRequestFocus = false;
    } else {
      dauMoiNhapNoiDung.canRequestFocus = true;
      dauMoiNhapTieuDe.canRequestFocus = true;
    }
    super.khaDung = gt;
  }

  /// CONSTRUCTOR
  DieuKhienTruongVanBan({
    this.vanBanBanDau = "",
    this.tieuDeBanDau = "",
    this.goiYNoiDung,
    this.goiYTieuDe,
    super.khaDung,
    super.laDieuKhienMoi,
    bool luonHienThi = false
  }) {
    quanLyNhapTieuDe.text = tieuDeBanDau;
    quanLyNhapNoiDung.text = vanBanBanDau;
    dauMoiNhapNoiDung.addListener(_khiFocusThayDoi);
    dauMoiNhapTieuDe.addListener(_khiFocusTieuDeThayDoi);
    quanLyNhapNoiDung.addListener(_khiVanBanThayDoi);
    quanLyNhapTieuDe.addListener(_khiTieuDeThayDoi);
    dauMoiNhapNoiDung.unfocus();
    dauMoiNhapNoiDung.canRequestFocus = khaDung;
    dauMoiNhapTieuDe.unfocus();
    dauMoiNhapTieuDe.canRequestFocus = khaDung;
    dkLuonHienThi.khaDung = khaDung;
    dkLuonHienThi.giaTri = luonHienThi;
  }

  /// DESTRUCTOR
  @override
  void dispose() {
    super.dispose();
    dauMoiNhapNoiDung.removeListener(_khiFocusThayDoi);
    dauMoiNhapTieuDe.removeListener(_khiFocusTieuDeThayDoi);
    quanLyNhapNoiDung.removeListener(_khiVanBanThayDoi);
    quanLyNhapTieuDe.removeListener(_khiTieuDeThayDoi);
    dauMoiNhapNoiDung.dispose();
    dauMoiNhapTieuDe.dispose();
    quanLyNhapNoiDung.dispose();
    quanLyNhapTieuDe.dispose();
    dkLuonHienThi.dispose();
  }

  /// Xử lý nội bộ
  bool _coTheTheoDoiThayDoiVanBan = true;
  /// Văn bản
  String get vanBan => quanLyNhapNoiDung.text;
  String get vbTieuDe => quanLyNhapTieuDe.text;
  /// Văn bản
  set vanBan(String value) {
    quanLyNhapNoiDung.text = value;
  }
  set vbTieuDe(String value) {
    quanLyNhapTieuDe.text = value;
  }

  /// Focus (con trỏ văn bản)
  TrangThaiNhapVanBan get trangThaiNhap {
    if (dauMoiNhapNoiDung.hasFocus) {
      return TrangThaiNhapVanBan.noiDung;
    }
    if (dauMoiNhapTieuDe.hasFocus) {
      return TrangThaiNhapVanBan.tieuDe;
    }
    return TrangThaiNhapVanBan.khong;
  }
  /// Focus (con trỏ văn bản)
  set trangThaiNhap(TrangThaiNhapVanBan newValue) {
    switch (newValue) {
      case TrangThaiNhapVanBan.khong:
        dauMoiNhapNoiDung.unfocus();
        dauMoiNhapTieuDe.unfocus();
      case TrangThaiNhapVanBan.tieuDe:
        dauMoiNhapTieuDe.requestFocus();
      case TrangThaiNhapVanBan.noiDung:
        dauMoiNhapNoiDung.requestFocus();
    }
  }
  bool dangTrongTrangThaiNhap() => dauMoiNhapNoiDung.hasFocus || dauMoiNhapTieuDe.hasFocus;

  /// Thông báo lỗi
  Vbht? get thongBaoLoi => this[ThuocTinhTruongVanBan.thongBaoLoi.name];
  /// Thông báo lỗi
  set thongBaoLoi(Vbht? giaTri) => this[ThuocTinhTruongVanBan.thongBaoLoi.name] = giaTri;

  /// Trạng thái nút bên phải
  int? get trangThaiNutBenPhai => this[ThuocTinhTruongVanBan.nutBenPhai.name];
  /// Trạng thái nút bên phải
  set trangThaiNutBenPhai(int? giaTri) => this[ThuocTinhTruongVanBan.nutBenPhai.name] = giaTri;

  bool get luonHienThi => dkLuonHienThi.giaTri;
  set luonHienThi(bool gt) => dkLuonHienThi.giaTri = gt;

  /// Xử lý khi văn bản thay đổi
  void _khiVanBanThayDoi() {
    if (_coTheTheoDoiThayDoiVanBan) {
      thongBao({ThuocTinhTruongVanBan.vanBan.name: vanBan});
    }
  }

  /// Xử lý khi focus thay đổi
  void _khiFocusThayDoi() {
    _thongBaoTrangThaiNhap();
  }

    /// Xử lý khi văn bản thay đổi
  void _khiTieuDeThayDoi() {
    if (_coTheTheoDoiThayDoiVanBan) {
      thongBao({ThuocTinhTruongVanBan.vbTieuDe.name: vbTieuDe});
    }
  }

  /// Xử lý khi focus thay đổi
  void _khiFocusTieuDeThayDoi() {
    _thongBaoTrangThaiNhap();
  }

  void _thongBaoTrangThaiNhap() {
    final TrangThaiNhapVanBan trangThaiHienTai = trangThaiNhap;
    if (trangThaiHienTai != _trangThaiCu) {
      _trangThaiCu = trangThaiHienTai;
      thongBao({ThuocTinhTruongVanBan.trangThaiNhap.name: trangThaiHienTai});
    }
  }

  @override
  void apDungVaThongBao(Map<String, dynamic> cacGiaTri) {
    Map<String, dynamic> dem = cacGiaTri;
    // Xử lý các thuộc tính ko lưu thông qua Map mặc định
    if (dem.containsKey(ThuocTinhTruongVanBan.trangThaiNhap.name)) {
      final dynamic gt = dem[ThuocTinhTruongVanBan.trangThaiNhap.name];
      if (gt != null && gt is TrangThaiNhapVanBan) {
        dem.remove(ThuocTinhTruongVanBan.trangThaiNhap.name);
        trangThaiNhap = gt;
      }
    }
    if (dem.containsKey(ThuocTinhTruongVanBan.vanBan.name)) {
      final dynamic gt = dem[ThuocTinhTruongVanBan.vanBan.name];
      if (gt != null && gt is String) {
        dem.remove(ThuocTinhTruongVanBan.vanBan.name);
        vanBan = gt;
      }
    }
    dkLuonHienThi.khaDung = khaDung;
    super.apDungVaThongBao(dem);
  }

}

class CauHinhTruongVanBan {
  /// Kiểu bàn phím
  final TextInputType kieuBanPhim;
  /// Số ký tự tối đa
  final int? soKyTuToiDa;
  /// Tự động bật bàn phím
  final bool tuDongKichHoatNhap;
  /// Kiểm soát ký tự nhập vào
  final List<TextInputFormatter>? kiemSoatNhapLieu;

  const CauHinhTruongVanBan({
    this.kieuBanPhim = TextInputType.text,
    this.soKyTuToiDa,
    this.kiemSoatNhapLieu,
    this.tuDongKichHoatNhap = false
  });

}

/// Trường văn bản
class TruongVanBan extends GiaoDienCoSo<DieuKhienTruongVanBan> {

  /// Tiêu đề
  final Vbht? tieuDe;
  /// Cấu hình phần nhập chính
  final CauHinhTruongVanBan cauHinh;
  /// Cấu hình phần nhập tiêu đề
  final CauHinhTruongVanBan? cauHinhTieuDe;
  /// Bật luôn hiển thị
  final bool batLuonHienThi;
  final BoDemVbht? demVbht;
  /// Hàm xây dựng nút bên phải theo trạng thái
  final Widget? Function(int? giaTri, bool khaDung)? xayDungNutBenPhai;

  /// CONSTRUCTOR
  TruongVanBan({
    this.cauHinh = const CauHinhTruongVanBan(),
    this.tieuDe,
    this.cauHinhTieuDe,
    this.batLuonHienThi = false,
    required DieuKhienTruongVanBan trinhDieuKhien,
    this.xayDungNutBenPhai,
    this.demVbht
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
        datTrangThaiKhiAnToan();
      }
    }
  }

  /// Tìm gợi ý
  Future<List<String>> _timGoiY(bool laPhanNoiDung) async {
    VongLapGioiHan vongLap = VongLapGioiHan.koDongBo((vLap, _) async {
      final text = (laPhanNoiDung ? widget.dieuKhien?.vanBan : widget.dieuKhien?.vbTieuDe) ?? "";
      final goiY = laPhanNoiDung ? widget.dieuKhien?.goiYNoiDung : widget.dieuKhien?.goiYTieuDe;
      List<String> ketQua = await goiY?.timKiemGoiY(text, widget) ?? [];
      final textHienTai = (laPhanNoiDung ? widget.dieuKhien?.vanBan : widget.dieuKhien?.vbTieuDe) ?? "";
      if (textHienTai != text) { // Văn bản thay đổi trong khi tìm kiếm gợi ý
        return await vLap.tienHanhKoDB(null);
      }
      return ketQua;
    }, gioiHan: 1);
    try {
      return await vongLap.tienHanhKoDB(null);
    } catch (_) {
      return [];
    }
  }

  /// Lấy văn bản nổi bật để hiển thị
  VanBanNoiBat _layVanBanNoiBat({required String dayDu, required bool laPhanNoiDung}) {
    final goiY = laPhanNoiDung ? widget.dieuKhien?.goiYNoiDung : widget.dieuKhien?.goiYTieuDe;
    final String noiBat = (laPhanNoiDung ? widget.dieuKhien?.vanBan : widget.dieuKhien?.vbTieuDe) ?? "";
    // print("DEBUG LAYNOIBAT $laPhanNoiDung");
    return goiY?.layVanBanNoiBat(dayDu, noiBat) ?? VanBanNoiBat(vanBanDayDu: dayDu, vanBanNoiBat: noiBat);
  }

  @override
  Widget build(BuildContext context) {
    final Vbht? tbLoi = widget.dieuKhien?.thongBaoLoi;
    List<Widget> mainChildren = [];
    // Tiêu đề
    if (widget.cauHinhTieuDe != null) {
      mainChildren.add(Row(children: [
        Expanded(
          flex: 1,
          child: _xayDungONhap(
            cauHinh: widget.cauHinhTieuDe!,
            txtCtrl: widget.dieuKhien!.quanLyNhapTieuDe,
            fNode: widget.dieuKhien!.dauMoiNhapTieuDe,
            laONhapChinh: false
          )
        ),
        Expanded(
          flex: 3,
          child: _xayDungONhap(
            cauHinh: widget.cauHinh,
            txtCtrl: widget.dieuKhien!.quanLyNhapNoiDung,
            fNode: widget.dieuKhien!.dauMoiNhapNoiDung,
            laONhapChinh: true
          )
        )
      ]));
    } else {
      mainChildren.add(VbhtWidget(text: widget.tieuDe ?? Vbht.trucTiep(""), textAlign: TextAlign.left));
      // Text input
      mainChildren.add(_xayDungONhap(
        cauHinh: widget.cauHinh,
        txtCtrl: widget.dieuKhien!.quanLyNhapNoiDung,
        fNode: widget.dieuKhien!.dauMoiNhapNoiDung,
        laONhapChinh: true
      ));
    }
    // Thông báo lỗi
    if (tbLoi != null) {
      mainChildren.add(
        VbhtWidget(text: tbLoi, style: const TextStyle(color: Colors.red))
      );
    }
    if (widget.batLuonHienThi) {
      final Widget oLuonHienThi = _xayDungOLuonHienThi();
      Widget? nutBenPhai = widget.xayDungNutBenPhai?.call(widget.dieuKhien!.trangThaiNutBenPhai, widget.dieuKhien!.khaDung);
      List<Widget> dsCacO = [oLuonHienThi];
      if (nutBenPhai != null) {
        dsCacO.add(nutBenPhai);
      }
      mainChildren.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dsCacO,
      ));
    }
    List<Widget> rowChildren = [];
    rowChildren.add(
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mainChildren
      ))
    );
    if (!widget.batLuonHienThi) {
      Widget? nutBenPhai = widget.xayDungNutBenPhai?.call(widget.dieuKhien!.trangThaiNutBenPhai, widget.dieuKhien!.khaDung);
      if (nutBenPhai != null) {
        rowChildren.add(Column(
          children: [
            const SizedBox(height: 12),
            nutBenPhai
          ],
        ));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }

  Widget _xayDungONhap({
    required CauHinhTruongVanBan cauHinh,
    required TextEditingController txtCtrl,
    required FocusNode fNode,
    required bool laONhapChinh
  }) {
    final Vbht? tbLoi = widget.dieuKhien?.thongBaoLoi;
    return RawAutocomplete<String>(
      focusNode: fNode,
      textEditingController: txtCtrl,
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return SizedBox(
          height: cauHinh.soKyTuToiDa == null ? 30 : 50,
          child: TextFormField(
            style: TextStyle(fontWeight: laONhapChinh ? FontWeight.normal : FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: tbLoi != null ? Colors.red : Colors.grey)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor))
            ),
            keyboardType: cauHinh.kieuBanPhim,
            controller: textEditingController,
            focusNode: focusNode,
            readOnly: !widget.dieuKhien!.khaDung,
            maxLength: cauHinh.soKyTuToiDa,
            inputFormatters: cauHinh.kiemSoatNhapLieu,
            autofocus: cauHinh.tuDongKichHoatNhap,
            onFieldSubmitted: (value) {
              // onFieldSubmitted();
            }
          )
        );
      },
      optionsBuilder: (value) async => await _timGoiY(laONhapChinh),
      optionsViewBuilder: (context, onSelected, options) {
        // print("DEBUG build suggest $laONhapChinh: $options");
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
                  child: Row(children: [VanBanHienThiNoiBat(vanBan: _layVanBanNoiBat(dayDu: opt, laPhanNoiDung: laONhapChinh))])
                );
              }
            )
          )
        );
      },
      onSelected: (option) {
        final GoiYVanBan? goiY = laONhapChinh ? widget.dieuKhien?.goiYNoiDung : widget.dieuKhien?.goiYTieuDe;
        if (goiY?.tiepTucGoiY(widget.dieuKhien!.vanBan, widget) ?? false) {
          widget.dieuKhien!._coTheTheoDoiThayDoiVanBan = false;
          if (laONhapChinh) {
            widget.dieuKhien!.vanBan = "";
            widget.dieuKhien!.vanBan = option;
          } else {
            widget.dieuKhien!.vbTieuDe = "";
            widget.dieuKhien!.vbTieuDe = option;
          }
          widget.dieuKhien!._coTheTheoDoiThayDoiVanBan = true;
        }
        goiY?.daChonGoiY(option);
      }
    );
  }

  Widget _xayDungOLuonHienThi() {
    return TruongBatTat(
      tieuDe: Vbht.tuKhoa(TK.luonHienThi, dem: widget.demVbht),
      sapXep: MainAxisAlignment.start,
      daoChieu: true,
      trinhDieuKhien: widget.dieuKhien!.dkLuonHienThi
    );
  }

}
