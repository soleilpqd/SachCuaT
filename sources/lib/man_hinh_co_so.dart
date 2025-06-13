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

/// Phần Navigation Bar dùng chung cho tất cả các màn hình.
class ManHinhCoSo extends StatelessWidget {

  final String tieuDe;
  final Widget? nutTrai;
  final Widget? nutPhai;
  final Widget noiDung;

  const ManHinhCoSo({super.key, required this.tieuDe, this.nutTrai, this.nutPhai, required this.noiDung});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tieuDe),
          actions: nutPhai != null ? [nutPhai!] : null,
          leading: nutTrai
        ),
        body: noiDung
      );
  }

}