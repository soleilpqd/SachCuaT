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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Kiểu tính tỉ lệ khung ảnh
enum KieuTiLeKhungAnh {
  /// Tính tỉ lệ sao cho khung ảnh khít với khung hiển thị
  khit,
  /// Tính tỉ lệ sao cho khung ảnh lấp đầy khung hiển thị
  lapDay
}

/// Cơ sở để tính kích thước khung ảnh
enum CoSoTiLeKhungAnh {
  /// Tính dựa trên kích thước gốc
  theoKichThuocGoc,
  /// Tính dựa trên kích thước khung hiển thị
  theoKhungHienThi
}

/// Cấu hình tỉ lệ để tính kích thước khung ảnh
/// - Kích thước giới hạn = Kích thước cơ sở * Tỉ lệ.
/// - Kích thước khung hình = Kiểu tỉ lệ áp dụng vào Kích thước giới hạn.
/// - Tỉ lệ kết quả  = kích thước hiển thị / kích thước khung hình.
class TiLeKhungAnh {
  /// Tỉ lệ
  final double tiLe;
  /// Kiểu tính
  final KieuTiLeKhungAnh kieu;
  /// Cơ sở để tính
  final CoSoTiLeKhungAnh coSo;
  /// Áp dụng khi tính theo cơ sở khung hiển thị, `true` thì nếu kích thước gốc nhỏ hơn kích thước khung ảnh thì lấy kích thước gốc
  final bool uuTienGoc;

  TiLeKhungAnh({required this.tiLe, required this.kieu, required this.coSo, required this.uuTienGoc});
}

/// Cấu hình cơ sở để điểu khiển khung ảnh hoạt động
class CauHinhCoSoKhungAnh {

  /// Kích thước ngang (Width) của view ảnh (`null` để tự động xác định)
  final double? ngang;
  /// Kích thước dọc (Height) của view ảnh (`null` để tự động xác định)
  final double? doc;
  /// Các giới hạn tỉ lệ thay đổi khung hình
  final List<TiLeKhungAnh> tiLeThayDoi;
  /// Các mốc tỉ lệ cho thao tác nhấn kép
  final List<TiLeKhungAnh> tiLeMoc;

  CauHinhCoSoKhungAnh({this.ngang, this.doc, required this.tiLeThayDoi, required this.tiLeMoc});

}

/// Điều khiển khung ảnh
class DieuKhienKhungAnh {

  /// Cấu hình điều khiển hoạt động.
  CauHinhCoSoKhungAnh? cauHinh;

  /// Key của InteractiveViewer
  final GlobalKey _keyKhungCuon = GlobalKey();
  /// Key của Container chứa view ảnh
  final GlobalKey _keyKhungAnh = GlobalKey();
  _TrangThaiKhungChuaAnh? get _trangThaiKhung {
    return _keyKhungAnh.currentState as _TrangThaiKhungChuaAnh?;
  }
  /// Điều khiển Transformation của InteractiveViewer
  final TransformationController _transformer = TransformationController();
  /// Kích thước gốc của view ảnh (lấy từ Container chứa view ảnh)
  Size? _kichThuocGoc;
  /// Tỉ lệ thu phóng hiện tại
  double? _tiLeHienTai;
  /// Tỉ lệ mốc cho thao tác thu phóng 2 ngón
  double? _tiLeMoc;
  /// Danh sách các tỉ lệ (đã tính)
  List<double> _dsCacTiLe = [];
  /// Danh sách các tỉ lệ dùng cho Nhấn kép
  final List<double> _dsTiLeKep = [];
  /// Điểm mốc (điểm chạp trên khung hiển thị)
  Offset? _diemMoc;
  /// Điểm mốc tương ứng trên view nội dung ở tỉ lệ 1
  Offset? _diemMocNoiDung;
  // Giá trị lấy từ _TrangThaiKhungCuonTheoKichThuoc
  /// Kích thước ngang khung hiển thị
  double? _kichThuocNgangKhungChua;
  /// Kích thước dọc khung hiển thị
  double? _kichThuocDocKhungChua;
  // Giá trị dùng cho _TrangThaiKhungCuonTheoKichThuoc
  /// Kích thước ngang hiện tại cho Container chứa widget nội dung
  double? _kichThuocNgangNoiDung;
  /// Kích thước dọc hiện tại cho Container chứa widget nội dung
  double? _kichThuocDocNoiDung;
  /// Kích thước ngang hiện tại cho Container nền (quyết định kích thước scroll) ≥ _kichThuocNgangNoiDung
  double? _kichThuocNgangNen;
  /// Kích thước dọc hiện tại cho Container nền (quyết định kích thước scroll) ≥ _kichThuocDocNoiDung
  double? _kichThuocDocNen;

