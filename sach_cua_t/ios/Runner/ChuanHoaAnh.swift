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

    let duongDan: String
    let kichThuoc: Int
    let chatLuong: CGFloat
    private let luongThucThi = OperationQueue()
    private let luongThongBao = OperationQueue()
    private var daHoanThanh = 0

    init(thuMuc: String, gioiHan: Int, nen: Int) {
        duongDan = thuMuc
        kichThuoc = gioiHan
        chatLuong = CGFloat(nen) / 100.0
        luongThongBao.maxConcurrentOperationCount = 1
        luongThucThi.maxConcurrentOperationCount = 1
    }

    /// Thực hiện việc chuẩn hoá
    private func chuanHoa(_ mucTieu: String) {
        let url = URL(fileURLWithPath: duongDan).appendingPathComponent(mucTieu)
        guard let anh = UIImage(contentsOfFile: url.path) else { return }
        var anhChuan = anh
        let ktF = CGFloat(kichThuoc)
        if anh.size.width > ktF || anh.size.height > ktF {
            anhChuan = HeThongMay.duyNhat.coDanAnh(dauVao: anh, toiDa: kichThuoc) ?? anh
        }
        guard let jpeg = anhChuan.jpegData(compressionQuality: chatLuong) else { return }
        try? jpeg.write(to: url)
    }

    /// Bắt đầu
    func batDau() {
        let fileMan = FileManager.default
        let dsTep = (try? fileMan.contentsOfDirectory(atPath: duongDan)) ?? []
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
