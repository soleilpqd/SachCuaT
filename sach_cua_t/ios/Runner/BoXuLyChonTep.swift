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

import Foundation
import UniformTypeIdentifiers

/// Bộ xử lý chọn tệp (xử lý `UIDocumentPickerViewController`)
final class BoXuLyChonTep: NSObject {

    private var neo: BoXuLyChonTep?
    let phanHoi: FlutterResult
    let loc: [HeThongMay.KieuTep]

    init(kieu: [HeThongMay.KieuTep], traLoi: @escaping FlutterResult) {
        loc = kieu
        phanHoi = traLoi
        super.init()
    }

    func batDau() {
        guard let rootController = AppDelegate.app.rootViewController else { return }
        neo = self

        let docController: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            var types = [UTType]()
            for kieu in loc {
                switch kieu {
                case .anh:
                    types.append(.image)
                case .zip:
                    types.append(.zip)
                case .p7zip:
                    if let type = UTType("org.7-zip.7-zip-archive") {
                        types.append(type)
                    }
                }
            }
            docController = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        } else {
            var types = [String]()
            for kieu in loc {
                switch kieu {
                case .anh:
                    types.append("public.jpeg")
                    types.append("public.png")
                case .zip:
                    types.append("public.zip-archive")
                case .p7zip:
                    types.append("org.7-zip.7-zip-archive")
                }
            }
            docController = UIDocumentPickerViewController(documentTypes: types, in: .import)
        }
        docController.delegate = self
        docController.modalPresentationStyle = .popover
        rootController.present(docController, animated: true)
    }

    private func donDep() {
        neo = nil
    }

}

extension BoXuLyChonTep: UIDocumentPickerDelegate {

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        phanHoi(nil)
        donDep()
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let ketQua = BoQuanLyThuMuc.duyNhat.saoChep(nguon: urls, thuMucDich: BoQuanLyThuMuc.duyNhat.thuMucChiaSe)
        phanHoi(ketQua.map({ $0.path }))
        donDep()
    }

}
