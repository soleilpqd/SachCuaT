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

final class HeThongMay {

    enum TenHamTuFlutter: String {
        case quetMaISBN
    }

    enum TenHamDenFlutter: String {
        case kiemTraISBN
    }

    static var duyNhat: HeThongMay!

    private let kenhKetNoi: FlutterMethodChannel

    public static func register(with rootController: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "sach.cua.T", binaryMessenger: rootController.binaryMessenger)
        let instance = HeThongMay(kenh: channel)
        duyNhat = instance
    }

    init(kenh: FlutterMethodChannel) {
        kenhKetNoi = kenh
        kenhKetNoi.setMethodCallHandler { call, result in
            HeThongMay.duyNhat.xuLyHam(call: call, result: result)
        }
    }

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
                AppDelegate.app.rootViewController.present(manHinh, animated: true)
            }
        }
    }

    func kiemTraISBN(giaTri: String, nhanKetQua: @escaping (Bool) -> Void) {
        kenhKetNoi.invokeMethod(TenHamDenFlutter.kiemTraISBN.rawValue, arguments: giaTri) { value in
            if let val = value as? Bool {
                nhanKetQua(val)
            }
        }
    }

}
