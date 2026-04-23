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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tro_giup.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DieuKhienManHinhWeb extends DieuKhienManHinh {

  /// URL
  final String url;
  /// Tiêu đề
  final Vbht tieuDe;
  /// Webview controller
  final WebViewController _webController = WebViewController();
  /// Điều khiển nút trích xuất
  final DieuKhienCoSo _dkNutTrichXuat = DieuKhienCoSo(khaDung: false);
  /// Hàm xử lý khi nhấn chọn 1 sách khi trích xuất
  final Function(Map<String, String>)? khiChonSach;
  /// Bật trích xuất (là trang Lưu chiểu)
  final bool batTrichXuat;
  /// Đang tải
  bool dangTai = false;
  /// Đã tải thành công
  bool daTaiThanhCong = false;
  /// Đã tiêm nhiễm thành công code JS để trích xuất dữ liệu
  bool trichXuatSanSang = false;
  /// Danh sách nhà xuất bản đã trích xuất
  Map<String, String> dsNXB = {};
  /// Danh sách Sách đã trích xuất
  List<List<String>> dsSach = [];

  DieuKhienManHinhTuDuoiDay? _dkHopThoaiChonSach;

  DieuKhienManHinhWeb({
    required this.url,
    required this.tieuDe,
    this.khiChonSach,
    bool? coTheTrichXuat
  }) : batTrichXuat = coTheTrichXuat ?? (url == HangSo.urlLuuChieu || url == HangSo.urlDKXuatBan) {
    widgetCuaManHinh = _ManHinhWeb(dkManHinh: this);
    _webController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webController.setNavigationDelegate(NavigationDelegate(
      onPageStarted: _khiBatDauTaiTrang,
      onPageFinished: _khiKetThucTaiTrang,
      onHttpError: _khiTaiTrangLoi
    ));
    dangTai = true;
    daTaiThanhCong = false;
    trichXuatSanSang = false;
    _webController.loadRequest(Uri.parse(url));
  }

  void _cauHinhNutTrichXuat() => _dkNutTrichXuat.khaDung = choPhepTrichXuat;

  /// Kiểm tra xem nút trích xuất có thể sử dụng được hay không
  bool get choPhepTrichXuat {
    final bool koChoPhep = dangTai || !daTaiThanhCong || !batTrichXuat || !trichXuatSanSang;
    return !koChoPhep;
  }

  void _khiNhanQuayLai() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  /// Khi webview bắt đầu tải trang
  void _khiBatDauTaiTrang(String url) {
    dangTai = true;
    daTaiThanhCong = false;
    trichXuatSanSang = false;
    _cauHinhNutTrichXuat();
  }

  /// Khi webview kết thúc tải trang
  void _khiKetThucTaiTrang(String url) {
    if (batTrichXuat) {
      _webController.runJavaScript(
        """
        function layDanhSachNXB() {
          let ketQua = "";
          const selectTag = document.getElementsByName("id_nxb");
          if (selectTag.length > 0) {
            selectTag.item(0).childNodes.forEach(function (item, index, list) {
              if (item.tagName == "OPTION") {
                ketQua += `\${item.value}\\n\${item.text}\\n`;
              }
            });
          }
          return ketQua;
        }

        function layDanhSachSach() {
          let ketQua = "";
          const divKetQua = document.getElementById("list_data_return");
          if (divKetQua != null) {
            divKetQua.childNodes.forEach(function (divKqItem, divKqIndex, divKqList) {
              if (divKqItem.tagName == "TABLE") {
                divKqItem.childNodes.forEach(function (tableItem, tableIndex, tableList) {
                  if (tableItem.tagName == "TBODY") {
                    tableItem.childNodes.forEach(function (tbodyItem, tbodyIndex, tbodyList) {
                      if (tbodyItem.tagName == "TR") {
                        tbodyItem.childNodes.forEach(function (trItem, trIndex, trList) {
                          if (trItem.tagName == "TD") {
                            ketQua += `\${trItem.textContent}\\n`;
                          }
                        })
                        ketQua += "\\r\\n";
                      }
                    })
                  }
                })
              }
            })
          }
          return ketQua;
        }
        """
      ).then((value) {
        trichXuatSanSang = true;
        _cauHinhNutTrichXuat();
      });
    }

    dangTai = false;
    daTaiThanhCong = true;
    _cauHinhNutTrichXuat();
  }

  /// Khi tải trang thất bại
  void _khiTaiTrangLoi(HttpResponseError error) {
    dangTai = false;
    daTaiThanhCong = false;
    _cauHinhNutTrichXuat();
  }

  /// Khi nhấn nút trích xuất
  void _khiNhanNutTrichXuat() {
    // _trichXuatDsNXB();
    _trichXuatDsSach();
  }

  /// Reserved
  void _trichXuatDsNXB() {
    dsNXB.clear();
    dsSach.clear();
    _webController.runJavaScriptReturningResult("layDanhSachNXB();").then((value) {
      String ketQua = value as String;
      List<String> cacDong = ketQua.split(Platform.isAndroid ? "\\n" : "\n");
      bool dongLe = false;
      String tenNXB = "";
      String maNXB = "";
      Map<String, String> dsNXB = {};
      for (final dong in cacDong) {
        if (dongLe) {
          tenNXB = dong;
          if (maNXB != "-1") {
            dsNXB[maNXB] = tenNXB;
          }
        } else {
          maNXB = dong;
        }
        dongLe = !dongLe;
      }
      List<String> dsMa = dsNXB.keys.toList();
      dsMa.sort((a, b) => (int.tryParse(a) ?? 0) - (int.tryParse(b) ?? 0));
      for (final ma in dsMa) {
        print("(\"${dsNXB[ma]}\", \"$ma\"),\n");
      }
      _trichXuatDsSach();
    }).onError((error, stackTrace) {
      _trichXuatDsSach();
    });
  }

  /// Trích xuất danh sách sách
  void _trichXuatDsSach() {
    _webController.runJavaScriptReturningResult("layDanhSachSach();").then((value) {
      String ketQua = value as String;
      List<String> cacDoan = ketQua.split(Platform.isAndroid ? "\\n\\r\\n" : "\n\r\n");
      dsSach.clear();
      for (final doan in cacDoan) {
        List<String> cacDong = doan.split(Platform.isAndroid ? "\\n" : "\n");
        if (cacDong.length > 6) {
          dsSach.add(cacDong);
        }
      }
      if (dsSach.isEmpty) {
        _khongCoKetQuaTrichXuat();
      } else {
        _xuLyKetQuaTrichXuat();
      }
    }).onError((error, stackTrace) {
      _khongCoKetQuaTrichXuat();
    });
  }

  /// Xử lý khi danh sách trích xuất rỗng
  void _khongCoKetQuaTrichXuat() {
    HopThoai.hienThiHopThoaiThongBao(
      noiDung: Vbht.tuKhoa(TK.khongCoKetQua),
      nhanCacNut: [Vbht.tuKhoa(TK.dong)]
    );
  }

  void _dongHopThoaiChonSach(Map<String, String>? thongTinSach) {
    if (_dkHopThoaiChonSach != null) {
      _dkHopThoaiChonSach!.luongManHinh?.loaiManHinh(
        manHinh: _dkHopThoaiChonSach!
      );
      _dkHopThoaiChonSach = null;
      if (thongTinSach != null) {
        khiChonSach?.call(thongTinSach);
        luongManHinh?.loaiManHinh(manHinh: this);
      }
    }
  }

  /// Xử lý kết quả trích xuất: hiển thị bottom sheet cho user chọn
  void _xuLyKetQuaTrichXuat() {
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    _dkHopThoaiChonSach = HopThoai.hienThiHopThoaiTuDuoiDay(
      noiDung: Material(
        color: phongCach.mauNen,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: ListView.separated(
          itemBuilder: (ctx2, index) {
            return ListTile(
              leading: VbhtWidget(
                text: Vbht.trucTiep(dsSach[index][0]),
                coChu: CoChu.to,
              ),
              title: VbhtWidget(
                text: Vbht.trucTiep(dsSach[index][2]),
                coChu: CoChu.binhThuong,
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: VbhtWidget(
                text: Vbht.trucTiep("ISBN: ${dsSach[index][1]}\nTG: ${dsSach[index][3]}\nNXB: ${dsSach[index][5]}"),
                coChu: CoChu.nho,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              isThreeLine: true,
              onTap: () {
                Map<String, String> thongTinSach = {};
                List<String> duLieu = dsSach[index];
                thongTinSach["ISBN"] = LinhTinh.chuanHoaMaSo(duLieu[1]);
                thongTinSach["ten"] = duLieu[2].trim();
                thongTinSach["TG"] = duLieu[3].trim();
                thongTinSach["BTV"] = duLieu[4].trim();
                thongTinSach["NXB"] = duLieu[5].trim();
                thongTinSach["DT"] = duLieu[6].trim();
                thongTinSach["in"] = duLieu[7].trim();
                thongTinSach["ngay"] = duLieu[8].trim();
                _dongHopThoaiChonSach(thongTinSach);
              },
            );
          },
          separatorBuilder: (ctx3, index) {
            return Divider(
              color: phongCach.mauVien,
              thickness: 1,
              height: 1,
            );
          },
          itemCount: dsSach.length
        )
      ),
      khiDong: () => _dongHopThoaiChonSach(null),
    );
  }

}

/// Màn hình web
class _ManHinhWeb extends StatelessWidget  {

  final DieuKhienManHinhWeb dkManHinh;

  const _ManHinhWeb({required this.dkManHinh});

  @override
  Widget build(BuildContext context) {
    List<Widget> nutPhai = [];
    if (dkManHinh.batTrichXuat) {
      nutPhai.add(NutBamBieuTuong(
        bieuTuong: Icons.input,
        khiNhan: dkManHinh._khiNhanNutTrichXuat,
        thuocThanhDieuHuong: true,
        dieuKhien: dkManHinh._dkNutTrichXuat
      ));
    }
    nutPhai.add(ManHinhCoSo.taoNutHuongDan(KieuHuongDan.web));
    return ManHinhCoSo(
      tieuDe: dkManHinh.tieuDe,
      khiNhanQuayLai: dkManHinh._khiNhanQuayLai,
      nutPhai: nutPhai,
      noiDung: WebViewWidget(key: dkManHinh.khoaWidgetGoc, controller: dkManHinh._webController)
    );
  }

}
