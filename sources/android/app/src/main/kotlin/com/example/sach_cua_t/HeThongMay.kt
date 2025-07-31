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

package com.example.sach_cua_t

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/// Tên hàm gọi từ Flutter đến native
enum class TenHamTuFlutter(val value: String) {

    quetMaISBN("quetMaISBN");

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

    kiemTraISBN("kiemTraISBN")

}

class NhanKetQuaKenhFlutter: MethodChannel.Result {

    var khiThanhCong: ((duLieu: Any?) -> Unit)? = null
    var khiThatBai: ((errorCode: String, errorMessage: String?, errorDetails: Any?) -> Unit)? = null

    override fun success(result: Any?) {
        khiThanhCong?.invoke(result)
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        khiThatBai?.invoke(errorCode, errorMessage, errorDetails)
    }

    override fun notImplemented() {    }

}

class HeThongMay(kenh: MethodChannel, main: MainActivity): MethodCallHandler {

    private val kenhKetNoi: MethodChannel = kenh
    private val manHinhChinh: MainActivity
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

    private fun themHangDoiTraKetQua(result: MethodChannel.Result): Int {
        for (index in Int.MIN_VALUE..Int.MAX_VALUE) {
            if (!dsTraKetQua.containsKey(index)) {
                dsTraKetQua[index] = result
                return index
            }
        }
        return 0
    }

    fun layTraKetQua(ma: Int): MethodChannel.Result? {
        return dsTraKetQua.remove(ma)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (TenHamTuFlutter.taoTuTenTho(call.method)) {
            TenHamTuFlutter.quetMaISBN -> {
                val ma = themHangDoiTraKetQua(result)
                manHinhChinh.hienThiManHinhCamera(KieuQuetMaCamera.isbn, ma)
            }
            null -> result.error("1", "Hàm không xác định", call.method)
        }
    }

    fun kiemTraISBN(giaTri: String, nhanKetQua: (Boolean) -> Unit) {
        val callback = NhanKetQuaKenhFlutter()
        callback.khiThanhCong = { ketQua ->
            if (ketQua is Boolean) {
                nhanKetQua(ketQua)
            }
        }
        kenhKetNoi.invokeMethod(TenHamDenFlutter.kiemTraISBN.value, giaTri, callback)
    }

}
