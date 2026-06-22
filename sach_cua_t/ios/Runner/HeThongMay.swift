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
        /// Dán tệp từ pasteboard
        case dan
        /// Mở màn hình chọn tệp
        case chonTep
    }

    /// Tên hàm từ native module tới Flutter module
    enum TenHamDenFlutter: String {
        /// Kiểm tra ISBN
        case kiemTraISBN
        /// Nhận được tệp
        case nhanDuocTep
    }

    enum KieuTep: Int {
        case anh = 0
        case zip
        case p7zip
    }

    enum Uti: String {
        case meta = "com.apple.DocumentManager.FPItem.File"
        case jpeg = "public.jpeg"
        case png = "public.png"
        case zip = "public.zip-archive"
        case p7z = "org.7-zip.7-zip-archive"

        var fileExtension: String {
            switch self {
            case .meta:
                return "bin"
            case .jpeg:
                return "jpg"
            case .png:
                return "png"
            case .zip:
                return "zip"
            case .p7z:
                return "7z"
            }
        }
    }

    /// Duy nhất (Singleton)
    static var duyNhat: HeThongMay!

    /// Kênh kết nối
    private let kenhKetNoi: FlutterMethodChannel

//    private let kbToolbarView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))

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
//        nhungKeyboardToolbar()
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnResize), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

//    private func timView(viewCha: UIView, dieuKien: String) -> UIView? {
//        for muc in viewCha.subviews {
//            if muc.description.hasPrefix(dieuKien) {
//                return muc
//            }
//        }
//        return nil
//    }

