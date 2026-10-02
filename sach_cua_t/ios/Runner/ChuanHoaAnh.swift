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

/// Chuẩn hoá ảnh (xử lý kích thước và chất lượng tất cả các ảnh trong thư mục chỉ định)
final class ChuanHoaAnh {

    let kichThuoc: Int
    let kichThuocTn: Int
    let chatLuong: CGFloat
    let chatLuongTn: CGFloat
    let chiTaoLaiTn: Bool
    private let luongThucThi = OperationQueue()
    private let luongThongBao = OperationQueue()
    private var daHoanThanh = 0

    init(gioiHan: Int, gioiHanTn: Int, nen: Int, nenTn: Int, chiTn: Bool) {
        kichThuoc = gioiHan
        kichThuocTn = gioiHanTn
        chatLuong = CGFloat(nen) / 100.0
        chatLuongTn = CGFloat(nenTn) / 100.0
        chiTaoLaiTn = chiTn
        luongThongBao.maxConcurrentOperationCount = 1
        luongThucThi.maxConcurrentOperationCount = 1
    }

    /// Thực hiện việc chuẩn hoá
    private func chuanHoa(_ mucTieu: URL) {
        let laAnhTn = mucTieu.path.hasSuffix("_tn.jpg")
        if laAnhTn {
            return
        }
        guard let anh = UIImage(contentsOfFile: mucTieu.path) else { return }
        if !chiTaoLaiTn { // Nén lại ảnh chính
            var anhChuan = anh
            let ktF = CGFloat(kichThuoc)
            if anh.size.width > ktF || anh.size.height > ktF {
                anhChuan = HeThongMay.duyNhat.coDanAnh(dauVao: anh, toiDa: kichThuoc) ?? anh
            }
            guard let jpeg = anhChuan.jpegData(compressionQuality: chatLuong) else { return }
            try? jpeg.write(to: mucTieu)
        }
        // Tạo lại ảnh thu nhỏ
        var urlTn = mucTieu.deletingPathExtension()
        let tenTn = urlTn.lastPathComponent
        urlTn = urlTn.deletingLastPathComponent().appendingPathComponent("\(tenTn)_tn.jpg")
        var anhTn = anh
        let ktFtn = CGFloat(kichThuocTn)
        if anh.size.width > ktFtn || anh.size.height > ktFtn {
            anhTn = HeThongMay.duyNhat.coDanAnh(dauVao: anh, toiDa: kichThuocTn) ?? anh
        }
        guard let jpeg = anhTn.jpegData(compressionQuality: chatLuongTn) else { return }
        try? jpeg.write(to: urlTn)
    }

    /// Bắt đầu
    func batDau() {
        let fileMan = FileManager.default
        let dsTep = (try? fileMan.contentsOfDirectory(at: BoQuanLyThuMuc.duyNhat.thuMucAnhSach, includingPropertiesForKeys: nil)) ?? []
        let tong = dsTep.count
        if tong == 0 {
            HeThongMay.duyNhat.capNhatChuanHoaAnh(hienTai: 0, tongSo: 0)
            return
        }
        HeThongMay.duyNhat.capNhatChuanHoaAnh(hienTai: 0, tongSo: tong)
        daHoanThanh = 0
        for muc in dsTep {
            luongThucThi.addOperation {[weak self] in
                self?.chuanHoa(muc)
                self?.luongThongBao.addOperation {
                    DispatchQueue.main.async {[weak self] in
                        guard let mSelf = self else { return }
                        mSelf.daHoanThanh += 1
                        HeThongMay.duyNhat.capNhatChuanHoaAnh(hienTai: mSelf.daHoanThanh, tongSo: tong)
                    }
                }
            }
        }
    }

}
