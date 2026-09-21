//
//  ChuanHoaAnh.swift
//  Runner
//
//  Created by soleilpqd on 21/09/2026.
//

import Foundation
import UIKit

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