  /// Constructor
  DieuKhienKhungAnh({this.cauHinh}) {
    _boCucLai(canNapLai: false);
  }

  /// Cập nhật khung chứa (hàm gọi từ widget `KhungAnh`)
  void _capNhatKhungChua(double ngang, double doc) {
    _kichThuocNgangKhungChua = ngang;
    _kichThuocDocKhungChua = doc;
    _boCucLai(canNapLai: false);
  }

  void _capNhatKichThuocGoc(Size kichThuoc) {
    _kichThuocGoc = kichThuoc;
    _boCucLai(canNapLai: true);
  }

  /// Đặt cấu hình để điều khiển việc bố cục hiển thị (ở đây sẽ xoá hết các trạng thái trước đó)
  void datCauHinh(CauHinhCoSoKhungAnh caiDat) {
    _tiLeHienTai = null;
    _diemMoc = null;
    _diemMocNoiDung = null;
    cauHinh = caiDat;
    _boCucLai(canNapLai: true);
  }

  /// Khi nhấn kép xuống (đánh dấu điểm mốc cho nhấn kép)
  void _khiNhanKepXuong(TapDownDetails thongTin) {
    _diemMoc = thongTin.localPosition;
    _tinhDiemMocNoiDung();
  }

  /// Khi nhấn kép: thay đổi tỉ lệ hiện tại đến tỉ lệ mốc tiếp theo
  void _khiNhanKep() {
    _kiemTraTiLeHienTai(true);
    _apDungTiLeCoDan(true);
    _diemMoc = null;
    _diemMocNoiDung = null;
  }

  /// Khi người dùng bắt đầu thu phóng (co dãn 2 ngón)
  void _khiBatDauCoDan(ScaleStartDetails thongTin) {
    if (thongTin.pointerCount != 2) { return; }
    _tiLeMoc = _tiLeHienTai;
    _diemMoc = thongTin.localFocalPoint;
    _tinhDiemMocNoiDung();
  }

  /// Khi thu phóng cập nhật
  void _khiThayDoiCoDan(ScaleUpdateDetails thongTin) {
    if (thongTin.pointerCount != 2 || _tiLeMoc == null) { return; }
    final double thayDoi = thongTin.scale - 1;
    _tiLeHienTai = _tiLeMoc! + thayDoi;
    _kiemTraTiLeHienTai(false);
    _apDungTiLeCoDan(true);
  }

  /// Khi thu phóng kết thúc
  void _khiKetThucCoDan(ScaleEndDetails thongTin) {
    if (thongTin.pointerCount != 2) { return; }
    _tiLeMoc = null;
    _diemMoc = null;
    _diemMocNoiDung = null;
  }

  /// Kích thước ngang cần hiển thị: ưu tiên từ cấu hình,
  /// hoặc lấy từ kích thước bố cục gốc trên màn hình
  double? _ktNgangNoiDung() {
    double? gt = cauHinh?.ngang;
    if (gt != null) {
      return gt;
    }
    return _kichThuocGoc?.width;
  }

  /// Kích thước dọc cần hiển thị: ưu tiên từ cấu hình,
  /// hoặc lấy từ kích thước bố cục gốc trên màn hình
  double? _ktDocNoiDung() {
    double? gt = cauHinh?.doc;
    if (gt != null) {
      return gt;
    }
    return _kichThuocGoc?.height;
  }

