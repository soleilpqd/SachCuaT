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
import 'package:sach_cua_t/utils/common.dart';
import 'package:sach_cua_t/utils/vanbanhienthi.dart';
import 'package:sach_cua_t/views/phong_cach_giao_dien.dart';

/// Text widget mở rộng cho việc nạp Văn bản hiển thị
class VbhtWidget extends StatefulWidget {

  final Vbht text;
  final CoChu coChu;
  final bool khaDung;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final Vbht? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const VbhtWidget({
    required this.text,
    required this.coChu,
    this.khaDung = true,
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor
  });

  @override
  State<StatefulWidget> createState() => _VbhtWidgetState();

}

class _VbhtWidgetState extends State<VbhtWidget> {

  @override
  void initState() {
    super.initState();
    _napLaiDuLieu();
  }

  @override
  void didUpdateWidget(covariant VbhtWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _napLaiDuLieu();
  }

  void _napLaiDuLieu() {
    widget.text.khiXong = (_) => datTrangThaiKhiAnToan();
    widget.semanticsLabel?.khiXong = (_) => datTrangThaiKhiAnToan();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    final PhongCachGiaoDien phongCach = PhongCachGiaoDien();
    if (widget.style != null) {
      style = widget.style!.copyWith(
        color: widget.style?.color ?? (widget.khaDung ? phongCach.mauNoiDungNen : phongCach.mauNoiDungKhoaNen),
        fontFamily: phongCach.tenFont,
        fontSize: phongCach.coFont(widget.coChu)
      );
    } else {
      style = TextStyle(
        color: widget.style?.color ?? (widget.khaDung ? phongCach.mauNoiDungNen : phongCach.mauNoiDungKhoaNen),
        fontFamily: phongCach.tenFont,
        fontSize: phongCach.coFont(widget.coChu)
      );
    }
    return Text(
      widget.text.vanBan,
      style: style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel?.vanBan,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor
    );
  }

}
