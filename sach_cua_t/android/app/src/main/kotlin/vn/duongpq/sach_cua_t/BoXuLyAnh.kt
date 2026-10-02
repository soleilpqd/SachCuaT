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

import android.graphics.Bitmap
import java.io.File
import java.io.FileOutputStream

/// Xử lý ảnh
object BoXuLyAnh {

    /// Co dãn ảnh
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

    /// Lưu ảnh thành tệp JPEG
    fun luuAnhJpeg(anh: Bitmap, mucTieu: File, chatLuong: Int = 100): Exception? {
        try {
            val outstream = FileOutputStream(mucTieu)
            anh.compress(Bitmap.CompressFormat.JPEG, chatLuong, outstream)
            outstream.flush()
            outstream.close()
            return null
        } catch (err: Exception) {
            return err
        }
    }

}
