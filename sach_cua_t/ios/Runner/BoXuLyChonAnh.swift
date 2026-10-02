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

import UIKit
import Flutter

/// Xử lý UIImagePickerController (lưu lại ảnh được chọn/chụp thành ảnh JPEG không nén vào thư mục được chỉ định)
final class BoXuLyChonAnh: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let phanHoi: FlutterResult
    let kieu: HeThongMay.KieuMedia
    private var neo: BoXuLyChonAnh?

    init(nguon: HeThongMay.KieuMedia, xlKetQua: @escaping FlutterResult) {
        kieu = nguon
        phanHoi = xlKetQua
    }

    func batDau() {
        let nguon: UIImagePickerController.SourceType
        switch kieu {
        case .camera:
            nguon = .camera
        case .khoAnh:
            nguon = .photoLibrary
        }
        guard UIImagePickerController.isSourceTypeAvailable(nguon) else {
            phanHoi(FlutterError(code: "chonAnh_2", message: "Kiểu media không hiện có", details: kieu.rawValue))
            return
        }
        let maKieuAnh = "public.image"
        guard UIImagePickerController.availableMediaTypes(for: nguon)?.contains(maKieuAnh) ?? false else {
            phanHoi(FlutterError(code: "chonAnh_3", message: "Kiểu media không hiện có", details: maKieuAnh))
            return
        }
        guard let rootController = AppDelegate.app.rootViewController else { return }
        neo = self
        let controller = UIImagePickerController()
        controller.modalPresentationStyle = .fullScreen
        controller.sourceType = nguon
        controller.mediaTypes = [maKieuAnh]
        controller.delegate = self
        rootController.present(controller, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        phanHoi(nil)
        neo = nil
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var ketQua: String?
        let fileMan = FileManager.default
        if let urlGoc = info[.imageURL] as? URL {
            BoQuanLyThuMuc.duyNhat.donSachThuMuc(BoQuanLyThuMuc.duyNhat.thuMucMayAnh)
            let tenAnh = urlGoc.lastPathComponent
            let urlDich = BoQuanLyThuMuc.duyNhat.thuMucMayAnh.appendingPathComponent(tenAnh)
//            ketQua = "\(urlGoc) => \(urlDich)"
            do {
                try fileMan.copyItem(at: urlGoc, to: urlDich)
            } catch let err {
                picker.dismiss(animated: true)
                phanHoi(err)
                neo = nil
                return
            }
            if fileMan.fileExists(atPath: urlDich.path) {
                ketQua = urlDich.path
            }
        } else if let anhGoc = info[.originalImage] as? UIImage, let duLieu = anhGoc.jpegData(compressionQuality: 1) {
            BoQuanLyThuMuc.duyNhat.donSachThuMuc(BoQuanLyThuMuc.duyNhat.thuMucMayAnh)
            let urlDich = BoQuanLyThuMuc.duyNhat.thuMucMayAnh.appendingPathComponent("anh_chup.JPG")
            do {
                try duLieu.write(to: urlDich)
            } catch let err {
                picker.dismiss(animated: true)
                phanHoi(err)
                neo = nil
                return
            }
            if fileMan.fileExists(atPath: urlDich.path) {
                ketQua = urlDich.path
            }
        }
        picker.dismiss(animated: true)
        phanHoi(ketQua)
        neo = nil
    }

}
