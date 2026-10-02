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
import SafariServices

struct ThongTinWebsite: Decodable {
    let url: String
    let thamSo: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case url
        case thamSo = "tham_so"
    }

    func xayDungURL(_ tuKhoa: String) -> URL? {
        let choCanDien = "%TK%"
        var urlGoc = url
        if urlGoc.contains(choCanDien) {
            urlGoc = urlGoc.replacingOccurrences(
                of: choCanDien,
                with: (tuKhoa as NSString).addingPercentEncoding(withAllowedCharacters: CharacterSet()) ?? ""
            )
        }
        guard var xayUrl = URLComponents(string: urlGoc) else { return nil }
        var thamSoUrl = [URLQueryItem]()
        for (ten, giaTri) in thamSo ?? [:] {
            var gt = giaTri
            if gt.contains(choCanDien) {
                gt = gt.replacingOccurrences(
                    of: choCanDien,
                    with: tuKhoa
                )
            }
            thamSoUrl.append(URLQueryItem(name: ten, value: gt))
        }
        xayUrl.queryItems = thamSoUrl
        return xayUrl.url
    }
}

/// Xử lý màn hình SFSafariViewController tại GG Search Images.
/// Sử dụng timer để tự động phát hiện khi người dùng sao chép ảnh/url ảnh từ trên trang web.
/// Sau đó tiến hành dán (bằng BoXuLyDuLieuTrungGian).
/*
 batDau -> người dùng sao chép -> tiến hành dán (`khiDan`):
   - Dán thành công: -> ketThuc -> donDep
   - Dán thất bại: không làm gì (giữ nguyên màn hình)
 */
final class BoXuLyTimKiemAnh: NSObject {

    private var khiXong: (() -> Void)?
    /// Return `true` khi dán thành công
    private var khiDan: ((@escaping (Bool) -> Void) -> Void)?
    private weak var safari: SFSafariViewController?
    private var timer: Timer?
    private var tuKhoa = ""
    private weak var mienHienTai: BoChuyenDoiTrangWeb?
    private var dsChuyenDoiWebsites = [BoChuyenDoiTrangWeb]()

