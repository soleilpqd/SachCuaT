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

final class BoQuanLyThuMuc {

    static let duyNhat = BoQuanLyThuMuc()

    private(set) var thuMucDan: URL!
    private(set) var thuMucChiaSe: URL!
    private(set) var thuMucMayAnh: URL!
    private(set) var thuMucCSDL: URL!
    private(set) var thuMucAnhSach: URL!

    private init() {}

    /// Hàm khởi tạo các thư mục của App khi khởi động
    func batDau(_ dsThuMuc: [String: String]) -> [String: String] {
        let fileMan = FileManager.default
        guard let duongDanDoc = fileMan.urls(for: .documentDirectory, in: .userDomainMask).first,
              let duongDanTam = fileMan.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return [:] }
        var ketQua = [String: String]()
        for (ten, duongDan) in dsThuMuc {
            if let url = URL(string: duongDan), url.scheme == "sct" {
                let duongDanCoSo: URL?
                switch url.host {
                case "dulieu.sach":
                    duongDanCoSo = duongDanDoc
                case "tam.sach":
                    duongDanCoSo = duongDanTam
                default:
                    duongDanCoSo = nil
                }
                if let coSo = duongDanCoSo {
                    let urlKq = url.path.count < 2 ? coSo : coSo.appendingPathComponent(url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
                    if !fileMan.fileExists(atPath: urlKq.path) {
                        try? fileMan.createDirectory(at: urlKq, withIntermediateDirectories: true)
                    }
                    ketQua[ten] = urlKq.path
                    switch ten {
                    case "dan":
                        thuMucDan = urlKq
                    case "mayAnh":
                        thuMucMayAnh = urlKq
                    case "chiaSe":
                        thuMucChiaSe = urlKq
                    case "dl":
                        thuMucCSDL = urlKq
                    case "anhSach":
                        thuMucAnhSach = urlKq
                    default:
                        break
                    }
                }
            }
        }
        return ketQua
    }

    /// Xoá hết các mục con trong thư mục được chỉ định
    func donSachThuMuc(_ duongDan: URL) {
        let fileMan = FileManager.default
        for muc in (try? fileMan.contentsOfDirectory(at: duongDan, includingPropertiesForKeys: nil)) ?? [] {
            try? fileMan.removeItem(at: muc)
        }
    }

    /// Sao chép các tệp nguồn vào thư mục đích
    func saoChep(nguon: [URL], thuMucDich: URL) {
        let fileMan = FileManager.default
        for muc in nguon {
            let tepDich = thuMucDich.appendingPathComponent(muc.lastPathComponent)
            try? fileMan.copyItem(at: muc, to: tepDich)
        }
    }

    /// Tạo mới 1 tên tệp chưa tồn tại trong thư mục chỉ định
    /// theo định dạng: `<tenGoc>_<stt>.<ext>`
    func taoTen(thuMuc: URL, tenGoc: String?, ext: String) -> URL {
        var ten = ""
        var kieu = ext
        if let tGoc = tenGoc, !tGoc.isEmpty {
            let temp = thuMuc.appendingPathComponent(tGoc)
            if !temp.pathExtension.isEmpty {
                kieu = temp.pathExtension
            }
            ten = temp.deletingPathExtension().lastPathComponent
        }

        var ketQua = thuMuc.appendingPathComponent(ten.isEmpty ? "1" : ten).appendingPathExtension(kieu)
        var stt = ten.isEmpty ? 1 : 0;
        while FileManager.default.fileExists(atPath: ketQua.path) {
            stt += 1
            ketQua = thuMuc.appendingPathComponent(ten.isEmpty ? "\(stt)" : "\(ten)_\(stt)").appendingPathExtension(kieu)
        }
        return ketQua
    }

}