  /// Tính tỉ lệ theo 1 cấu hình cụ thể
  double _tinhTiLe(TiLeKhungAnh chTiLe) {
    final double ktNgang = _ktNgangNoiDung()!;
    final double ktDoc = _ktDocNoiDung()!;
    double gioiHanNgang = switch (chTiLe.coSo) {
      CoSoTiLeKhungAnh.theoKhungHienThi => _kichThuocNgangKhungChua!,
      CoSoTiLeKhungAnh.theoKichThuocGoc => ktNgang
    } * chTiLe.tiLe;
    if (chTiLe.uuTienGoc && chTiLe.coSo == CoSoTiLeKhungAnh.theoKhungHienThi) {
      final double gioiHanNgangTheoGoc = ktNgang * chTiLe.tiLe;
      if (gioiHanNgangTheoGoc < gioiHanNgang) {
        gioiHanNgang = gioiHanNgangTheoGoc;
      }
    }
    double gioiHanDoc = switch (chTiLe.coSo) {
      CoSoTiLeKhungAnh.theoKhungHienThi => _kichThuocDocKhungChua!,
      CoSoTiLeKhungAnh.theoKichThuocGoc => ktDoc
    } * chTiLe.tiLe;
    if (chTiLe.uuTienGoc && chTiLe.coSo == CoSoTiLeKhungAnh.theoKhungHienThi) {
      final double gioiHanDocTheoGoc = ktDoc * chTiLe.tiLe;
      if (gioiHanDocTheoGoc < gioiHanDoc) {
        gioiHanDoc = gioiHanDocTheoGoc;
      }
    }
    final double tiLeNgang = gioiHanNgang / ktNgang;
    final double tiLeDoc = gioiHanDoc / ktDoc;
    double ketQua = switch (chTiLe.kieu) {
      KieuTiLeKhungAnh.khit => min(tiLeNgang, tiLeDoc),
      KieuTiLeKhungAnh.lapDay => max(tiLeNgang, tiLeDoc)
    };
    return ketQua;
  }

  /// Kiểm tra tỉ lệ hiển thị hiện tại.
  /// Nếu chưa đặt hoặc vượt quá giới hạn thì đặt lại.
  void _kiemTraTiLeHienTai(bool tangTiLeHt) {
    if (_dsCacTiLe.isEmpty) {
      _tiLeHienTai = null;
      return;
    }
    if (_tiLeHienTai == null) {
      _tiLeHienTai = _dsCacTiLe.first;
    } else if (tangTiLeHt) {
      bool timThay = false;
      for (final double muc in _dsTiLeKep) {
        if (_tiLeHienTai! < muc) {
          timThay = true;
          _tiLeHienTai = muc;
          break;
        }
      }
      if (!timThay) {
        _tiLeHienTai = _dsTiLeKep.first;
      }
    }
    if (_tiLeHienTai! < _dsCacTiLe.first) {
      _tiLeHienTai = _dsCacTiLe.first;
    }
    if (_tiLeHienTai! > _dsCacTiLe.last) {
      _tiLeHienTai = _dsCacTiLe.last;
    }
  }

  /// Tính tỉ lệ mốc cho thao tác nhấn kép
  /// (bao gồm: tỉ lệ nhỏ nhất, tỉ lệ khít hình với khung, tỉ lệ lấp đầy hình với khung, tỉ lệ lớn nhất).
  void _tinhTiLeMoc() {
    _dsTiLeKep.clear();
    if (_dsCacTiLe.length < 2) {
      return;
    }
    List<double> dsTiLe = cauHinh!.tiLeMoc.map((muc) => _tinhTiLe(muc)).toList();
    for (final muc in dsTiLe) {
      if (muc >= _dsCacTiLe.first && muc <= _dsCacTiLe.last && !_dsTiLeKep.contains(muc)) {
        _dsTiLeKep.add(muc);
      }
    }
    _dsTiLeKep.sort();
  }

