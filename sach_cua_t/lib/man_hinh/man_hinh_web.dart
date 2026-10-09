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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:man_hinh_ung_dung/man_hinh_ung_dung.dart';
import 'package:path/path.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_co_so.dart';
import 'package:sach_cua_t/man_hinh/man_hinh_tro_giup.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/models/luutrucauhinh.dart';
import 'package:sach_cua_t/models/xu_ly_nut_lui_android.dart';
import 'package:sach_cua_t/utils/hopthoai.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/dieu_khien_co_so.dart';
import 'package:sach_cua_t/views/nut_bam_bieu_tuong.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Các khoá trường thông tin sách trả lại từ mã JS trích xuất thông tin web
enum TruongThongTinSachTuInternet {
  /// Số thứ tự
  stt,
  /// ISBN
  isbn,
  /// Tên sách
  ten,
  /// Tác giả
  tacGia,
  /// Biên tập viên
  bienTapVien,
  /// Nhà xuất bản
  nxb,
  /// Đối tác
  doiTac,
  /// In ấn (nhà in)
  inAn,
  /// Ngày tháng
  ngay;

  /// Giá trị khoá
  String get giaTri {
    return switch (this) {
      tacGia => "tac_gia",
      bienTapVien => "bien_tap_vien",
      doiTac => "doi_tac",
      inAn => "in",
      _ => name
    };
  }
}

/// Website để nhập thông tin sách
class WebsiteThongTinSach {
  /// Tên hiển thị
  final String ten;
  /// URL
  final String url;

  const WebsiteThongTinSach({required this.ten, required this.url});
}

/// Mã lệnh JS để nhập thông tin sách
class MaLenhNhapThongTinSach {
  /// Mã lệnh
  final String maLenh;
  /// Lọc lấy chính xác (áp dụng mã lệnh với các URL chính xác trong danh sách)
  final List<String> locChinhXac = [];
  /// Lọc lấy URL dùng Biểu thức chính quy (Regular Expression)
  final List<RegExp> locBieuThuc = [];
  /// Lọc bỏ chính xác (không áp dụng mã lệnh với các URL chính xác trong danh sách)
  final List<String> boChinhXac = [];
  /// Lọc bỏ URL dùng Biểu thức chính quy (Regular Expression)
  final List<RegExp> boBieuThuc = [];

  MaLenhNhapThongTinSach({required this.maLenh});

  bool kiemTraUrl(String url) {
    for (final loc in boChinhXac) {
      if (loc == url) {
        return false;
      }
    }
    for (final loc in locChinhXac) {
      if (loc == url) {
        return true;
      }
    }
    for (final loc in boBieuThuc) {
      if (loc.hasMatch(url)) {
        // print("REGEX exclue true: ${loc.pattern} => $url");
        return false;
      }
      // print("REGEX exclue false: ${loc.pattern} => $url");
    }
    for (final loc in locBieuThuc) {
      if (loc.hasMatch(url)) {
        // print("REGEX include true: ${loc.pattern} => $url");
        return true;
      }
      // print("REGEX include false: ${loc.pattern} => $url");
    }
    return false;
  }
}

class DieuKhienManHinhWeb extends DieuKhienManHinh with XuLyNutLuiAndroid {

  final List<WebsiteThongTinSach> _websites = [];
  final List<MaLenhNhapThongTinSach> _maLenh = [];

  /// Webview controller
  final WebViewController _webController = WebViewController();
  /// Điều khiển nút trích xuất
  final DieuKhienCoSo _dkNutTrichXuat = DieuKhienCoSo(khaDung: false);
  /// Hàm xử lý khi nhấn chọn 1 sách khi trích xuất
  final Function(Map<String, String>)? khiChonSach;
  /// Đang tải
  bool _dangTai = false;
  /// Đã tải thành công
  bool _daTaiThanhCong = false;
  /// Đã tiêm nhiễm thành công code JS để trích xuất dữ liệu
  bool _trichXuatSanSang = false;

  /// Danh sách Sách đã trích xuất
  final List<Map<String, String>> _dsSach = [];
  int _sanSang = 0;

  final Vbht _tieuDeManHinh = Vbht.trucTiep("Website");
  DieuKhienManHinhTuDuoiDay? _dkHopThoaiChonSach;
  DieuKhienManHinhTuDuoiDay? _dkHopThoaiChonWebsite;

