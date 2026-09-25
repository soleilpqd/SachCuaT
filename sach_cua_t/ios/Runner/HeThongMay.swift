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

import UIKit
import Flutter
import SafariServices

/// Quản lý module Native iOS
final class HeThongMay {

    /// Tên hàm từ Flutter module
    enum TenHamTuFlutter: String {
        /// Quét mã ISBN
        case quetMaISBN
        /// Lưu ảnh sách
        case luuAnhSach
        /// Phiên bản
        case phienBan
        /// Chọn ảnh
        case chonAnh
        /// Dán tệp từ pasteboard
        case dan
        /// Mở màn hình chọn tệp
        case chonTep
        /// Chuẩn hoá ảnh
        case chuanHoaAnh
        /// Tìm kiếm ảnh
        case timKiemAnh
    }

    /// Tên hàm từ native module tới Flutter module
    enum TenHamDenFlutter: String {
        /// Kiểm tra ISBN
        case kiemTraISBN
        /// Nhận được tệp
        case nhanDuocTep
        /// Chuẩn hoá ảnh
        case chuanHoaAnh
    }

    enum KieuTep: Int {
        case anh = 0
        case zip
        case p7zip
    }

    enum KieuMedia: Int {
        case camera = 0
        case khoAnh
    }

    /// Duy nhất (Singleton)
    static var duyNhat: HeThongMay!

    /// Kênh kết nối
    private let kenhKetNoi: FlutterMethodChannel

    private var chuanHoaAnh: ChuanHoaAnh?
    private let boTimKiemAnh = BoXuLyTimKiemAnh()

    public static func register(with messenger: any FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "sach.cua.T", binaryMessenger: messenger)
        let instance = HeThongMay(kenh: channel)
        duyNhat = instance
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(kenh: FlutterMethodChannel) {
        kenhKetNoi = kenh
        kenhKetNoi.setMethodCallHandler { call, result in
            HeThongMay.duyNhat.xuLyHam(call: call, result: result)
        }
    }

