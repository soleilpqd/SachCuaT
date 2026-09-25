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
import 'package:sach_cua_t/views/truong_tieu_de.dart';

/// ListView theo phân đoạn
mixin ListViewTheoPhanDoan {

  /// Số lượng phân đoạn
  int soLuongPhanDoan();
  /// Số mục của phân đoạn [doan]
  int soMucCuaPhanDoan(int doan);
  /// TruongTieuDe tiêu đề cho đoạn [doan]
  TruongTieuDe? tieuDeChoDoan(int doan);
  /// Các widget cho phân đoạn [doan]. Nếu kết quả khác null thì bỏ qua `soMucCuaPhanDoan`, `widgetCuaMuc`, `khoangCachPhiaTren`, `khoangCachPhiaDuoi`
  List<Widget>? widgetsCuaCaDoan(int doan);
  /// Widget cho mục ở đoạn [doan] dòng [dong]
  Widget? widgetCuaMuc(int doan, int dong);
  /// Khoảng trống phía trên cho mục ở đoạn [doan] dòng [dong]
  double? khoangCachPhiaTren(int doan, int dong);
  /// Khoảng trống phái dưới cho mục ở đoạn [doan] dòng [dong]
  double? khoangCachPhiaDuoi(int doan, int dong);

  /// Xây dựng list view
  /// [key] và [scrollCtrl] nên được lưu tại điều khiển màn hình
  /// để ListView giữ được offset sau mỗi lần setState
  ListView xayDungListView(BuildContext context, {Key? key, ScrollController? scrollCtrl}) {
    return ListView(
      key: key,
      controller: scrollCtrl,
      padding: const EdgeInsets.all(5),
      children: _xayDungCacWidgetCon()
    );
  }

  List<Widget> _xayDungCacWidgetCon() {
    List<Widget> children = [];
    final int soDoan = soLuongPhanDoan();
    for (int doan = 0; doan < soDoan; doan += 1) {
      final List<Widget>? toanBoWidgets = widgetsCuaCaDoan(doan);
      int soMuc = 0;
      if (toanBoWidgets != null) {
        soMuc = toanBoWidgets.length;
      } else {
        soMuc = soMucCuaPhanDoan(doan);
      }
      if (soMuc == 0) {
        continue;
      }
      final TruongTieuDe? tieuDe = tieuDeChoDoan(doan);
      if (tieuDe != null) {
        children.add(tieuDe);
      }
      if (toanBoWidgets != null) {
        children.addAll(toanBoWidgets);
      } else {
        for (int muc = 0; muc < soMuc; muc += 1) {
          double? khoangTrong = khoangCachPhiaTren(doan, muc);
          if (khoangTrong != null && khoangTrong > 0) {
            children.add(SizedBox(height: khoangTrong));
          }
          final Widget? widMuc = widgetCuaMuc(doan, muc);
          if (widMuc != null) {
            children.add(widMuc);
          }
          khoangTrong = khoangCachPhiaDuoi(doan, muc);
          if (khoangTrong != null && khoangTrong > 0) {
            children.add(SizedBox(height: khoangTrong));
          }
        }
      }
    }
    return children;
  }

}