    @discardableResult
    private func napDsChuyenDoiWebsites(_ duongDan: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: duongDan.path),
              let jsonData = try? Data(contentsOf: duongDan),
              let thongTin = try? JSONDecoder().decode([ThongTinWebsite].self, from: jsonData)
        else {
            return false
        }
        for muc in thongTin {
            let boChuyenDoi = BoChuyenDoiTrangWeb(thongTin: muc)
            boChuyenDoi.boTimKiem = self
            dsChuyenDoiWebsites.append(boChuyenDoi)
        }
        return dsChuyenDoiWebsites.count > 1
    }

    override init() {
        super.init()
        dsChuyenDoiWebsites.append(BoChuyenDoiTrangWeb(thongTin: nil)) // Đánh dấu URL sách
        dsChuyenDoiWebsites.first?.boTimKiem = self
    }

    private func napDsWebsitesTimAnh() {
        guard dsChuyenDoiWebsites.count <= 1 else { return }

        // Đọc từ Flutter assets
        let tenTepDlWebsites = "websites.json"
        let duongDanDoc = BoQuanLyThuMuc.duyNhat.thuMucCSDL.appendingPathComponent(tenTepDlWebsites)
        napDsChuyenDoiWebsites(duongDanDoc)

        if dsChuyenDoiWebsites.count <= 1,
           //           let flutterBundleUrl = Bundle.main.url(
           //            forResource: "App",
            //            withExtension: "framework",
            //            subdirectory: "Frameworks"
            //           ),
            //           let flutterBundle = Bundle(url: flutterBundleUrl),
            //           let websitesJsonUrl = flutterBundle.url(
            //            forResource: tenTepDlWebsites,
            //            withExtension: duoiTepDLWebsites,
            //            subdirectory: "flutter_assets/assets"
            //           ) {
           let duongDanFlutter = AppDelegate.app.rootViewController?.lookupKey(forAsset: "assets/\(tenTepDlWebsites)"),
           let websitesJsonUrl = Bundle.main.url(forResource: duongDanFlutter, withExtension: nil) {
            napDsChuyenDoiWebsites(websitesJsonUrl)
        }
    }

    /// Bắt đầu
    func batDau(tuKhoa: String, xong: @escaping () -> Void, dan: @escaping (@escaping (Bool) -> Void) -> Void) -> Bool {
        khiXong = xong
        khiDan = dan
        self.tuKhoa = tuKhoa
        napDsWebsitesTimAnh()
        if dsChuyenDoiWebsites.count > 1, khoiDongSafari(dsChuyenDoiWebsites[1].cauHinh!) {
            mienHienTai = dsChuyenDoiWebsites[1]
            batDauTimerTuDongDan()
            return true
        }
        return false
    }

    private func batDauTimerTuDongDan() {
        BoXuLyDuLieuTrungGian.duyNhat.xoaBoDuLieuTrungGianChoAnhVaUrl()
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(khiKiemTraBoDuLieuTrungGianTuDong),
            userInfo: nil,
            repeats: true
        )
    }

    /// Dọn dẹp: xoá, kết thúc các đối tượng
    private func donDep() {
        khiXong = nil
        khiDan = nil
        timer?.invalidate()
        timer = nil
    }

    /// Kết thúc: bắt buộc đóng màn hình
    func ketThuc() {
        donDep()
        safari?.dismiss(animated: true)
    }

    /// Hàm timer
    @IBAction private func khiKiemTraBoDuLieuTrungGianTuDong() {
        if kiemTraDieuKienDan() {
            timer?.invalidate()
            timer = nil
            khiDan?({[weak self] (thanhCong) in
                if (!thanhCong) {
                    self?.batDauTimerTuDongDan()
                }
            })
        }
    }

    /// Kiểm tra bộ dữ liệu trung gian có dữ liệu hay không
    private func kiemTraDieuKienDan() -> Bool {
        let boDL = BoXuLyDuLieuTrungGian.duyNhat.boDuLieuTrungGian
        return boDL.hasURLs || boDL.hasImages
    }

    private func khoiDongSafari(_ thongTin: ThongTinWebsite) -> Bool {
        guard let url = thongTin.xayDungURL(tuKhoa), let rootController = AppDelegate.app.rootViewController
        else { return false }
        let hoatHinh = safari == nil
        safari?.dismiss(animated: hoatHinh)
        safari = nil
        let controller = SFSafariViewController(url: url)
        controller.delegate = self
        safari = controller
        rootController.present(controller, animated: hoatHinh)
        return true
    }

    fileprivate func khiChonActivity(_ sender: BoChuyenDoiTrangWeb) {
        if let thongTin = sender.cauHinh {
            mienHienTai = sender
            _ = khoiDongSafari(thongTin)
        } else if let url = sender.url {
            HeThongMay.duyNhat.danhDauUrlSach(url)
        }
        sender.activityDidFinish(true)
    }

}

extension BoXuLyTimKiemAnh: SFSafariViewControllerDelegate {

    /// Người dùng chủ động nhấn đóng màn hình
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if kiemTraDieuKienDan() {
            khiDan?({ _ in })
        } else {
            khiXong?()
        }
        donDep()
    }

    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        var ketQua = [BoChuyenDoiTrangWeb]()
        for muc in dsChuyenDoiWebsites where muc != mienHienTai {
            muc.url = URL
            ketQua.append(muc)
        }
        return ketQua
    }

}

class BoChuyenDoiTrangWeb: UIActivity {

    let cauHinh: ThongTinWebsite?
    weak var boTimKiem: BoXuLyTimKiemAnh?
    var url: URL?

    init(thongTin: ThongTinWebsite?) {
        cauHinh = thongTin
        super.init()
    }

    override var activityTitle: String? {
        if let thongTin = cauHinh {
            let choCanDien = "%TK%"
            var url = thongTin.url
            if url.contains(choCanDien) {
                url = url.replacingOccurrences(of: choCanDien, with: "index")
            }
            return URL(string: url)?.host ?? thongTin.url
        }
        return "📌 URL"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        if let quanLy = boTimKiem {
            quanLy.khiChonActivity(self)
        } else {
            activityDidFinish(true)
        }
    }

}
