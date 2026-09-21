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

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.io.FileOutputStream
import vn.duongpq.sach_cua_t.BuildConfig

/// Tên hàm gọi từ Flutter đến native
enum class TenHamTuFlutter(val value: String) {

    quetMaISBN("quetMaISBN"),
    luuAnhSach("luuAnhSach"),
    phienBan("phienBan");
//    layThongTinHienThi("layThongTinHienThi");

    companion object {
        fun taoTuTenTho(raw: String): TenHamTuFlutter? {
            for (item in TenHamTuFlutter.values()) {
                if (item.value == raw) {
                    return item
                }
            }
            return null
        }
    }

}

/// Tên hàm gọi từ Native về Flutter
enum class TenHamDenFlutter(val value: String) {

    kiemTraISBN("kiemTraISBN"),
//    capNhatHienThi("capNhatHienThi");
    khiNhanNutLui("nutLuiAndroid");

}

/// Callback trả kết quả khi từ native gọi đến flutter
class NhanKetQuaKenhFlutter: MethodChannel.Result {

    /// Khi thành công
    var khiThanhCong: ((duLieu: Any?) -> Unit)? = null
    /// Khi thất bại
    var khiThatBai: ((errorCode: String, errorMessage: String?, errorDetails: Any?) -> Unit)? = null

    override fun success(result: Any?) {
        khiThanhCong?.invoke(result)
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        khiThatBai?.invoke(errorCode, errorMessage, errorDetails)
    }

    override fun notImplemented() {    }

}

/// Hệ thống máy
class HeThongMay(kenh: MethodChannel, main: MainActivity): MethodCallHandler {

    /// Kênh kết nối
    private val kenhKetNoi: MethodChannel = kenh
    /// Màn hình chính
    private val manHinhChinh: MainActivity
    /// Hàng đợi các đối tượng trả kết quả cho flutter
    private val dsTraKetQua = mutableMapOf<Int, MethodChannel.Result>()

    companion object {
        lateinit var duyNhat: HeThongMay

        fun register(engine: FlutterEngine, main: MainActivity) {
            duyNhat = HeThongMay(MethodChannel(engine.dartExecutor.binaryMessenger, "sach.cua.T"), main)
        }
    }

    init {
        kenhKetNoi.setMethodCallHandler(this)
        manHinhChinh = main
    }

    /// Thêm hàng đợi trả kết quả
    private fun themHangDoiTraKetQua(result: MethodChannel.Result): Int {
        for (index in Int.MIN_VALUE..Int.MAX_VALUE) {
            if (!dsTraKetQua.containsKey(index)) {
                dsTraKetQua[index] = result
                return index
            }
        }
        return 0
    }

    /// Lấy đối tượng trả kết quả
    fun layTraKetQua(ma: Int): MethodChannel.Result? {
        return dsTraKetQua.remove(ma)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (TenHamTuFlutter.taoTuTenTho(call.method)) {
            TenHamTuFlutter.quetMaISBN -> {
                val ma = themHangDoiTraKetQua(result)
                manHinhChinh.hienThiManHinhCamera(KieuQuetMaCamera.isbn, ma)
            }
            TenHamTuFlutter.luuAnhSach -> {
                luuAnhSach(call, result)
            }
            TenHamTuFlutter.phienBan -> {
                result.success(BuildConfig.VERSION_NAME)
            }
//            TenHamTuFlutter.layThongTinHienThi -> {
//                val ketQua = manHinhChinh.layThongTinManHinh()
//                result.success(ketQua)
//            }
            null -> result.error("1", "Hàm không xác định", call.method)
        }
    }

    /// Kiểm tra ISBN: hàm từ native gọi cho flutter
    fun kiemTraISBN(giaTri: String, nhanKetQua: (Boolean) -> Unit) {
        val callback = NhanKetQuaKenhFlutter()
        callback.khiThanhCong = { ketQua ->
            if (ketQua is Boolean) {
                nhanKetQua(ketQua)
            }
        }
        kenhKetNoi.invokeMethod(TenHamDenFlutter.kiemTraISBN.value, giaTri, callback)
    }
    
