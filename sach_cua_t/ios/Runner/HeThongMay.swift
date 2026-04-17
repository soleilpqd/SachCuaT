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
    }

    /// Tên hàm từ native module tới Flutter module
    enum TenHamDenFlutter: String {
        /// Kiểm tra ISBN
        case kiemTraISBN
    }

    /// Duy nhất (Singleton)
    static var duyNhat: HeThongMay!

    /// Kênh kết nối
    private let kenhKetNoi: FlutterMethodChannel

//    private let kbToolbarView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))

    public static func register(with rootController: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "sach.cua.T", binaryMessenger: rootController.binaryMessenger)
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
            if let manHinh = AppDelegate.app.rootViewController.storyboard?.instantiateViewController(withIdentifier: "ManHinhCamera") as? ManHinhCamera {
                manHinh.resultHandle = result
                manHinh.kieuQuet = .isbn
                manHinh.chuanBi {
                    AppDelegate.app.rootViewController.present(manHinh, animated: true)
                }
            }
        case .luuAnhSach:
            luuAnhSach(call: call, result: result)
        case .phienBan:
            let phienBan = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
            result(phienBan)
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

}
