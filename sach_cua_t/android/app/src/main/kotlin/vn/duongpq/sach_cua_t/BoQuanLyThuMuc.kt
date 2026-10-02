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

import android.net.Uri
import androidx.core.net.toUri
import java.io.File

object BoQuanLyThuMuc {

    lateinit var thuMucDan: File
        private set
    lateinit var thuMucChiaSe: File
        private set
    lateinit var thuMucMayAnh: File
        private set
    lateinit var thuMucCSDL: File
        private set
    lateinit var thuMucAnhSach: File
        private set

    fun batDau(dsThuMuc: Map<String, String>): Map<String, String> {
        val ketQua = mutableMapOf<String, String>()
        val mhChinh = HeThongMay.duyNhat.manHinhChinh
        val duongDanDoc = mhChinh.getExternalFilesDir("du_lieu")
        val duongDanTam = mhChinh.cacheDir
        dsThuMuc.forEach { (ten, duongDan) ->
            val uri = duongDan.toUri()
            if (uri.scheme == "sct") {
                var duongDanCoSo: File? = null
                when (uri.host) {
                    "dulieu.sach" -> duongDanCoSo = duongDanDoc
                    "tam.sach" -> duongDanCoSo = duongDanTam
                }
                if (duongDanCoSo != null) {
                    val path = uri.path ?: ""
                    val duongDanKq = if (path.length > 1) File(duongDanCoSo, path) else duongDanCoSo
                    if (!duongDanKq.exists()) {
                        duongDanKq.mkdirs()
                    }
                    ketQua[ten] = duongDanKq.path
                    when (ten) {
                        "dan" -> thuMucDan = duongDanKq
                        "mayAnh" -> thuMucMayAnh = duongDanKq
                        "chiaSe" -> thuMucChiaSe = duongDanKq
                        "dl" -> thuMucCSDL = duongDanKq
                        "anhSach" -> thuMucAnhSach = duongDanKq
                    }
                }
            }
        }
        return ketQua
    }

    /// Xoá hết các mục con trong thư mục được chỉ định
    fun donSachThuMuc(duongDan: File) {
        duongDan.listFiles()?.forEach { muc ->
            try {
                muc.deleteRecursively()
            } catch (err: Exception) {}
        }
    }

    /// Sao chép các tệp nguồn vào thư mục đích
    fun saoChep(nguon: List<File>, thuMucDich: File) {
        for (muc in nguon) {
            try {
                val tepDich = File(thuMucDich, muc.name)
                muc.copyTo(target = tepDich, overwrite = true)
            } catch (err: Exception) {}
        }
    }

    /// Tạo mới 1 tên tệp chưa tồn tại trong thư mục chỉ định
    /// theo định dạng: `<tenGoc>_<stt>.<ext>`
    fun taoTen(thuMuc: File, tenGoc: String?, ext: String): File {
        var ten = ""
        var kieu = ext
        val tGoc = tenGoc
        if (tGoc != null && tGoc.isNotEmpty()) {
            val temp = File(thuMuc, tGoc)
            val tempExt = temp.extension
            if (tempExt.isNotEmpty()) {
                kieu = tempExt
            }
            ten = temp.nameWithoutExtension
        }

        var tenDayDu = ten.ifEmpty { "1" } + if (kieu.isEmpty()) "" else ".$kieu"
        var ketQua = File(thuMuc, tenDayDu)
        var stt = if (ten.isEmpty()) 1 else 0;
        while (ketQua.exists()) {
            stt += 1
            tenDayDu = if (ten.isEmpty()) "$stt" else "${ten}_${stt}" + if (kieu.isEmpty()) "" else ".$kieu"
            ketQua = File(thuMuc, tenDayDu)
        }
        return ketQua
    }

}