  DieuKhienManHinhWeb({
    this.khiChonSach
  }){
    widgetCuaManHinh = _ManHinhWeb(dkManHinh: this);
    _webController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webController.setNavigationDelegate(NavigationDelegate(
      onPageStarted: _khiBatDauTaiTrang,
      onPageFinished: _khiKetThucTaiTrang,
      onHttpError: _khiTaiTrangLoi
    ));
    _dangTai = true;
    _daTaiThanhCong = false;
    _trichXuatSanSang = false;
    _napDanhSachWebsites();
  }

  void _cauHinhNutTrichXuat() => _dkNutTrichXuat.khaDung = choPhepTrichXuat;

  void _kiemTraSanSang() {
    _sanSang += 1;
    if (_sanSang == 2) {
      _khiNhanTieuDeManHinh();
    }
  }

  @override
  void manHinhDaThanhManHinhChinhTrongLuong() {
    super.manHinhDaThanhManHinhChinhTrongLuong();
    _kiemTraSanSang();
  }

  void _napDanhSachWebsites() async {
    final String tenTep = "nhap_sach.json";
    File tepJson = File(join(CoSoDuLieu().thuMucAnhCoSo, tenTep));
    if (await tepJson.exists()) {
      final noiDung = await tepJson.readAsString();
      await _napDsWebsitesTu(noiDung);
    }
    if (_websites.isEmpty) {
      final noiDung = await rootBundle.loadString(join("assets", tenTep));
      await _napDsWebsitesTu(noiDung);
    }
    _kiemTraSanSang();
  }

  Future<void> _napDsWebsitesTu(String duLieu) async {
    try {
      final Map<String, dynamic> thongTin = jsonDecode(duLieu);
      final dsMaLenh = thongTin["ma_lenh"];
      if (dsMaLenh != null && dsMaLenh is List<dynamic>) {
        for (final muc in dsMaLenh) {
          if (muc is Map<String, dynamic>) {
            final ma = muc["ma"];
            if (ma is String) {
              MaLenhNhapThongTinSach maLenh = MaLenhNhapThongTinSach(maLenh: ma);
              var loc = muc["loc_chinh_xac"];
              if (loc != null && loc is List<dynamic>) {
                for (final mucLoc in loc) {
                  if (mucLoc is String) {
                    maLenh.locChinhXac.add(mucLoc);
                  }
                }
              }
              loc = muc["bo_chinh_xac"];
              if (loc != null && loc is List<dynamic>) {
                for (final mucLoc in loc) {
                  if (mucLoc is String) {
                    maLenh.boChinhXac.add(mucLoc);
                  }
                }
              }
              loc = muc["loc_regex"];
              if (loc != null && loc is List<dynamic>) {
                for (final mucLoc in loc) {
                  if (mucLoc is String) {
                    maLenh.locBieuThuc.add(RegExp(mucLoc));
                  }
                }
              }
              loc = muc["bo_regex"];
              if (loc != null && loc is List<dynamic>) {
                for (final mucLoc in loc) {
                  if (mucLoc is String) {
                    maLenh.boBieuThuc.add(RegExp(mucLoc));
                  }
                }
              }
              _maLenh.add(maLenh);
            }
          }
        }
      }
      final dsWebsites = thongTin["urls"];
      if (dsWebsites is List<dynamic>) {
        for (final muc in dsWebsites) {
          if (muc is Map<String, dynamic>) {
            final WebsiteThongTinSach aWeb = WebsiteThongTinSach(
              ten: muc["ten"] as String,
              url: muc["url"] as String
            );
            _websites.add(aWeb);
          }
        }
      }
    } catch (_){}
  }

  /// Kiểm tra xem nút trích xuất có thể sử dụng được hay không
  bool get choPhepTrichXuat {
    final bool koChoPhep = _dangTai || !_daTaiThanhCong || !_trichXuatSanSang;
    return !koChoPhep;
  }

  @override
  bool khiNhanNutLuiAndroid() {
    _khiNhanQuayLai();
    return false;
  }

