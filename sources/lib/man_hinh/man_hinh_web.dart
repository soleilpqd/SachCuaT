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
import 'package:webview_flutter/webview_flutter.dart';

class ManHinhWeb extends StatefulWidget {

  static const String tenManHinh = "ManHinhWeb";
  final String url;
  final String tieuDe;

  const ManHinhWeb({super.key, required this.tieuDe, required this.url});

  @override
  State<StatefulWidget> createState() => _TrangThaiManHinhWeb();

}

class _TrangThaiManHinhWeb extends State<ManHinhWeb> with KhuonMauQuanLyManHinh {

  @override
  String get tenManHinh => ManHinhWeb.tenManHinh;

  final _webController = WebViewController();
  bool _dangTai = false;
  bool _daTaiThanhCong = false;
  bool _batTrichXuat = true;
  bool _trichXuatSanSang = false;

  @override
  void initState() {
    _webController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webController.setNavigationDelegate(NavigationDelegate(
      onPageStarted: _khiBatDauTaiTrang,
      onPageFinished: _khiKetThucTaiTrang,
      onHttpError: _khiTaiTrangLoi
    ));
    _dangTai = true;
    _daTaiThanhCong = false;
    _trichXuatSanSang = false;
    // TODO: check URL to set _isEnableExtractor
    _webController.loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ManHinhCoSo(
      tieuDe: widget.tieuDe,
      nutPhai:
        _dangTai || !_daTaiThanhCong || !_batTrichXuat || !_trichXuatSanSang ?
          null :
          IconButton(icon: const Icon(Icons.input), onPressed: _khiNhanNutTrichXuat),
      noiDung: WebViewWidget(controller: _webController)
    );
  }

  void _khiBatDauTaiTrang(String url) {
    setState(() {
      _dangTai = true;
      _daTaiThanhCong = false;
      _trichXuatSanSang = false;
    });
  }

  void _khiKetThucTaiTrang(String url) {
    if (_batTrichXuat) {
      _webController.runJavaScript(
        """
        function timMaNXB() {
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
        """
      ).then((value) {
        setState(() {
          _trichXuatSanSang = true;
        });
      });
    }

    setState(() {
      _dangTai = false;
      _daTaiThanhCong = true;
    });
  }

  void _khiTaiTrangLoi(HttpResponseError error) {
    setState(() {
      _dangTai = false;
      _daTaiThanhCong = false;
    });
  }

  void _khiNhanNutTrichXuat() {
    _trichXuatDsNXB();
  }

  void _trichXuatDsNXB() {
    _webController.runJavaScriptReturningResult("timMaNXB();").then((value) {
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
      List<String> dsMaNXB = dsNXB.keys.toList();
      dsMaNXB.sort((item1, item2) => (int.tryParse(item1) ?? 0) - (int.tryParse(item2) ?? 0));
      for (final ma in dsMaNXB) {
        print("$ma: ${dsNXB[ma]}");
      }
      _trichXuatDsSach();
    });
  }

  void _trichXuatDsSach() {

  }

}