  /// Tính lại vị trí cuộn sau cập nhật (dựa trên điểm mốc đã lưu trước cập nhật)
  void _tinhLaiLeCuon() {
    if (
      _diemMoc == null ||
      _diemMocNoiDung == null
    ) {
      return;
    }
    final double mocNDNgang = _diemMocNoiDung!.dx * _tiLeHienTai!;
    final double mocNDDoc = _diemMocNoiDung!.dy * _tiLeHienTai!;
    final double leTrai = (_kichThuocNgangNen! - _kichThuocNgangNoiDung!) / 2;
    final double leTren = (_kichThuocDocNen! - _kichThuocDocNoiDung!) / 2;
    final double mocNgang = leTrai + mocNDNgang;
    final double mocDoc = leTren + mocNDDoc;
    final double gioiHanNgang = _kichThuocNgangNen! - _kichThuocNgangKhungChua!;
    final double gioiHanDoc = _kichThuocDocNen! - _kichThuocDocKhungChua!;
    double doLechNgang = mocNgang - _diemMoc!.dx;
    double doLechDoc = mocDoc - _diemMoc!.dy;
    if (doLechNgang < 0) {
      doLechNgang = 0;
    }
    if (doLechNgang > gioiHanNgang) {
      doLechNgang = gioiHanNgang;
    }
    if (doLechDoc < 0) {
      doLechDoc = 0;
    }
    if (doLechDoc > gioiHanDoc) {
      doLechDoc = gioiHanDoc;
    }
    _transformer.value = Matrix4.translationValues(-doLechNgang, -doLechDoc, 0);
  }

  /// Bố cục lại
  void _boCucLai({required bool canNapLai}) {
    final double? ktNgang = _ktNgangNoiDung();
    final double? ktDoc = _ktDocNoiDung();

    if (_kichThuocNgangKhungChua == null || _kichThuocDocKhungChua == null || cauHinh == null || ktNgang == null || ktDoc == null) {
      // Hiển thị 1 cách tự nhiên
      _kichThuocNgangNoiDung = null;
      _kichThuocDocNoiDung = null;
      _kichThuocNgangNen = null;
      _kichThuocDocNen = null;
      return;
    }
    // Tính các tỉ lệ giới hạn theo cấu hình
    _dsCacTiLe = cauHinh!.tiLeThayDoi.map((muc) => _tinhTiLe(muc)).toList();
    _dsCacTiLe.sort();
    // Tính tỉ lệ mốc cho thao tác nhấn kép
    _tinhTiLeMoc();
    // Kiểm tra và tính lại tỉ lệ thu phóng hiện tại
    _kiemTraTiLeHienTai(false);
    // Áp dụng tỉ lệ thu phóng
    _apDungTiLeCoDan(canNapLai);
  }

  /// Áp dụng tỉ lệ thu phóng vào kích thước hiển thị lên màn hình
  void _apDungTiLeCoDan(bool canNapLai) {
    final double ktNgang = _ktNgangNoiDung()!;
    final double ktDoc = _ktDocNoiDung()!;
    if (_tiLeHienTai == null) {
      // Không thu phóng
      _kichThuocNgangNoiDung = ktNgang;
      _kichThuocDocNoiDung = ktDoc;
      _kichThuocNgangNen = ktNgang;
      _kichThuocDocNen = ktDoc;
    } else {
      _kichThuocNgangNoiDung = ktNgang * _tiLeHienTai!;
      _kichThuocDocNoiDung = ktDoc * _tiLeHienTai!;
      _kichThuocNgangNen = _kichThuocNgangNoiDung;
      if (_kichThuocNgangKhungChua! > _kichThuocNgangNoiDung!) {
        _kichThuocNgangNen = _kichThuocNgangNen! + (_kichThuocNgangKhungChua! - _kichThuocNgangNoiDung!);
      }
      _kichThuocDocNen = _kichThuocDocNoiDung;
      if (_kichThuocDocKhungChua! > _kichThuocDocNoiDung!) {
        _kichThuocDocNen = _kichThuocDocNen! + (_kichThuocDocKhungChua! - _kichThuocDocNoiDung!);
      }
    }
    if (canNapLai) {
      _trangThaiKhung?.napLai();
    }
    // Di chuyển phần nội dung
    _tinhLaiLeCuon();
  }

