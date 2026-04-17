/*
 Sách của T - Quản lý sách cá nhân
 Copyright © 2025 SoleilPQD

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
import AVFoundation

/// Màn hình Camera (quét mã đồ hoạ)
final class ManHinhCamera: UIViewController {

    /// Kiểu quét
    enum KieuQuet {
        case isbn
        case other
    }

    var resultHandle: FlutterResult?
    var kieuQuet = KieuQuet.isbn

    private var videoLayer = AVCaptureVideoPreviewLayer()
    private var captureSession = AVCaptureSession()
    private var khiCauHinhXong: (() -> Void)?

    @IBOutlet private weak var nutDong: UIButton!

    /// Chuẩn bị (gọi trước khi hiển thị màn hình -> nếu có lỗi thì trả kết quả luôn)
    func chuanBi(_ khiXong: @escaping () -> Void) {
        khiCauHinhXong = khiXong
        kiemTraQuyenTruyCap()
    }

    /// Khi nhấn nút đóng
    @IBAction private func khiNhanNutDong(_ doiTuong: Any?) {
        ketThuc(voi: nil)
    }

    deinit {
        print("DESTROY CAMERA VIEW")
    }

    // MARK: - Internal

    /// Kết thúc
    private func ketThuc(voi ketQua: String?) {
        var this: ManHinhCamera? = self
        dismiss(animated: true) {
            this?.resultHandle?(ketQua)
            this = nil
        }
    }

    /// Kiểm tra quyền truy cập
    private func kiemTraQuyenTruyCap() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cauHinhCamera()
        case .denied:
            khiKhongCoCamera()
        case .notDetermined:
            yeuCauTruyCap()
        default:
            break
        }
    }

    /// Yêu cầu quyền truy cập
    private func yeuCauTruyCap() {
        AVCaptureDevice.requestAccess(for: .video) {[weak self] capPhep in
            DispatchQueue.main.async {
                if capPhep {
                    self?.cauHinhCamera()
                } else {
                    self?.khiKhongCoCamera()
                }
            }
        }
    }

    /// Khi không có camera
    private func khiKhongCoCamera() {
        resultHandle?(FlutterError(code: "2", message: "No camera", details: nil))
        khiCauHinhXong = nil
    }

    /// Cấu hình camera
    private func cauHinhCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            khiKhongCoCamera()
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            khiKhongCoCamera()
            return
        }

        let outPut = AVCaptureMetadataOutput()
        captureSession.addOutput(outPut)
        outPut.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        switch kieuQuet {
        case .isbn:
            outPut.metadataObjectTypes = [.ean13]
        case .other:
            var types: [AVMetadataObject.ObjectType] = [
                .aztec,
                .code39,
                .code93,
                .code128,
                .code39Mod43,
                .ean8,
                .ean13,
                .itf14,
                .interleaved2of5,
                .dataMatrix,
                .qr,
                .upce,
                .pdf417
            ]
            if #available(iOS 15.4, *) {
                let additions: [AVMetadataObject.ObjectType] = [
                    .codabar,
                    .gs1DataBar,
                    .gs1DataBarLimited,
                    .gs1DataBarExpanded,
                    .microQR,
                    .microPDF417
                ]
                types.append(contentsOf: additions)
            }
            outPut.metadataObjectTypes = types
        }

        videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.backgroundColor = UIColor.white.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        self.view.layer.addSublayer(videoLayer)
        self.view.bringSubviewToFront(nutDong)
        captureSession.startRunning()
        khiCauHinhXong?()
        khiCauHinhXong = nil
    }

}

extension ManHinhCamera: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        print("CAMERA")
//        for item in metadataObjects {
//            print("", item.type)
//            if let obj = item as? AVMetadataMachineReadableCodeObject {
//                print("", obj.type, obj.descriptor, obj.stringValue)
//            }
//        }
        for item in metadataObjects {
            if let obj = item as? AVMetadataMachineReadableCodeObject {
                if let data = obj.stringValue {
                    switch kieuQuet {
                    case .isbn:
                        if obj.type == .ean13 {
                            DispatchQueue.main.async {[weak self] in
                                HeThongMay.duyNhat.kiemTraISBN(giaTri: data) { ketQua in
                                    print("KIEM TRA ISBN", data, ketQua)
                                    if ketQua {
                                        self?.ketThuc(voi: data)
                                    }
                                }
                            }
                        }
                    case .other:
                        DispatchQueue.main.async {[weak self] in
                            self?.ketThuc(voi: data)
                        }
                    }
                }
            }
        }
    }

}
