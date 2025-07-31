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

abstract class GoiYVanBan {
  List<String> timKiemGoiY(String dauVao) => [];
}

class TruongVanBan {

  TruongVanBan({required this.tieuDe, this.kieuBanPhim = TextInputType.text, this.thongBaoLoi, this.khiTrangThaiNhapThayDoi});

  TextEditingController? _textEditingController;
  FocusNode? _focusNode;
  GoiYVanBan? goiY;
  String tieuDe = "";
  String? thongBaoLoi;
  TextInputType kieuBanPhim = TextInputType.text;
  void Function(bool coTheNhap)? khiTrangThaiNhapThayDoi;

  String? get text => _textEditingController?.text;
  set text(String? newText) => _textEditingController?.text = newText ?? "";

  Widget build(BuildContext context, {Widget? accesoryWidget, String text = ""}) {
    List<Widget> children = [];
    children.add(
      Expanded(child: Autocomplete<String>(
        initialValue: TextEditingValue(text: text),
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          _textEditingController = textEditingController;
          if (_focusNode != null) {
            _focusNode?.removeListener(_onFocusChange);
            _focusNode = null;
          }
          _focusNode = focusNode;
          _focusNode?.addListener(_onFocusChange);
          return TextFormField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: thongBaoLoi != null ? Colors.red : Colors.grey)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor))
            ),
            keyboardType: kieuBanPhim,
            controller: textEditingController,
            focusNode: focusNode,
            onFieldSubmitted: (value) {
              // onFieldSubmitted();
            }
          );
        },
        optionsBuilder: (value) {
          return []; // [value.text + "A", value.text + "B", value.text + "C"];
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Container(
            color: Colors.white,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              separatorBuilder: (context, index) => SizedBox(height: 1, child: Container(color: Colors.grey)),
              itemBuilder: (context, index) {
                final String opt = options.toList()[index];
                return TextButton(
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))),
                    foregroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                  onPressed: () => onSelected(opt),
                  child: Row(
                    children: [
                      Text(opt),
                      Text(opt, style: const TextStyle(fontWeight: FontWeight.bold))
                    ]
                  )
                );
              }
            )
          );
        },
        onSelected: (option) {
          print("SELECT $option");
        })
      )
    );
    if (accesoryWidget != null) {
      children.add(accesoryWidget);
    }
    List<Widget> mainChildren = [
      Text(tieuDe, textAlign: TextAlign.left),
      Row(children: children)
    ];
    if (thongBaoLoi != null) {
      mainChildren.add(
        Text(thongBaoLoi!, style: const TextStyle(color: Colors.red))
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mainChildren
    );
  }

  void _onFocusChange() {
    if (_focusNode != null && khiTrangThaiNhapThayDoi != null) {
      khiTrangThaiNhapThayDoi!(_focusNode!.hasFocus);
    }
  }

}