  /// Từ điểm mốc trên khung hiển thị, tính toạ độ tương ứng trên widget nội dung ở tỉ lệ 1 làm điểm mốc nội dung.
  void _tinhDiemMocNoiDung() {
    if (
      _diemMoc == null ||
      _kichThuocNgangNen == null ||
      _kichThuocDocNen == null ||
      _kichThuocNgangNoiDung == null ||
      _kichThuocDocNoiDung == null ||
      _tiLeHienTai == null
    ) {
      return;
    }
    /*
    +------------------
    |       t
    |   +-------
    |   |   y
    |-l-|-x-*
    |   |

    Toạ độ điểm mốc trên khung hiển thị là bao gồm lề trên, lề trái + toạ độ trên widget nội dung.
     */
    final Vector3 trans = _transformer.value.getTranslation();
    final double cuonLeTrai = max(0, -trans.x);
    final double cuonLeTren = max(0, -trans.y);
    final double leTrai = (_kichThuocNgangNen! - _kichThuocNgangNoiDung!) / 2;
    final double leTren = (_kichThuocDocNen! - _kichThuocDocNoiDung!) / 2;
    final double mocNgang = (cuonLeTrai + _diemMoc!.dx) - leTrai;
    final double mocDoc = (cuonLeTren + _diemMoc!.dy) - leTren;
    _diemMocNoiDung = Offset(mocNgang / _tiLeHienTai!, mocDoc / _tiLeHienTai!);
  }

}

/// Khung ảnh: hiển thị widget [noiDung] trong 1 Container nằm trong `InteractiveViewer`.
/// Kích thước của Container sẽ do điều khiển quyết định.
/// Người dùng có thể dùng thao tác nhấn kép để thay đổi nhanh tỉ lệ kích thước theo các mốc,
/// hoặc dùng cử chỉ di 2 ngón để thay đổi tỉ lệ kích thước.
class KhungAnh extends StatelessWidget {

  /// Widget cần hiển thị. Cần chú ý [noiDung] được chứa trong 1 container có kích thước do điều khiển quyết định,
  /// cần cấu hình [noiDung] luôn lấp đầy container chứa nó (ví dụ ảnh nhỏ hơn khung hiển thị)
  final Widget noiDung;
  final DieuKhienKhungAnh dieuKhien;

  const KhungAnh({super.key, required this.noiDung, required this.dieuKhien});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      dieuKhien._capNhatKhungChua(constraint.maxWidth, constraint.maxHeight);
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onDoubleTapDown: dieuKhien._khiNhanKepXuong,
        onDoubleTap: dieuKhien._khiNhanKep,
        child: InteractiveViewer(
          key: dieuKhien._keyKhungCuon,
          constrained: false,
          minScale: 1,
          maxScale: 1,
          onInteractionStart: dieuKhien._khiBatDauCoDan,
          onInteractionUpdate: dieuKhien._khiThayDoiCoDan,
          onInteractionEnd: dieuKhien._khiKetThucCoDan,
          transformationController: dieuKhien._transformer,
          child: _KhungChuaAnh(key: dieuKhien._keyKhungAnh, noiDung: noiDung, dieuKhien: dieuKhien)
        )
      );
    });
  }

}

class _KhungChuaAnh extends StatefulWidget {

  final Widget noiDung;
  final DieuKhienKhungAnh dieuKhien;

  const _KhungChuaAnh({required super.key, required this.noiDung, required this.dieuKhien});

  @override
  State<StatefulWidget> createState() => _TrangThaiKhungChuaAnh();

}

class _TrangThaiKhungChuaAnh extends State<_KhungChuaAnh> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _layKichThuocNoiDungGoc());
  }

  void _layKichThuocNoiDungGoc() {
    if (widget.key != null && widget.key is GlobalKey) {
      final GlobalKey khoa = widget.key as GlobalKey;
      final RenderBox? renderBox = khoa.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        widget.dieuKhien._capNhatKichThuocGoc(renderBox.size);
      }
    }
  }

  void napLai() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: widget.dieuKhien._kichThuocNgangNen,
      height: widget.dieuKhien._kichThuocDocNen,
      child: Center(child: Container(
        color: Colors.transparent,
        width: widget.dieuKhien._kichThuocNgangNoiDung,
        height: widget.dieuKhien._kichThuocDocNoiDung,
        child: widget.noiDung,
      ))
    );
  }

}
