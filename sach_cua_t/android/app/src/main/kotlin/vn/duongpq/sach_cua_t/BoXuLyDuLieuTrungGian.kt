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

package vn.duongpq.sach_cua_t

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
import java.io.File

/// Bộ xử lý Clipboard
// TODO: hiện tại chỉ xử lý ảnh
object BoXuLyDuLieuTrungGian {

    lateinit var clipboard: ClipboardManager

    private fun kiemTraMime(mime: String, loc: List<Int>): KieuTep? {
        for (kieu in loc) {
            when (kieu) {
                KieuTep.anh.value -> if (mime.startsWith("image/")) { return KieuTep.anh }
                else -> {} // TODO: trien khai sau
            }
        }
        return null
    }

    fun dan(loc: List<Int>, khiXong: (List<Any>) -> Unit) {
        val phanGiai = HeThongMay.duyNhat.manHinhChinh.contentResolver
        val mucChinh = clipboard.primaryClip
        val ketQua = mutableListOf<Any>()
        if (mucChinh != null) {
            val tong = mucChinh.itemCount
            if (tong > 0) {
                var stt = 0
                while (stt < tong) {
                    val muc = mucChinh.getItemAt(stt)
                    val uri = muc.uri
                    if (uri != null) {
                        val mime = phanGiai.getType(uri)
                        val kieuTep = if (mime != null) kiemTraMime(mime, loc) else null
                        if (kieuTep != null) {
                            val dauVao = phanGiai.openInputStream(uri)
                            if (dauVao != null) {
                                when (kieuTep) {
                                    KieuTep.anh -> {
                                        try {
                                            val bitmap = BitmapFactory.decodeStream(dauVao)
                                            ketQua.add(bitmap)
                                        } catch (err: Exception) {}
                                    }
                                    else -> {}
                                }
                                dauVao.close()
                            }
                        }
                    }
                    stt += 1
                }
            }
        }
        if (ketQua.isNotEmpty()) {
            clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
        }
        khiXong(ketQua)
    }

    fun danAnh(loc: List<Int> = listOf(KieuTep.anh.value), khiXong: (List<String>) -> Unit) {
        dan(loc) { dsKq ->
            if (dsKq.isNotEmpty()) {
                BoQuanLyThuMuc.donSachThuMuc(BoQuanLyThuMuc.thuMucDan)
            }
            val ketQua = mutableListOf<String>()
            for (muc in dsKq) {
                if (muc is Bitmap) {
                    val tep = BoQuanLyThuMuc.taoTen(BoQuanLyThuMuc.thuMucDan, null, "JPG")
                    val kqLuuAnh = BoXuLyAnh.luuAnhJpeg(muc, tep)
                    if (kqLuuAnh == null) {
                        ketQua.add(tep.path)
                    }
                }
            }
            khiXong(ketQua)
        }
    }

    fun luuAnhChiaSe(yDinh: Intent): File? {
        if (yDinh.action == Intent.ACTION_SEND && (yDinh.type ?: "").startsWith("image/")) {
            val imageUri = yDinh.extras?.get(Intent.EXTRA_STREAM)
            if (imageUri != null && imageUri is Uri) {
                try {
                    val inputStream = HeThongMay.duyNhat.manHinhChinh.contentResolver.openInputStream(imageUri)
                    if (inputStream != null) {
                        val bitmap = BitmapFactory.decodeStream(inputStream)
                        inputStream.close()
                        val tep = BoQuanLyThuMuc.taoTen(BoQuanLyThuMuc.thuMucChiaSe, null, "JPG")
                        if (BoXuLyAnh.luuAnhJpeg(bitmap, tep) == null) {
                            return tep
                        }
                    }
                } catch (err: Exception) {}
            }
        }
        return null
    }

    fun danUrlSach(): Boolean {
        val mucChinh = clipboard.primaryClip
        if (mucChinh != null) {
            val tongSo = mucChinh.itemCount
            if (tongSo > 0) {
                var stt = 0
                while (stt < tongSo) {
                    val muc = mucChinh.getItemAt(stt)
                    var noiDung = muc.uri?.toString() ?: muc.text?.toString()
                    if (noiDung != null && HeThongMay.duyNhat.danhDauUrlSach(noiDung)) {
                        return true
                    }
                    stt += 1
                }
            }
        }
        return false
    }

}
