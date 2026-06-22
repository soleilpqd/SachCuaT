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
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Nút bấm chỉ có tiêu đề (ko hiệu ứng nền)
class NutBamTieuDe extends TextButton {

  NutBamTieuDe({
    super.key,
    required Vbht tieuDe,
    required bool khaDung,
    bool canChuY = false,
    void Function()? khiNhan
  }) : super(
    child: VbhtWidget(
      text: tieuDe,
      coChu: CoChu.binhThuong,
      style: TextStyle(color: khaDung ?
        (canChuY ? PhongCachGiaoDien().mauThaoTacCanChuY : PhongCachGiaoDien().mauChinh) :
        PhongCachGiaoDien().mauNoiDungKhoaNen,
      )
    ),
    style: const ButtonStyle(
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory
    ),
    onPressed: khiNhan
  );

}

class NutBamBieuTuongTieuDe extends IconButton {

  NutBamBieuTuongTieuDe({
    super.key,
    required IconData bieuTuong,
    double? kichThuocBieuTuong,
    required bool thuocThanhDieuHuong,
    required bool khaDung,
    bool canChuY = false,
    List<Shadow>? doBongBieuTuong,
    void Function()? khiNhan,
  }) : super(style: const ButtonStyle(
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory
    ),
    icon: Icon(bieuTuong, size: kichThuocBieuTuong, shadows: doBongBieuTuong, color: khaDung ?
      (canChuY ? PhongCachGiaoDien().mauThaoTacCanChuY : (thuocThanhDieuHuong ? PhongCachGiaoDien().mauNoiDungChinh : PhongCachGiaoDien().mauChinh)) :
      (thuocThanhDieuHuong ? PhongCachGiaoDien().mauNoiDungKhoaChinh : PhongCachGiaoDien().mauNoiDungKhoaNen)
    ),
    onPressed: khaDung ? khiNhan : null
  );

}