    /// Xử lý hàm
    private func xuLyHam(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(#function, call.method)
        guard let ham = TenHamTuFlutter(rawValue: call.method) else {
            result(FlutterError(code: "1", message: "Hàm không xác định", details: call.method))
            return
        }
        switch ham {
        case .quetMaISBN:
            if let rootController = AppDelegate.app.rootViewController,
               let manHinh = rootController.storyboard?.instantiateViewController(withIdentifier: "ManHinhCamera") as? ManHinhCamera {
                manHinh.resultHandle = result
                manHinh.kieuQuet = .isbn
                manHinh.chuanBi {
                    rootController.present(manHinh, animated: true)
                }
            }
        case .luuAnhSach:
            luuAnhSach(call: call, result: result)
        case .phienBan:
            let phienBan = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
            result(phienBan)
        case .chonAnh:
            chonAnh(call: call, result: result)
        case .dan:
            dan(call: call, result: result)
        case .chonTep:
            break
        case .chuanHoaAnh:
            chuanHoaAnh(call: call, result: result)
        case .timKiemAnh:
            timKiemAnh(call: call, result: result)
        }
    }

    /// Kiểm tra ISBN (hàm native -> Flutter)
    func kiemTraISBN(giaTri: String, nhanKetQua: @escaping (Bool) -> Void) {
        kenhKetNoi.invokeMethod(TenHamDenFlutter.kiemTraISBN.rawValue, arguments: giaTri) { value in
            if let val = value as? Bool {
                nhanKetQua(val)
            }
        }
    }

    /// Co dãn ảnh
    func coDanAnh(dauVao: UIImage, toiDa: Int) -> UIImage? {
        let caoF: CGFloat
        let rongF:CGFloat
        if dauVao.size.height > dauVao.size.width {
            caoF = CGFloat(toiDa)
            rongF = floor(caoF * dauVao.size.width / dauVao.size.height)
        } else {
            rongF = CGFloat(toiDa)
            caoF = floor(rongF * dauVao.size.height / dauVao.size.width)
        }
        let rect = CGRect(x: 0, y: 0, width: rongF, height: caoF)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        dauVao.draw(in: rect)
        let ketQua = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return ketQua
    }

    /// Lưu ảnh sách
    private func luuAnhSach(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let anhGoc = args["goc"] as? String,
              let anhSach = args["dich"] as? String,
              let gioiHan = args["gioi_han"] as? Int,
              let anhThuNho = args["thunho"] as? String,
              let chieuCao = args["cao"] as? Int,
              let chatLuong = args["chat_luong"] as? Int
        else {
            result(FlutterError(code: "luuAnhSach_1", message: "Tham số không đúng", details: call.method))
            return
        }
        // Nạp ảnh gốc
        guard let imgGoc = UIImage(contentsOfFile: anhGoc) else {
            result(FlutterError(code: "luuAnhSach_2", message: "Không nạp được ảnh gốc", details: anhGoc))
            return
        }
        let chatLuongAnh = CGFloat(chatLuong) / 100.0
        var anhLuu = imgGoc;
        let gioiHanF = CGFloat(gioiHan)
        if (anhLuu.size.height > gioiHanF || anhLuu.size.width > gioiHanF) {
            anhLuu = coDanAnh(dauVao: imgGoc, toiDa: gioiHan) ?? imgGoc
        }
        // Tạo JPEG
        guard let jpeg = anhLuu.jpegData(compressionQuality: chatLuongAnh) else {
            result(FlutterError(code: "luuAnhSach_3", message: "Không tạo được JPEG data", details: anhGoc))
            return
        }
        do {
            try jpeg.write(to: URL(fileURLWithPath: anhSach))
        } catch let error {
            result(FlutterError(code: "luuAnhSach_4", message: "Không ghi được tệp ảnh", details: error.localizedDescription))
        }
        // Tạo ảnh thu nhỏ
        guard let hinh = coDanAnh(dauVao: imgGoc, toiDa: chieuCao) else {
            result(FlutterError(code: "luuAnhSach_5", message: "Không vẽ được ảnh thu nhỏ", details: anhThuNho))
            return
        }
        // Lưu JPEG thu nhỏ
        guard let jpegTn = hinh.jpegData(compressionQuality: chatLuongAnh) else {
            result(FlutterError(code: "luuAnhSach_6", message: "Không tạo được JPEG data ảnh nhỏ", details: anhThuNho))
            return
        }
        do {
            try jpegTn.write(to: URL(fileURLWithPath: anhThuNho))
        } catch let error {
            result(FlutterError(code: "luuAnhSach_7", message: "Không ghi được tệp ảnh thu nhỏ", details: error.localizedDescription))
            return
        }
        result(true)
    }

    /// Chọn ảnh
    private func chonAnh(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as?  [String: Any],
              let duongDan = args["duong_dan"] as? String,
              let kieuTho = args["kieu"] as? Int,
              let kieu = KieuMedia(rawValue: kieuTho)
        else {
            result(FlutterError(code: "chonAnh_1", message: "Tham số không đúng", details: call.method))
            return
        }
        let boXl = BoXuLyChonAnh(nguon: kieu, duongDan: duongDan, xlKetQua: result)
        boXl.batDau()
    }

    /// Từ AppDelegate
    func nhanDuocTep(dsDuongDan: [String]) {
        kenhKetNoi.invokeMethod(TenHamDenFlutter.nhanDuocTep.rawValue, arguments: dsDuongDan)
    }

    /// Dán
    private func dan(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let thamSo = call.arguments as? [String: Any],
           let duongDanChua = thamSo["duong_dan"] as? String,
           let locTho = thamSo["loc"] as? [Int] {
            var loc = [KieuTep]()
            for muc in locTho {
                if let gt = KieuTep(rawValue: muc) {
                    loc.append(gt)
                }
            }
            BoXuLyDuLieuTrungGian.duyNhat.dan(duongDanLuu: duongDanChua, loc: loc) { dsDuongDan in
                result(dsDuongDan)
            }
        } else {
            result(FlutterError(code: "dan_1", message: "Tham số không phù hợp", details: call.method))
        }
    }

    /// Chữa cháy: giảm kích thước ảnh
    private func chuanHoaAnh(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let thuMucChua = args["duong_dan"] as? String,
              let gioiHan = args["gioi_han"] as? Int,
              let chatLuong = args["chat_luong"] as? Int
        else {
            result(FlutterError(code: "chuanHoaAnh_1", message: "Tham số không đúng", details: call.method))
            return
        }
        if (chuanHoaAnh == nil) {
            chuanHoaAnh = ChuanHoaAnh(thuMuc: thuMucChua, gioiHan: gioiHan, nen: chatLuong)
            chuanHoaAnh?.batDau()
        }
        result(nil)
    }

    /// Từ ChuanHoaAnh
    func capNhatChuanHoaAnh(hienTai: Int, tongSo: Int) {
        var thamSo: [String: Int] = [:]
        if hienTai == tongSo {
            chuanHoaAnh = nil
        } else {
            thamSo["stt"] = hienTai
            thamSo["tong"] = tongSo
        }
        kenhKetNoi.invokeMethod(TenHamDenFlutter.chuanHoaAnh.rawValue, arguments: thamSo)
    }

    /// Tìm kiếm ảnh bằng GG Images thông qua Safari
    private func timKiemAnh(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let thuMucChua = args["duong_dan"] as? String,
              let tuKhoa = args["tu_khoa"] as? String
        else {
            result(FlutterError(code: "timKiemAnh_1", message: "Tham số không đúng", details: call.method))
            return
        }
        BoXuLyDuLieuTrungGian.duyNhat.xoaBoDuLieuTrungGianChoAnhVaUrl()
        if (!boTimKiemAnh.batDau(
            tuKhoa: tuKhoa,
            xong: { // Khi đóng SFSafari mà ko có kết quả
                result(nil)
            }, dan: {[weak self] in // Khi có kết quả dán
//                ConsoleLog.shared.log("Khi dan")
                BoXuLyDuLieuTrungGian.duyNhat.danAnh(duongDanLuu: thuMucChua) {[weak self] ketQua in
                    guard let mmSelf = self, !ketQua.isEmpty else { return }
                    // Đóng SFSafari và trả lại kết quả nếu dán thành công (không dán được ảnh nào thì vẫn tiếp tục mở SFSafari)
                    mmSelf.boTimKiemAnh.ketThuc()
                    result(ketQua)
//                    ConsoleLog.shared.log("KQ dan \(ketQua)")
                }
            })) { // Khi không bật được SFSafari
            result(nil)
        }
    }

}
