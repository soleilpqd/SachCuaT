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
    private var khiDan: (() -> Void)?
    private weak var safari: SFSafariViewController?
    private var timer: Timer?

    /// Bắt đầu (cần xoá bộ dữ liệu trung gian trước khi gọi hàm này)
    func batDau(tuKhoa: String, xong: @escaping () -> Void, dan: @escaping () -> Void) -> Bool {
        khiXong = xong
        khiDan = dan
        if var urlBuilder = URLComponents(string: "https://www.google.com/search") {
            urlBuilder.queryItems = [
                URLQueryItem(name: "q", value: "filetype:jpg \(tuKhoa)"),
                URLQueryItem(name: "udm", value: "2")
            ]
            if let url = urlBuilder.url, let rootController = AppDelegate.app.rootViewController {
                let controller = SFSafariViewController(url: url)
                controller.delegate = self
                safari = controller
                rootController.present(controller, animated: true)
                timer = Timer.scheduledTimer(
                    timeInterval: 0.5,
                    target: self,
                    selector: #selector(khiKiemTraBoDuLieuTrungGianTuDong),
                    userInfo: nil,
                    repeats: true
                )
                return true
            }
        }
        return false
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
            khiDan?()
        }
    }

    /// Kiểm tra bộ dữ liệu trung gian có dữ liệu hay không
    private func kiemTraDieuKienDan() -> Bool {
        let boDL = BoXuLyDuLieuTrungGian.duyNhat.boDuLieuTrungGian
        return boDL.hasURLs || boDL.hasImages
    }

}

extension BoXuLyTimKiemAnh: SFSafariViewControllerDelegate {

    /// Người dùng chủ động nhấn đóng màn hình
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if kiemTraDieuKienDan() {
            khiDan?()
        } else {
            khiXong?()
        }
        donDep()
    }

}
