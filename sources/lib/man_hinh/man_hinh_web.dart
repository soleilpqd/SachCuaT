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
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/models/vtv.dart';
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _DieuKhienManHinhWeb {

  late BuildContext context;
  /// Bật trích xuất (là trang Lưu chiểu)
  bool batTrichXuat = false;
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

  /// Kiểm tra xem nút trích xuất có thể sử dụng được hay không
  bool get choPhepTrichXuat {
    final bool koChoPhep = dangTai || !daTaiThanhCong || !batTrichXuat || !trichXuatSanSang;
    return !koChoPhep;
  }

}

/// Màn hình web
class ManHinhWeb extends StatelessWidget with KhuonMauQuanLyManHinh {

  /// Mã màn hình (dùng cho KhuonMauQuanLyManHinh)
  static const String maManHinh = "ManHinhWeb";

  @override
  String get tenManHinh => ManHinhWeb.maManHinh;

  /// URL
  final String url;
  /// Tiêu đề
  final Vbht tieuDe;
  /// Webview controller
  final WebViewController _webController = WebViewController();
  /// Điều khiển nút trích xuất
  final DieuKhienCoSo _dkNutTrichXuat = DieuKhienCoSo(khaDung: false);
  /// Điều khiển nội bộ
  final _DieuKhienManHinhWeb _dieuKhien = _DieuKhienManHinhWeb();
  /// Hàm xử lý khi nhấn chọn 1 sách khi trích xuất
  final Function(Map<String, String>)? khiChonSach;

  /// CONSTRUCTOR
  ManHinhWeb({super.key, required this.tieuDe, required this.url, this.khiChonSach}) {
    _dieuKhien.batTrichXuat = url == HangSo.urlLuuChieu;
    _webController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webController.setNavigationDelegate(NavigationDelegate(
      onPageStarted: _khiBatDauTaiTrang,
      onPageFinished: _khiKetThucTaiTrang,
      onHttpError: _khiTaiTrangLoi
    ));
    _dieuKhien.dangTai = true;
    _dieuKhien.daTaiThanhCong = false;
    _dieuKhien.trichXuatSanSang = false;
    _webController.loadRequest(Uri.parse(url));
  }

  void _cauHinhNutTrichXuat() => _dkNutTrichXuat.khaDung = _dieuKhien.choPhepTrichXuat;

  @override
  BuildContext get context => _dieuKhien.context;

  @override
  Widget build(BuildContext context) {
    _dieuKhien.context = context;
    return ManHinhCoSo(
      tieuDe: tieuDe,
      khiNhanQuayLai: () => pop(),
      nutPhai: _dieuKhien.batTrichXuat ? NutBamBieuTuong(icon: Icons.input, khiNhan: _khiNhanNutTrichXuat, dieuKhien: _dkNutTrichXuat) : null,
      noiDung: WebViewWidget(controller: _webController)
    );
  }

  /// Khi webview bắt đầu tải trang
  void _khiBatDauTaiTrang(String url) {
    _dieuKhien.dangTai = true;
    _dieuKhien.daTaiThanhCong = false;
    _dieuKhien.trichXuatSanSang = false;
    _cauHinhNutTrichXuat();
  }

  /// Khi webview kết thúc tải trang
  void _khiKetThucTaiTrang(String url) {
    if (_dieuKhien.batTrichXuat) {
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
        _dieuKhien.trichXuatSanSang = true;
        _cauHinhNutTrichXuat();
      });
    }

    _dieuKhien.dangTai = false;
    _dieuKhien.daTaiThanhCong = true;
    _cauHinhNutTrichXuat();
  }

  /// Khi tải trang thất bại
  void _khiTaiTrangLoi(HttpResponseError error) {
    _dieuKhien.dangTai = false;
    _dieuKhien.daTaiThanhCong = false;
    _cauHinhNutTrichXuat();
  }

  /// Khi nhấn nút trích xuất
  void _khiNhanNutTrichXuat() {
    // _trichXuatDsNXB();
    _trichXuatDsSach();
  }

  /// Reserved
  void _trichXuatDsNXB() {
    _dieuKhien.dsNXB.clear();
    _dieuKhien.dsSach.clear();
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
      _dieuKhien.dsNXB = dsNXB;
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
      List<List<String>> dsSach = [];
      for (final doan in cacDoan) {
        List<String> cacDong = doan.split(Platform.isAndroid ? "\\n" : "\n");
        if (cacDong.length > 6) {
          dsSach.add(cacDong);
        }
      }
      if (dsSach.isEmpty) {
        _khongCoKetQuaTrichXuat();
      } else {
        _dieuKhien.dsSach = dsSach;
        _xuLyKetQuaTrichXuat();
      }
    }).onError((error, stackTrace) {
      _khongCoKetQuaTrichXuat();
    });
  }

  /// Xử lý khi danh sách trích xuất rỗng
  void _khongCoKetQuaTrichXuat() {
    HopThoai.hienThiThongBao(
      context,
      noiDung: Vbht.tuKhoa(TK.khongCoKetQua),
      nhanNut: Vbht.tuKhoa(TK.dong)
    );
  }

  /// Xử lý kết quả trích xuất: hiển thị bottom sheet cho user chọn
  void _xuLyKetQuaTrichXuat() {
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (ctx) {
        return SizedBox(
          height: screenHeight / 2,
          child: ListView.separated(
            itemBuilder: (ctx2, index) {
              return ListTile(
                leading: Text(_dieuKhien.dsSach[index][0]),
                title: Text(_dieuKhien.dsSach[index][2]),
                subtitle: Text("ISBN: ${_dieuKhien.dsSach[index][1]}\nTG: ${_dieuKhien.dsSach[index][3]}\nNXB: ${_dieuKhien.dsSach[index][5]}"),
                isThreeLine: true,
                onTap: () {
                  Map<String, String> thongTinSach = {};
                  List<String> duLieu = _dieuKhien.dsSach[index];
                  thongTinSach["ISBN"] = LinhTinh.chuanHoaMaSo(duLieu[1]);
                  thongTinSach["ten"] = duLieu[2].trim();
                  thongTinSach["TG"] = duLieu[3].trim();
                  thongTinSach["BTV"] = duLieu[4].trim();
                  thongTinSach["NXB"] = duLieu[5].trim();
                  thongTinSach["DT"] = duLieu[6].trim();
                  thongTinSach["in"] = duLieu[7].trim();
                  thongTinSach["ngay"] = duLieu[8].trim();
                  Navigator.of(ctx).pop(); // Pop down this list
                  pop(); // Pop screen
                  khiChonSach?.call(thongTinSach);
                },
              );
            },
            separatorBuilder: (ctx3, index) {
              return const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 1,
              );
            },
            itemCount: _dieuKhien.dsSach.length
          ),
        );
      }
    );
  }

}
