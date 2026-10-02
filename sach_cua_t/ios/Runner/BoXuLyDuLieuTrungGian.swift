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
import UIKit

/// Xử lý UIPasteboard.general (lưu dữ liệu từ Pasteboard vào thư mục được chỉ định)
/// TODO: hiện tại chỉ xử lý ảnh (lưu vào thư mục chỉ định là JPEG hoặc PNG tuỳ vào ảnh có kênh Alpha hay không).
/// Với URL, lấy nội dung về và nếu là ảnh thì xử lý như trên.
/// Dự tính: xử lý zip/7z để khôi phục dữ liệu.
final class BoXuLyDuLieuTrungGian {

    static let duyNhat = BoXuLyDuLieuTrungGian()

    /// Mã định danh kiểu tệp trong UIPasteboard
    private enum Uti: String {
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

    var boDuLieuTrungGian: UIPasteboard { UIPasteboard.general }
    private let luongNapAnh = OperationQueue()

    private init() {
        luongNapAnh.maxConcurrentOperationCount = 1
    }

    func xoaBoDuLieuTrungGianChoAnhVaUrl() {
        boDuLieuTrungGian.image = nil
        boDuLieuTrungGian.images = nil
        boDuLieuTrungGian.url = nil
        boDuLieuTrungGian.urls = nil
    }

    /// Nạp ảnh từ URL
    private func napAnhTuUrl(url: URL, xong: @escaping (UIImage?) -> Void) {
        luongNapAnh.addOperation {
            if let duLieu = try? Data(contentsOf: url), let image = UIImage(data: duLieu) {
                DispatchQueue.main.async {
                    xong(image)
                }
            } else {
                DispatchQueue.main.async {
                    xong(nil)
                }
            }
        }
    }

    /// Ảnh có kênh Alpha (màu trong suốt) hay không
    ///  -> nếu có thì định dạng lưu trữ là PNG
    private func anhCoAlpha(anh: UIImage) -> Bool {
        guard let thongTin = anh.cgImage?.alphaInfo else { return false }
        switch thongTin {
        case .none, .noneSkipLast, .noneSkipFirst:
            return false
        default:
            return true
        }
    }

    /// Tiến hành lưu dữ liệu (tệp được chỉ định trong hàm)
    private func danDuLieu(duLieu: Data, tenGoc: String?, uti: Uti) -> URL? {
        let qlThuMuc = BoQuanLyThuMuc.duyNhat
        do {
            let dich = qlThuMuc.taoTen(thuMuc: qlThuMuc.thuMucDan, tenGoc: tenGoc, ext: uti.fileExtension)
            try duLieu.write(to: dich)
            return dich
        } catch _ {
            return nil
        }
    }

    /// Dán đối tượng ảnh
    private func danDoiTuongAnh(_ doiTuong: UIImage) -> URL? {
        let duLieuAnh: Data?
        let uti: Uti
        if anhCoAlpha(anh: doiTuong) {
            duLieuAnh = doiTuong.pngData()
            uti = .png
        } else {
            duLieuAnh = doiTuong.jpegData(compressionQuality: 1)
            uti = .jpeg
        }
        if let duLieu = duLieuAnh, let kq = danDuLieu(duLieu: duLieu, tenGoc: nil, uti: uti) {
            return kq
        }
        return nil
    }

    /// Dán ảnh (lấy dữ liệu ảnh hoặc URL từ pasteboard)
    func danAnh(_ khiXong: @escaping ([String]) -> Void) {
//        ConsoleLog.shared.log("Paste URLs: \(pasteboard.hasURLs); \(pasteboard.urls)")
        let qlThuMuc = BoQuanLyThuMuc.duyNhat
        if boDuLieuTrungGian.hasImages, let images = boDuLieuTrungGian.images, !images.isEmpty {
            qlThuMuc.donSachThuMuc(qlThuMuc.thuMucDan)
            var ketQua = [String]()
            for image in images {
                if let kq = danDoiTuongAnh(image) {
                    ketQua.append(kq.path)
                }
            }
            boDuLieuTrungGian.images = nil
            boDuLieuTrungGian.image = nil
            khiXong(ketQua)
        } else if boDuLieuTrungGian.hasURLs, let url = boDuLieuTrungGian.url {
            napAnhTuUrl(url: url) {[weak self] image in
                guard let mSelf = self else { return }
                if let img = image, let kq = mSelf.danDoiTuongAnh(img) {
                    khiXong([kq.path])
                } else {
                    khiXong([])
                }
            }
            boDuLieuTrungGian.url = nil
            boDuLieuTrungGian.urls = nil
        } else {
            khiXong([])
        }
    }

    /// Dán các loại khác -> tạm thời chưa sử dụng
    private func danKhac(_ utis: [Uti]) -> [String] {
        if !boDuLieuTrungGian.contains(pasteboardTypes: utis.map({ $0.rawValue })) {
//            ConsoleLog.shared.log("Pasteboard does not contain types: \(utis.map({ $0.rawValue }))")
            return []
        }
        var ketQua = [String]()
        for uti in utis {
//            ConsoleLog.shared.log("Check pasteboard for type \(uti.rawValue)")
            if let dsChiSo = boDuLieuTrungGian.itemSet(withPasteboardTypes: [uti.rawValue]),
               let dsDuLieu = boDuLieuTrungGian.data(forPasteboardType: uti.rawValue, inItemSet: dsChiSo) {
                var dsTenTep = [String?]()
                for chiSo in dsChiSo {
                    var tenTep: String? = nil
                    if let dsSieuDuLieu = boDuLieuTrungGian.data(forPasteboardType: Uti.meta.rawValue, inItemSet: IndexSet(integer: chiSo)),
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
//                ConsoleLog.shared.log("Pasteboard data list: \(dsDuLieu.count) \(dsTenTep)")
                if !dsDuLieu.isEmpty {
                    let qlThuMuc = BoQuanLyThuMuc.duyNhat
                    qlThuMuc.donSachThuMuc(qlThuMuc.thuMucDan)
                }
                for (stt, muc) in dsDuLieu.enumerated() {
                    if let ten = danDuLieu(duLieu: muc, tenGoc: dsTenTep[stt], uti: uti) {
                        ketQua.append(ten.path)
                    }
                }
            }
        }
        if !ketQua.isEmpty {
            boDuLieuTrungGian.items = []
        }
        return ketQua
    }

    /// Bắt đầu dán
    func dan(loc: [HeThongMay.KieuTep], khiXong: @escaping ([String]) -> Void) {
//        ketQua.append("\(duongDanLuu); \(loc.map({ "\($0) \($0.rawValue)" }).joined(separator: ";; "))")
        var utis = [Uti]()
        var coAnh = false
        for kieu in loc {
            switch kieu {
            case .zip:
                utis.append(.zip)
            case .p7zip:
                utis.append(.p7z)
            case .anh:
                coAnh = true
            }
        }
        if coAnh {
            danAnh(khiXong)
            return
        }
        if !utis.isEmpty {
            let ketQua = danKhac(utis)
            khiXong(ketQua)
        }
    }

}