    fun coDanAnh(dauVao: Bitmap, gioiHan: Int): Bitmap? {
        val chieuRong: Int
        val chieuCao: Int
        if (dauVao.height > dauVao.width) {
            chieuRong = gioiHan * dauVao.width / dauVao.height
            chieuCao = gioiHan
        } else {
            chieuRong = gioiHan
            chieuCao = gioiHan * dauVao.height / dauVao.width
        }
        try {
            return Bitmap.createScaledBitmap(dauVao, chieuRong, chieuCao, false)
        } catch (err: Exception) {}
        return null
    }

    /// Lưu ảnh sách (ảnh chính, ảnh thu nhỏ)
    private fun luuAnhSach(call: MethodCall, result: MethodChannel.Result) {
        val anhGoc = call.argument<String>("goc")
        val anhSach = call.argument<String>("dich")
        val anhThuNho = call.argument<String>("thunho")
        val chieuCao = call.argument<Int>("cao")
        val gioiHan = call.argument<Int>("gioi_han")
        val chatLuong = call.argument<Int>("chat_luong")
        if (anhGoc == null || anhSach == null || anhThuNho == null || chieuCao == null || gioiHan == null || chatLuong == null) {
            result.error("luuAnhSach_1", "Tham số không đúng", call.method)
            return
        }
        // Nạp ảnh gốc
        var bitmap: Bitmap? = null
        try {
            bitmap = BitmapFactory.decodeFile(anhGoc)
        } catch (err: Exception) {}
        if (bitmap == null) {
            result.error("luuAnhSach_2", "Không nạp được ảnh gốc", anhGoc)
            return
        }
        var bitmapDeLuu = bitmap
        if (bitmap.width >= gioiHan || bitmap.height >= gioiHan) {
            bitmapDeLuu = coDanAnh(bitmap, gioiHan) ?: bitmap
        }
        // Lưu vào CSDL dưới dạng JPEG
        try {
            val outStream = FileOutputStream(File(anhSach))
            bitmapDeLuu!!.compress(Bitmap.CompressFormat.JPEG, chatLuong, outStream)
            outStream.flush()
            outStream.close()
        } catch (err: Exception) {
            result.error("luuAnhSach_3", "Không tạo được JPEG data", anhGoc)
            return
        }
        // Tạo ảnh thu nhỏ
        val bitmapTn: Bitmap? = coDanAnh(bitmap, chieuCao)
        if (bitmapTn == null) {
            result.error("luuAnhSach_5", "Không vẽ được ảnh thu nhỏ", anhThuNho)
            return
        }
        // Lưu ảnh JPEG thu nhỏ
        try {
            val outStream = FileOutputStream(File(anhThuNho))
            bitmapTn!!.compress(Bitmap.CompressFormat.JPEG, chatLuong, outStream)
            outStream.flush()
            outStream.close()
        } catch (err: Exception) {
            result.error("luuAnhSach_6", "Không tạo được JPEG data ảnh thu nhỏ", anhGoc)
            return
        }
        result.success(true)
    }

//    fun thongBaoCapNhatHienThi(thongTin: Map<String, Any>) {
//        kenhKetNoi.invokeMethod(TenHamDenFlutter.capNhatHienThi.value, thongTin)
//    }

    fun khiNhanNutLui(xuLyHeThong: () -> Unit) {
        val callback = NhanKetQuaKenhFlutter()
        callback.khiThanhCong = { ketQua ->
            if (ketQua is Boolean && ketQua) {
                xuLyHeThong()
            }
        }
        kenhKetNoi.invokeMethod(TenHamDenFlutter.khiNhanNutLui.value, null, callback)
    }

}
