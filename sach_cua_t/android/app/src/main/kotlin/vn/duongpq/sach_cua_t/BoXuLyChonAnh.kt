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

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.provider.MediaStore
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import java.io.File

/// Bộ xử lý Mở máy ảnh hoặc Thư viện ảnh + Kiểm tra quyền sử dụng máy ảnh
class BoXuLyChonAnh(
    val manHinhChinh: ComponentActivity,
    val maYeuCauQuyenTruyCapMayAnh: Int
) {

    var khiChupChonXongAnh: ((Bitmap?, Boolean) -> Unit)? = null
    private var boKichHoatCameraChupAnh: ActivityResultLauncher<Intent>? = null
    private var boKichHoatChonAnh: ActivityResultLauncher<PickVisualMediaRequest>? = null
    private var dauRaMayAnh: File? = null

    /// Cấu hình để mở chụp ảnh hoặc chọn ảnh (nếu chỉ dùng kiểm tra quyền truy cập máy ảnh thì không cần)
    fun cauHinh() {
        dauRaMayAnh = File(manHinhChinh.externalCacheDir, "anh_chup.JPG")
        boKichHoatChonAnh = manHinhChinh.registerForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
            var bitmap: Bitmap? = null
            if (uri != null) {
                val inputStream = manHinhChinh.contentResolver.openInputStream(uri)
                if (inputStream != null) {
                    bitmap = BitmapFactory.decodeStream(inputStream)
                    inputStream.close()
                }
            }
            khiChupChonXongAnh?.invoke(bitmap, true)
        }
        boKichHoatCameraChupAnh = manHinhChinh.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result: ActivityResult ->
            var bitmap: Bitmap? = null
            if (dauRaMayAnh != null && dauRaMayAnh!!.exists()) {
                val inputStream = dauRaMayAnh!!.inputStream()
                bitmap = BitmapFactory.decodeStream(inputStream)
                inputStream.close()
                dauRaMayAnh!!.delete()
            }
            khiChupChonXongAnh?.invoke(bitmap, true)
        }
    }

    /// Kiểm tra quyền sử dụng máy ảnh
    fun kiemTraQuyenSuDungMayAnh(): Boolean {
        return ContextCompat.checkSelfPermission(manHinhChinh, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
    }

    /// Yêu cầu quyền sử dụng máy ảnh
    fun yeuCauQuyenSuDungMayAnh() {
        ActivityCompat.requestPermissions(manHinhChinh, arrayOf(Manifest.permission.CAMERA), maYeuCauQuyenTruyCapMayAnh)
    }

    /// Mở màn hình chọn ảnh (cần gọi `cauHinh()` tại `onCreate` của màn hình chính)
    fun moChonAnh() {
        boKichHoatChonAnh!!.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
    }

    /// Mở máy ảnh (không bao gồm kiểm tra quyền) (cần gọi `cauHinh()` tại `onCreate` của màn hình chính)
    fun moMayAnh() {
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (dauRaMayAnh!!.exists()) {
            dauRaMayAnh!!.delete()
        }
        val photoUri = FileProvider.getUriForFile(manHinhChinh, manHinhChinh.packageName + ".provider", dauRaMayAnh!!)
        intent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
        boKichHoatCameraChupAnh!!.launch(intent)
    }

}