  void _napTrangWeb(WebsiteThongTinSach doiTuong) {
    _dangTai = true;
    _daTaiThanhCong = false;
    _trichXuatSanSang = false;
    _cauHinhNutTrichXuat();
    _tieuDeManHinh.ganTrucTiep(doiTuong.ten);
    final LuuTruCauHinh cauHinh = LuuTruCauHinh();
    final Uri uri = Uri.parse(doiTuong.url);
    // print("DEBUG kich hoat $uri");
    cauHinh.layLuuYTrangWeb(uri.host).then((gt) {
      // print("DEBUG kich hoat $uri da xac nhan $gt");
      if (!gt) {
        HopThoai.hienThiHopThoaiThongBao(
          noiDung: Vbht.tuKhoa(TK.luuYTrangWebNgoai, ts: [doiTuong.url]),
          nhanCacNut: [Vbht.tuKhoa(TK.moTrongTrinhDuyet), Vbht.tuKhoa(TK.moTrongUngDung)],
          boCucHangDoc: true,
          khiDong: (stt, _) {
            if (stt == 0) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
              luongManHinh?.loaiManHinh(manHinh: this);
            } else {
              cauHinh.luuLuuYTrangWeb(uri.host);
              _webController.loadRequest(uri);
            }
          },
        );
      } else {
        _webController.loadRequest(uri);
      }
    });
  }

  void _khiNhanTieuDeManHinh() {
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    _dkHopThoaiChonWebsite = HopThoai.hienThiHopThoaiTuDuoiDay(
      noiDung: Material(
        color: phongCach.mauNen,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: ListView.separated(
          itemBuilder: (ctx2, index) {
            return ListTile(
              title: VbhtWidget(
                text: Vbht.trucTiep(_websites[index].ten),
                coChu: CoChu.binhThuong,
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: VbhtWidget(
                text: Vbht.trucTiep(_websites[index].url),
                coChu: CoChu.nho,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              isThreeLine: true,
              onTap: () {
                _dongHopThoaiChonWebsite(_websites[index]);
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
          itemCount: _websites.length
        )
      ),
      khiDong: () => _dongHopThoaiChonWebsite(null),
    );
  }

  void _khiNhanQuayLai() {
    luongManHinh?.loaiManHinh(manHinh: this);
  }

  void _dongHopThoaiChonWebsite(WebsiteThongTinSach? web) {
    if (_dkHopThoaiChonWebsite != null) {
      _dkHopThoaiChonWebsite!.luongManHinh?.loaiManHinh(
        manHinh: _dkHopThoaiChonWebsite!
      );
      _dkHopThoaiChonWebsite = null;
      if (web != null) {
        // print("DEBUG doi web ${web.ten}");
        _webController.currentUrl().then((urlHienTai) {
          if (web.url != urlHienTai) {
            // print("  DEBUG doi web $urlHienTai -> ${web.ten}");
            _napTrangWeb(web);
          }
        });
      }
    }
  }

  void _khiNhanTaiLaiTrang() {
    _webController.reload();
  }

  /// Khi webview bắt đầu tải trang
  void _khiBatDauTaiTrang(String url) {
    // print("DEBUG bat dau $url");
    _dangTai = true;
    _daTaiThanhCong = false;
    _trichXuatSanSang = false;
    _cauHinhNutTrichXuat();
  }

  /// Khi webview kết thúc tải trang
  void _khiKetThucTaiTrang(String url) {
    _webController.getTitle().then((tieuDe) {
      _tieuDeManHinh.ganTrucTiep(tieuDe ?? "");
    });
    MaLenhNhapThongTinSach? maLenh;
    for (final muc in _maLenh) {
      if (muc.kiemTraUrl(url)) {
        maLenh = muc;
        break;
      }
    }
    if (maLenh == null) {
      return;
    }
    // print("DEBUG ma lenh: ${maLenh.maLenh}");
    _webController.runJavaScript(maLenh.maLenh).then((_) {
      _trichXuatSanSang = true;
      _cauHinhNutTrichXuat();
    });
    _dangTai = false;
    _daTaiThanhCong = true;
    _cauHinhNutTrichXuat();
  }

  /// Khi tải trang thất bại
  void _khiTaiTrangLoi(HttpResponseError error) {
    _dangTai = false;
    _daTaiThanhCong = false;
    _cauHinhNutTrichXuat();
  }

  /// Mở URL gốc trong trình duyệt ngoài
  void _khiNhanNutTrinhDuyet() {
    _webController.currentUrl().then((url) {
      if (url != null) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    });
  }

  /// Khi nhấn nút trích xuất
  void _khiNhanNutTrichXuat() {
    _trichXuatDsSach();
  }

  /// Trích xuất danh sách sách
  void _trichXuatDsSach() {
    String maLenh = "layDanhSachSach();";
    if (Platform.isIOS) {
      maLenh = "JSON.stringify(layDanhSachSach());";
    }
    _webController.runJavaScriptReturningResult(maLenh).then((value) {
      _dsSach.clear();
      String ketQua = value as String;
      // print("DEBUG kq trich xuat: $value");
      final dynamic ketQuaJson = jsonDecode(ketQua);
      if (ketQuaJson is List<dynamic>) {
        for (final muc in ketQuaJson) {
          if (muc is Map<String, dynamic>) {
            final Map<String, String> mucKq = {};
            muc.forEach((khoa, giaTri) {
              if (giaTri is String) {
                mucKq[khoa] = giaTri;
              }
            });
            _dsSach.add(mucKq);
          }
        }
      }
      if (_dsSach.isEmpty) {
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
    }
    if (thongTinSach != null) {
      _khiChonSach(thongTinSach);
    }
  }

  void _khiChonSach(Map<String, String> thongTinSach) {
    _webController.currentUrl().then((url) {
      if (url != null) {
        thongTinSach["nhan:URL::hien"] = url;
      }
      khiChonSach?.call(thongTinSach);
      luongManHinh?.loaiManHinh(manHinh: this);
    });
  }

  /// Xử lý kết quả trích xuất: hiển thị bottom sheet cho user chọn
  void _xuLyKetQuaTrichXuat() {
    if (_dsSach.length == 1) {
      _khiChonSach(_dsSach.first);
      return;
    }
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
                text: Vbht.trucTiep(_dsSach[index][TruongThongTinSachTuInternet.stt.giaTri] ?? "0"),
                coChu: CoChu.to,
              ),
              title: VbhtWidget(
                text: Vbht.trucTiep(_dsSach[index][TruongThongTinSachTuInternet.ten.giaTri] ?? ""),
                coChu: CoChu.binhThuong,
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: VbhtWidget(
                text: Vbht.trucTiep(
                  "ISBN: ${_dsSach[index][TruongThongTinSachTuInternet.isbn.giaTri]}\n"
                  "TG: ${_dsSach[index][TruongThongTinSachTuInternet.tacGia.giaTri]}\n"
                  "NXB: ${_dsSach[index][TruongThongTinSachTuInternet.nxb.giaTri]}"
                ),
                coChu: CoChu.nho,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              isThreeLine: true,
              onTap: () {
                Map<String, String> thongTinSach = _dsSach[index];
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
          itemCount: _dsSach.length
        )
      ),
      khiDong: () => _dongHopThoaiChonSach(null),
    );
  }

  void _khiNhanLui() {
    _webController.goBack();
  }

  void _khiNhanTien() {
    _webController.goForward();
  }

}

/// Màn hình web
class _ManHinhWeb extends StatelessWidget  {

  final DieuKhienManHinhWeb dkManHinh;

  const _ManHinhWeb({required this.dkManHinh});

  @override
  Widget build(BuildContext context) {
    List<Widget> nutPhai = [
      NutBamBieuTuong(
        bieuTuong: Icons.input,
        khiNhan: dkManHinh._khiNhanNutTrichXuat,
        thuocThanhDieuHuong: true,
        dieuKhien: dkManHinh._dkNutTrichXuat
      ),
      ManHinhCoSo.taoNutHuongDan(KieuHuongDan.web)
    ];
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    return ManHinhCoSo(
      tieuDe: dkManHinh._tieuDeManHinh,
      khiNhanQuayLai: dkManHinh._khiNhanQuayLai,
      khiNhanTieuDe: dkManHinh._khiNhanTieuDeManHinh,
      nutPhai: nutPhai,
      noiDung: Column(
        children: [
          Expanded(child: WebViewWidget(key: dkManHinh.khoaWidgetGoc, controller: dkManHinh._webController)),
          Container(
            color: phongCach.mauChinh,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NutBamBieuTuong(
                  bieuTuong: Icons.arrow_back,
                  thuocThanhDieuHuong: true,
                  khiNhan: dkManHinh._khiNhanLui
                ),
                NutBamBieuTuong(
                  bieuTuong: Icons.open_in_browser,
                  thuocThanhDieuHuong: true,
                  khiNhan: dkManHinh._khiNhanNutTrinhDuyet
                ),
                NutBamBieuTuong(
                  bieuTuong: Icons.refresh,
                  thuocThanhDieuHuong: true,
                  khiNhan: dkManHinh._khiNhanTaiLaiTrang
                ),
                NutBamBieuTuong(
                  bieuTuong: Icons.arrow_forward,
                  thuocThanhDieuHuong: true,
                  khiNhan: dkManHinh._khiNhanTien
                )
              ]
            )
          ),
          Container(height: 30, color: phongCach.mauChinh)
        ],
      )
    );
  }

}
