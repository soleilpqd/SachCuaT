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
    private var mienHienTai = BoChuyenDoiTrangWeb.Web.ggImg

    /// Bắt đầu
    func batDau(tuKhoa: String, xong: @escaping () -> Void, dan: @escaping (@escaping (Bool) -> Void) -> Void) -> Bool {
        mienHienTai = .ggImg
        khiXong = xong
        khiDan = dan
        self.tuKhoa = tuKhoa
        if khoiDongSafari(.ggImg) {
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

    private func khoiDongSafari(_ kieu: BoChuyenDoiTrangWeb.Web) -> Bool {
        guard let url = kieu.xayDungUrl(tuKhoa), let rootController = AppDelegate.app.rootViewController
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
        if sender.web == .danhDau {
            HeThongMay.duyNhat.danhDauUrlSach(sender.url)
            return
        }
        mienHienTai = sender.web
        _ = khoiDongSafari(sender.web)
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
        let tatCa = BoChuyenDoiTrangWeb.Web.tatCa
        var ketQua = [BoChuyenDoiTrangWeb]()
        for muc in tatCa where muc != mienHienTai {
            let boChuyenDoi = BoChuyenDoiTrangWeb(mien: muc, link: URL)
            boChuyenDoi.boTimKiem = self
            ketQua.append(boChuyenDoi)
        }
        return ketQua
    }

}


class BoChuyenDoiTrangWeb: UIActivity {

    enum Web {
        case danhDau
        case ggImg
        case kimDong
        case nhaNam
        case tre
        case thaiHa
        case azvn
        case phuNu
        case sky
        case one980
        case taoDan
        case shopee
        case tiki
        case dongA
        case danTri
        case phucMinh
        case sbooks
        case dhsp
        case dinhTi
        case triViet
        case alpha
        case comicola
        case ipm
        case sanHo
        case linhLan

        static var tatCa: [Web] {[
            .danhDau,
            .ggImg,
            .kimDong,
            .nhaNam,
            .tre,
            .thaiHa,
            .azvn,
            .phuNu,
            .sky,
            .one980,
            .taoDan,
            .shopee,
            .tiki,
            .dongA,
            .danTri,
            .phucMinh,
            .sbooks,
            .dhsp,
            .dinhTi,
            .triViet,
            .alpha,
            .comicola,
            .ipm,
            .sanHo,
            .linhLan
        ]}

        var tieuDe: String {
            switch self {
            case .danhDau:
                return "📌 URL"
            default:
                return URL(string: duongDanGoc)?.host ?? "\(self)"
            }
        }

        var duongDanGoc: String {
            switch self {
            case .danhDau:
                return ""
            case .ggImg:
                return "https://www.google.com/search"
            case .kimDong:
                return "https://nxbkimdong.com.vn/search"
            case .nhaNam:
                return "https://nhanam.vn/search"
            case .tre:
                return "https://www.nxbtre.com.vn/tim-kiem"
            case .thaiHa:
                return "https://thaihabooks.com/search"
            case .azvn:
                return "https://azvietnam.vn/search"
            case .phuNu:
                return "https://sach.nxbphunu.com.vn/ket-qua-tim-kiem"
            case .sky:
                return "https://skybooks.vn/search"
            case .one980:
                return "https://1980books.com/search"
            case .taoDan:
                return "https://sachtaodan.vn/search"
            case .shopee:
                return "https://shopee.vn/search"
            case .tiki:
                return "https://tiki.vn/search"
            case .dongA:
                return "https://sachdonga.vn/search"
            case .danTri:
                return "https://nxbdantri.com.vn/"
            case .phucMinh:
                return "https://www.phucminhbooks.vn/search"
            case .sbooks:
                return "https://sbooks.vn/"
            case .dhsp:
                return "https://nxbdhsp.edu.vn/san-pham"
            case .dinhTi:
                return "https://dinhtibooks.com.vn/search/"
            case .triViet:
                return "https://www.trithucvietbook.com/search"
            case .alpha:
                return "https://www.alphabooks.vn/search"
            case .comicola:
                return "https://shop.comicola.com/"
            case .ipm:
                return "https://ipm.vn/search"
            case .sanHo:
                return "https://sanhobooks.com/"
            case .linhLan:
                return "https://linhlanbooks.vn/search"
            }
        }

        private func xayDungDanhSachThamSo(_ tuKhoa: String) -> [URLQueryItem] {
            switch self {
            case .ggImg:
                return [
                    URLQueryItem(name: "q", value: "filetype:jpg \(tuKhoa)"),
                    URLQueryItem(name: "udm", value: "2")
                ]
            case .kimDong, .nhaNam, .triViet, .alpha, .sky, .taoDan:
                return [URLQueryItem(name: "query", value: tuKhoa)]
            case .tre, .dongA, .thaiHa, .phucMinh, .azvn, .ipm, .one980, .linhLan:
                return [URLQueryItem(name: "q", value: tuKhoa)]
            case .phuNu:
                return [URLQueryItem(name: "keyword", value: tuKhoa)]
            case .shopee:
                return [URLQueryItem(name: "keyword", value: "sách \(tuKhoa)")]
            case .tiki:
                return [URLQueryItem(name: "q", value: "sách \(tuKhoa)")]
            case .danTri, .comicola:
                return [URLQueryItem(name: "s", value: tuKhoa)]
            case .sbooks, .sanHo:
                return [
                    URLQueryItem(name: "s", value: tuKhoa),
                    URLQueryItem(name: "post_type", value: "product")
                ]
            case .dhsp:
                return [
                    URLQueryItem(name: "searchContent", value: tuKhoa),
                    URLQueryItem(name: "page", value: "1"),
                    URLQueryItem(name: "objectType", value: "0,1,"),
                    URLQueryItem(name: "rating", value: "1"),
                    URLQueryItem(name: "priceFrom", value: ""),
                    URLQueryItem(name: "priceTo", value: ""),
                    URLQueryItem(name: "displaySelectionId", value: ""),
                    URLQueryItem(name: "isHighest", value: "false"),
                    URLQueryItem(name: "isLowest", value: "false")
                ]
            case .danhDau, .dinhTi:
                return []
            }
        }

        func xayDungUrl(_ tuKhoa: String) -> URL? {
            if var urlBuilder = URLComponents(string: duongDanGoc) {
                urlBuilder.queryItems = xayDungDanhSachThamSo(tuKhoa)
                let url = urlBuilder.url
                if self == .dinhTi {
                    return url?.appendingPathComponent("\(tuKhoa).html")
                }
                return url
            }
            return nil
        }

    }

    weak var boTimKiem: BoXuLyTimKiemAnh?

    override var activityTitle: String? { web.tieuDe }

    let web: Web
    let url: URL

    init(mien: Web, link: URL) {
        web = mien
        url = link
        super.init()
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
