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

package vn.duongpq.sach_cua_t

import android.Manifest
import androidx.appcompat.app.AppCompatActivity
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.ImageButton
import androidx.annotation.OptIn
import androidx.appcompat.app.AlertDialog
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import vn.duongpq.sach_cua_t.databinding.ActivityManHinhCameraBinding
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage

/// Kiểu quét mã qua máy ảnh
enum class KieuQuetMaCamera(val giaTri: Int) {
    isbn(0),
    other(1);

    companion object {
        /// Tạo từ giá trị thô
        fun taoTuGiaTriTho(raw: Int): KieuQuetMaCamera? {
            for (item in KieuQuetMaCamera.values()) {
                if (item.giaTri == raw) {
                    return item
                }
            }
            return null
        }
    }
}

/// Màn hình camera (quét mã đồ hoạ)
class ManHinhCamera : AppCompatActivity() {

    private lateinit var binding: ActivityManHinhCameraBinding
    /// Camera preview
    private lateinit var previewView: PreviewView
    /// Nút đóng
    private lateinit var nutDong: ImageButton
    /// Kiểu quét (kiểu barcode cần quét)
    private lateinit var kieuQuet: KieuQuetMaCamera
    /// Công cụ quét barcode từ MLKit
    private lateinit var barcodeScanner: BarcodeScanner
    /// Mã để trả lại kết quả cho flutter (thông qua `HeThongMay`)
    private var maKetQua: Int = 0

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        kieuQuet = KieuQuetMaCamera.taoTuGiaTriTho(intent.getIntExtra("mode", 0)) ?: KieuQuetMaCamera.isbn
        maKetQua = intent.getIntExtra("response", 0)
        binding = ActivityManHinhCameraBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val barcodeOptions = BarcodeScannerOptions.Builder()
        when (kieuQuet) {
            KieuQuetMaCamera.isbn -> {
                barcodeOptions.setBarcodeFormats(
                    Barcode.FORMAT_EAN_13
                )
            }
            KieuQuetMaCamera.other -> {
                barcodeOptions.setBarcodeFormats(
                    Barcode.FORMAT_ALL_FORMATS
                )
            }
        }

        barcodeScanner = BarcodeScanning.getClient(barcodeOptions.build())

        supportActionBar?.hide()
        previewView = binding.previewView
        nutDong = binding.nutDong
        nutDong.setOnTouchListener(khiNhanNutDong)

        if (!kiemTraQuyenSuDungMayAnh()) {
            yeuCauQuyenSuDungMayAnh()
        } else {
            cauHinhMayAnh()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        barcodeScanner.close()
    }

    /// Khi nhấn nút đóng
    private val khiNhanNutDong = View.OnTouchListener { view, motionEvent ->
        finish()
        false
    }

    /// Xử lý khi không có máy ảnh (phần cứng, quyền)
    private fun khiKhongCoMayAnh() {
        HeThongMay.duyNhat.layTraKetQua(maKetQua)?.error("2", "No camera", "")
        finish()
    }

    /// Khởi chạy camera
    @OptIn(ExperimentalGetImage::class) private fun cauHinhMayAnh() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

        cameraProviderFuture!!.addListener({
            val cameraProvider = cameraProviderFuture!!.get()
            // Cấu hình preview
            val previewUseCase = Preview.Builder().build()
            previewUseCase.setSurfaceProvider(previewView.surfaceProvider)
            // Chọn camera (mặt lưng)
            val cameraSelector = CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                .build()
            // Cấu hình xử lý frame hình
            val analysisUseCase = ImageAnalysis.Builder().build()
            analysisUseCase.setAnalyzer(
                ContextCompat.getMainExecutor(this)
            ) { imageProxy: ImageProxy ->
                val mediaImage = imageProxy.image
                if (mediaImage != null) {
                    val inputImage = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)
                    val processor = barcodeScanner.process(inputImage)
                    processor.addOnSuccessListener { barcodes ->
                        var found = false
                        if (barcodes.isNotEmpty()) {
                            for (barcode in barcodes) {
                                val raw = barcode.rawValue
                                if (raw != null) {
                                    khiQuetDuocDL(raw, cameraProvider, imageProxy)
                                    found = true
                                }
                            }
                        }
                        if (!found) {
                            imageProxy.close()
                        }
                    }
                    processor.addOnFailureListener {
                        imageProxy.close()
                    }
                }
            }
            // Gán các cấu hình vào cho Camera provider
            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this as LifecycleOwner,
                    cameraSelector,
                    previewUseCase, analysisUseCase
                )
            } catch(exc: Exception) {
                Log.e("ERROR CAMERA", exc.toString())
                khiKhongCoMayAnh()
            }

        }, ContextCompat.getMainExecutor(this))
    }

    /// Kiểm tra quyền sử dụng máy ảnh
    private fun kiemTraQuyenSuDungMayAnh(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
    }

    /// Yêu cầu quyền sử dụng máy ảnh
    private fun yeuCauQuyenSuDungMayAnh() {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 1)
    }

    /// Hàm xử lý kết quả yêu cầu quyền
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (kiemTraQuyenSuDungMayAnh()) {
            cauHinhMayAnh()
        } else {
            khiKhongCoMayAnh()
        }
    }

    /// Khi quét được DL
    private fun khiQuetDuocDL(raw: String, cameraProvider: ProcessCameraProvider, imageProxy: ImageProxy) {
        HeThongMay.duyNhat.kiemTraISBN(raw) { ketQua ->
            if (ketQua) {
                cameraProvider.unbindAll()
                finish()
                HeThongMay.duyNhat.layTraKetQua(maKetQua)?.success(raw)
            }
            imageProxy.close()
        }
    }

}