//    private func nhungKeyboardToolbar() {
//        kbToolbarView.isHidden = true
//        kbToolbarView.backgroundColor = .red
//        var viewChua: UIView?
//        for win in UIApplication.shared.windows {
//            if let muc = timView(viewCha: win, dieuKien: "<UIInputSetContainerView:") {
//                viewChua = muc
//                break
//            }
//        }
//        guard let vChua = viewChua, let viewKB = timView(viewCha: vChua, dieuKien: "<UIInputSetHostView: ")
//        else { return }
//        kbToolbarView.translatesAutoresizingMaskIntoConstraints = false
//        kbToolbarView.removeFromSuperview()
//        vChua.addSubview(kbToolbarView)
//        var constraint = NSLayoutConstraint(item: kbToolbarView, attribute: .leading, relatedBy: .equal, toItem: vChua, attribute: .leading, multiplier: 1.0, constant: 0)
//        vChua.addConstraint(constraint)
//        constraint = NSLayoutConstraint(item: kbToolbarView, attribute: .trailing, relatedBy: .equal, toItem: vChua, attribute: .trailing, multiplier: 1.0, constant: 0)
//        vChua.addConstraint(constraint)
//        constraint = NSLayoutConstraint(item: kbToolbarView, attribute: .bottom, relatedBy: .equal, toItem: viewKB, attribute: .top, multiplier: 1.0, constant: 0)
//        vChua.addConstraint(constraint)
//        constraint = NSLayoutConstraint(item: kbToolbarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50)
//        vChua.addConstraint(constraint)
//        if kbToolbarView.subviews.isEmpty {
//            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
//            label.text = "TEST"
//            kbToolbarView.addSubview(label)
//        }
//    }

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
        case .dan:
            if let thamSo = call.arguments as? [String: Any],
               let duongDanChua = thamSo["duong_dan"] as? String,
               let locTho = thamSo["loc"] as? [Int] {
                var loc = [KieuTep]()
                for muc in locTho {
                    if let gt = KieuTep(rawValue: muc) {
                        loc.append(gt)
                    }
                }
                let dsDuongDan = dan(duongDanLuu: duongDanChua, loc: loc)
                result(dsDuongDan)
            } else {
                result(FlutterError(code: "dan_1", message: "Tham số không phù hợp", details: call.method))
            }
        case .chonTep:
            break
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

    /// Lưu ảnh sách
    private func luuAnhSach(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let anhGoc = args["goc"] as? String,
              let anhSach = args["dich"] as? String,
              let anhThuNho = args["thunho"] as? String,
              let chieuCao = args["cao"] as? Int
        else {
            result(FlutterError(code: "luuAnhSach_1", message: "Tham số không đúng", details: call.method))
            return
        }
        // Nạp ảnh gốc
        guard let image = UIImage(contentsOfFile: anhGoc) else {
            result(FlutterError(code: "luuAnhSach_2", message: "Không nạp được ảnh gốc", details: anhGoc))
            return
        }
        // Tạo JPEG
        guard let jpeg = image.jpegData(compressionQuality: 1) else {
            result(FlutterError(code: "luuAnhSach_3", message: "Không tạo được JPEG data", details: anhGoc))
            return
        }
        do {
            try jpeg.write(to: URL(fileURLWithPath: anhSach))
        } catch let error {
            result(FlutterError(code: "luuAnhSach_4", message: "Không ghi được tệp ảnh", details: error.localizedDescription))
        }
        // Tạo ảnh thu nhỏ
        let caoF = CGFloat(chieuCao)
        let rongF = floor(caoF * image.size.width / image.size.height)
        let rect = CGRect(x: 0, y: 0, width: rongF, height: caoF)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        image.draw(in: rect)
        let hinhTn = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        guard let hinh = hinhTn else {
            result(FlutterError(code: "luuAnhSach_5", message: "Không vẽ được ảnh thu nhỏ", details: anhThuNho))
            return
        }
        // Lưu JPEG thu nhỏ
        guard let jpegTn = hinh.jpegData(compressionQuality: 1) else {
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

//    @IBAction private func keyboardOnAppear(_ notif: Notification) {
////        nhungKeyboardToolbar()
////        kbToolbarView.isHidden = false
//    }
//
//    @IBAction private func keyboardOnResize(_ notif: Notification) {
//
//    }
//
//    @IBAction private func keyboardOnDisappear(_ notif: Notification) {
////        kbToolbarView.isHidden = true
//    }

    func nhanDuocTep(dsDuongDan: [String]) {
        kenhKetNoi.invokeMethod(TenHamDenFlutter.nhanDuocTep.rawValue, arguments: dsDuongDan)
    }

    private func taoTen(thuMuc: String, tenGoc: String?, uti: Uti) -> String {
        let urlCoSo = URL(fileURLWithPath: thuMuc)
        var tenCoSo = ""
        let ext = uti.fileExtension
        if let ten = tenGoc {
            let url = urlCoSo.appendingPathComponent(ten)
            if !FileManager.default.fileExists(atPath: url.path) {
                return url.path
            }
            tenCoSo = url.deletingPathExtension().lastPathComponent
        }

        var stt = 1;
        while true {
            let url = urlCoSo.appendingPathComponent("\(tenCoSo)_\(stt).\(ext)")
            if !FileManager.default.fileExists(atPath: url.path) {
                return url.path
            }
            stt += 1
        }
    }

    private func anhCoAlpha(anh: UIImage) -> Bool {
        guard let thongTin = anh.cgImage?.alphaInfo else { return false }
        switch thongTin {
        case .none, .noneSkipLast, .noneSkipFirst:
            return false
        default:
            return true
        }
    }

    private func danDuLieu(duLieu: Data, duongDanLuu: String, tenGoc: String?, uti: Uti) -> String? {
        do {
            let ten = taoTen(thuMuc: duongDanLuu, tenGoc: tenGoc, uti: uti)
            try duLieu.write(to: URL(fileURLWithPath: ten))
            return ten
        } catch _ {
            return nil
        }
    }

    private func dan(duongDanLuu: String, loc: [KieuTep]) -> [String] {
//        ketQua.append("\(duongDanLuu); \(loc.map({ "\($0) \($0.rawValue)" }).joined(separator: ";; "))")
        let pasteboard = UIPasteboard.general
        var utis = [Uti]()
        for kieu in loc {
            switch kieu {
            case .anh:
                utis.append(.jpeg)
                utis.append(.png)
            case .zip:
                utis.append(.zip)
            case .p7zip:
                utis.append(.p7z)
            }
        }
        if !pasteboard.contains(pasteboardTypes: utis.map({ $0.rawValue })) {
            return []
        }
        var ketQua = [String]()
        for uti in utis {
            if let dsChiSo = pasteboard.itemSet(withPasteboardTypes: [uti.rawValue]),
               let dsDuLieu = pasteboard.data(forPasteboardType: uti.rawValue, inItemSet: dsChiSo) {
                var dsTenTep = [String?]()
                for chiSo in dsChiSo {
                    var tenTep: String? = nil
                    if let dsSieuDuLieu = pasteboard.data(forPasteboardType: Uti.meta.rawValue, inItemSet: IndexSet(integer: chiSo)),
                       !dsSieuDuLieu.isEmpty {
                        for sieuDl in dsSieuDuLieu {
                            if let plist = try? PropertyListSerialization.propertyList(from: sieuDl, format: nil) as? NSDictionary,
                               let objects = plist["$objects"] as? NSArray {
                                let stt = objects.index(of: "NSFileProviderDomainDefaultIdentifier")
                                if stt >= 0 && stt < objects.count - 1 {
                                    tenTep = objects[stt + 1] as? String
                                }
                            }
                            if tenTep != nil {
                                break
                            }
                        }
                    }
                    dsTenTep.append(tenTep)
                }
                for (stt, muc) in dsDuLieu.enumerated() {
                    if let ten = danDuLieu(duLieu: muc, duongDanLuu: duongDanLuu, tenGoc: dsTenTep[stt], uti: uti) {
                        ketQua.append(ten)
                    }
                }
            }
        }
        if !ketQua.isEmpty {
            pasteboard.items = []
        }
        return ketQua
    }

}
