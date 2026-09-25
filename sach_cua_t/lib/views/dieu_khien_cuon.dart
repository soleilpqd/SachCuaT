/*
  Sách của T - Quản lý sách cá nhân
  Copyright © 2026 SoleilPQD

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

class DieuKhienCuon {

  late ScrollController _dkCuon;
  ScrollController get dkCuon => _dkCuon;
  double? _doLechHienTai;

  DieuKhienCuon() {
    _dkCuon = ScrollController(
      onAttach: _khiGanCuon,
      onDetach: _khiTachCuon
    );
  }

  bool _khoiPhucViTri() {
    if (_doLechHienTai != null && _doLechHienTai != _dkCuon.offset && _dkCuon.position.hasContentDimensions) {
      _dkCuon.jumpTo(_doLechHienTai!);
      return true;
    }
    return false;
  }

  void _khiGanCuon(ScrollPosition viTriCuon) {
    viTriCuon.isScrollingNotifier.addListener(_khiCuonThayDoi);
    if (!_khoiPhucViTri()) {
      Future.delayed(const Duration(milliseconds: 100)).then((_) => _khoiPhucViTri());
    }
  }

  void _khiTachCuon(ScrollPosition viTriCuon) {
    viTriCuon.isScrollingNotifier.removeListener(_khiCuonThayDoi);
  }

  void _khiCuonThayDoi() {
    _doLechHienTai = _dkCuon.offset;
  }

  void cuonLenDau({Duration? thoiGianChuyenDong}) {
    if (thoiGianChuyenDong != null && thoiGianChuyenDong == Duration.zero) {
      _dkCuon.jumpTo(0);
    }
    _dkCuon.animateTo(0, duration: thoiGianChuyenDong ?? const Duration(milliseconds: 100), curve: Curves.bounceOut);
  }

}
