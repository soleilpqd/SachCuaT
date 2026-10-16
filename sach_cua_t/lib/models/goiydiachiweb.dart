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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sach_cua_t/models/database.dart';
import 'package:sach_cua_t/views/truong_van_ban.dart';

/// Gợi ý địa chỉ web để nhập thông tin sách
class GoiYDiaChiWeb extends GoiYVanBan {

  final String tenSach;
  final String isbn;
  final void Function() khiNapXong;
  void Function(String)? khiChonGoiY;
  final List<String> _dsWebsites = [];

  GoiYDiaChiWeb({required this.tenSach, required this.isbn, required this.khiNapXong}) {
    _napDanhSachWebsites();
  }

  Future<void> _napDanhSachWebsites() async {
    final String tenTep = "websites.json";
    File tepJson = File(join(CoSoDuLieu().thuMucCoSo, tenTep));
    if (await tepJson.exists()) {
      final noiDung = await tepJson.readAsString();
      await _napDsWebsiteTu(noiDung);
    }
    if (_dsWebsites.isEmpty) {
      final noiDung = await rootBundle.loadString(join("assets", tenTep));
      await _napDsWebsiteTu(noiDung);
    }
    khiNapXong();
  }

  Future<void> _napDsWebsiteTu(String duLieu) async {
    try {
      final dynamic dsWebsites = jsonDecode(duLieu);
      if (dsWebsites != null && dsWebsites is List<dynamic>) {
        for (final muc in dsWebsites) {
          if (muc is Map<String, dynamic>) {
            final dynamic laWebThongTin = muc["thong_tin"];
            if (laWebThongTin is bool && laWebThongTin) {
              final url = muc["url"];
              final thamSo = muc["tham_so"];
              final nhomIsbn = muc["isbn_nhom"];
              final dauChiaIsbn = muc["isbn_chia"];
              if (url is String && thamSo is Map<String, dynamic>) {
                _napWebsiteTu(url, thamSo, nhomIsbn, dauChiaIsbn);
              }
            }
          }
        }
      }
    } catch (err){
      print("JSON ERROR $err");
    }
  }

  String _xayDungTuKhoa(dynamic nhomIsbn, dynamic dauChiaIsbn) {
    final List<int> nIsbn = [];
    if (nhomIsbn is List<dynamic>) {
      for (final muc in nhomIsbn) {
        if (muc is int) {
          nIsbn.add(muc);
        }
      }
    }
    String ketQua = "";
    if (isbn.isNotEmpty && dauChiaIsbn is String && dauChiaIsbn.isNotEmpty && nIsbn.isNotEmpty) {
      int stt = 0;
      int batDau = 0;
      for (final muc in nIsbn) {
        int ketThuc = muc + batDau;
        ketQua += isbn.substring(batDau, ketThuc);
        batDau += muc;
        if (stt < nIsbn.length - 1) {
          ketQua += dauChiaIsbn;
        }
        stt += 1;
      }
    }
    if (tenSach.isNotEmpty) {
      if (ketQua.isNotEmpty) {
        ketQua += " $tenSach";
      } else {
        ketQua = tenSach;
      }
    }
    return ketQua;
  }

  void _napWebsiteTu(String url, Map<String, dynamic> thamSo, dynamic nhomIsbn, dynamic dauChiaIsbn) {
    final String giuCho = "%TK%";
    String link = url;
    String ts = "";
    int stt = 0;
    String tuKhoa = _xayDungTuKhoa(nhomIsbn, dauChiaIsbn);
    if (link.contains(giuCho)) {
      link = link.replaceAll(giuCho, Uri.encodeComponent(tuKhoa));
    }
    thamSo.forEach((khoa, giaTri) {
      String gt = "";
      if (giaTri is String && giaTri.contains(giuCho)) {
        if (tuKhoa.isNotEmpty) {
          gt = giaTri.replaceAll(giuCho, tuKhoa);
        }
      } else if (giaTri != null) {
        gt = "$giaTri";
      }
      if (gt.isNotEmpty) {
        ts += "${Uri.encodeComponent(khoa)}=${Uri.encodeComponent(gt)}";
      }
      if (stt < thamSo.length - 1) {
        ts += "&";
      }
      stt += 1;
    });
    if (ts.isNotEmpty) {
      link += "?$ts";
    }
    _dsWebsites.add(link);
  }

  @override
  Future<List<String>> timKiemGoiY(String dauVao, TruongVanBan widget) async {
    final List<String> ketQua = _dsWebsites.where((test) {
      final String gt1 = test.toLowerCase();
      final String gt2 = dauVao.toLowerCase();
      return gt1 != gt2 && gt1.contains(gt2);
    }).toList();
    if (ketQua.isEmpty) {
      return _dsWebsites.toList();
    }
    return ketQua;
  }

  @override
  void daChonGoiY(String tuKhoa) {
    super.daChonGoiY(tuKhoa);
    khiChonGoiY?.call(tuKhoa);
  }

}
