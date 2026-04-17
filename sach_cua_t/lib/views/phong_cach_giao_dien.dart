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

/// Cỡ chữ
enum CoChu {
  /// Tiêu đề màn hình
  tieuDe,
  /// Nhỏ
  nho,
  /// Bình thường
  binhThuong,
  /// To, lớn
  to;
}

class PhongCachGiaoDien {

  Color _mauChinh;
  Color _mauNen;
  Color _mauNoiDungChinh;
  Color _mauNoiDungKhoaChinh;
  Color _mauNoiDungNen;
  Color _mauNoiDungKhoaNen;
  Color _mauThaoTacCanChuY;
  Color _mauVien;
  Color _mauDanhDauChinh;
  Color _mauDanhDauPhu;
  Color _mauDoBong;

  double _coFontTieuDe;
  double _coFontTo;
  double _coFontThuong;
  double _coFontNho;
  double _coFontSieuNho;
  String? _tenFont;

  /// Cấu hình mặc định
  PhongCachGiaoDien.macDinh() :
    _mauChinh = Colors.blueAccent,
    _mauNen = Colors.white,
    _mauNoiDungChinh = Colors.white,
    _mauNoiDungKhoaChinh = Colors.grey,
    _mauNoiDungNen = Colors.black,
    _mauNoiDungKhoaNen = Colors.grey,
    _mauThaoTacCanChuY = Colors.red,
    _mauDanhDauChinh = Colors.yellow,
    _mauDanhDauPhu = Colors.lightGreenAccent,
    _mauVien = Colors.grey,
    _mauDoBong = Colors.black.withAlpha(128),
    _coFontTieuDe = 24,
    _coFontTo = 18,
    _coFontThuong = 16,
    _coFontNho = 14,
    _coFontSieuNho = 11
    ;

  /// Object dùng chung
  static PhongCachGiaoDien _dungChung = PhongCachGiaoDien.macDinh();
  factory PhongCachGiaoDien() => _dungChung;

  /// Màu chính
  Color get mauChinh => _mauChinh;
  /// Màu nền
  Color get mauNen => _mauNen;
  /// Màu nội dung trên màu chính
  Color get mauNoiDungChinh => _mauNoiDungChinh;
  /// Màu nội dung bị khoá trên màu chính
  Color get mauNoiDungKhoaChinh => _mauNoiDungKhoaChinh;
  /// Màu nội dung trên màu nền
  Color get mauNoiDungNen => _mauNoiDungNen;
  /// Màu nội dung bị khoá trên màu nền
  Color get mauNoiDungKhoaNen => _mauNoiDungKhoaNen;
  /// Màu đường viền
  Color get mauVien => _mauVien;
  /// Màu đánh dấu chính
  Color get mauDanhDauChinh => _mauDanhDauChinh;
  /// Màu đánh dấu phụ
  Color get mauDanhDauPhu => _mauDanhDauPhu;
  /// Màu của thao tác cần chú ý
  Color get mauThaoTacCanChuY => _mauThaoTacCanChuY;
  /// Màu của nền phía sau dialog
  Color get mauDoBong => _mauDoBong;
  /// Cỡ font tiêu đề màn hình
  double get coFontTieuDe => _coFontTieuDe;
  /// Cỡ font to
  double get coFontTo => _coFontTo;
  /// Cỡ font thường
  double get coFontThuong => _coFontThuong;
  /// Cỡ font nhỏ
  double get coFontNho => _coFontNho;
  /// Cỡ font siêu nhỏ
  double get coFontSieuNho => _coFontSieuNho;
  /// Tên font
  String? get tenFont => _tenFont;

  double coFont(CoChu co) => switch(co) {
    CoChu.tieuDe => _coFontTieuDe,
    CoChu.nho => _coFontNho,
    CoChu.binhThuong => _coFontThuong,
    CoChu.to => _coFontTo
  };

}
