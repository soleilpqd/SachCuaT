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

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts

/// Bộ xử lý chọn tệp
class BoXuLyChonTep(val manHinhChinh: ComponentActivity) {

    var khiChonXongTep: ((Bitmap?) -> Unit)? = null
    private var boKichHoatChonTep: ActivityResultLauncher<Intent>? = null

    /// Cấu hình
    fun cauHinh() {
        boKichHoatChonTep = manHinhChinh.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result: ActivityResult ->
            if (result.resultCode == Activity.RESULT_OK && result.data != null && result.data!!.data != null && khiChonXongTep != null) {
                val inputStream = manHinhChinh.contentResolver.openInputStream(result.data!!.data!!)
                if (inputStream != null) {
                    try {
                        val bitmap = BitmapFactory.decodeStream(inputStream)
                        if (bitmap != null) {
                            khiChonXongTep?.invoke(bitmap)
                            khiChonXongTep = null
                        }
                    } catch (err: Exception) {}
                    inputStream.close()
                }
            }
            khiChonXongTep?.invoke(null)
        }
    }

    /// Mở chọn tệp
    fun moChonTep(loc: List<Int>, khiXong: (Bitmap?) -> Unit) {
        khiChonXongTep = khiXong
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        // TODO: hiện tại chỉ xử lý ảnh
        intent.setType("image/*")
        boKichHoatChonTep!!.launch(intent)
    }

}
