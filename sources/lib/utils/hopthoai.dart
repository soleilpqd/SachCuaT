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
import 'package:sach_cua_t/views/van_ban_hien_thi_widget.dart';

/// Hộp thoại thông báo
class HopThoai {

  /// Hiển thị hộp thoại thông báo với 1 nút
  static void hienThiThongBao(
    BuildContext context,
    {
      /// Nội dung
      required Vbht noiDung,
      /// Tiêu đề nút
      required Vbht nhanNut,
      // Xử lý khi nhấn (context của hộp thoại)
      Function(BuildContext)? khiDong
    }
  ) {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: VbhtWidget(text: noiDung),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              khiDong?.call(ctx);
            },
            child: VbhtWidget(text: nhanNut)
          )
        ],
      );
    });
  }

  /// Hiển thị hộp thoại thông báo với nhiều nút
  static void hienThiThongBaoNhieuNut(
    BuildContext context,
    {
      /// Nội dung
      required Vbht noiDung,
      /// Tiêu đề các nút
      required List<Vbht> nhanCacNut,
      /// Hàm xử lý khi nhấn nút (context của hộp thoại, thứ tự nút (từ 0), tiêu đề nút)
      required Function(BuildContext, int, Vbht) khiDong
    }
  ) {
    showDialog(context: context, builder: (ctx) {
      List<Widget> actions = [];
      for (int dem = 0; dem < nhanCacNut.length; dem += 1) {
        Vbht nhan = nhanCacNut[dem];
        actions.add(
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                khiDong.call(ctx, dem, nhan);
              },
              child: VbhtWidget(text: nhan)
            )
        );
      }
      return AlertDialog(
        title: VbhtWidget(text: noiDung),
        actions: actions,
      );
    });
  }

}