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

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

//    private fun getRootView(): View { return findViewById(android.R.id.content) }

//    private val originDisplayRect = mutableMapOf<Int, Rect>()
//    private var lastOrientation: Int = 0
//    private var kbHeight: Int = 0

//    private val layoutListener = ViewTreeObserver.OnGlobalLayoutListener {
//        var banPhimThayDoi = false
//        var chieuThayDoi = false
//        val orientation = resources.configuration.orientation
//        if (lastOrientation != orientation) {
//            lastOrientation = orientation
//            chieuThayDoi = true
//        }
//        val rootView = getRootView()
//        val displayRect = Rect()
//        rootView.getWindowVisibleDisplayFrame(displayRect)
//        val originRect = originDisplayRect[orientation]
//        var kbH = 0
//        if (originRect != null) {
//            kbH = originRect.height() - displayRect.height()
//        } else {
//            originDisplayRect[orientation] = displayRect
//        }
//        if (kbH != kbHeight) {
//            kbHeight = kbH
//            banPhimThayDoi = true
//        }
//        xuLyThayDoiHienThi(banPhimThayDoi, chieuThayDoi)
//    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        HeThongMay.register(flutterEngine, this)
    }

//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        lastOrientation = resources.configuration.orientation
//        val rootView = getRootView()
//        val rect = Rect()
//        rootView.getWindowVisibleDisplayFrame(rect)
//        originDisplayRect[lastOrientation] = rect
//        rootView.viewTreeObserver.addOnGlobalLayoutListener(layoutListener)
//    }

//    override fun onDestroy() {
//        super.onDestroy()
//        getRootView().viewTreeObserver.removeOnGlobalLayoutListener(layoutListener)
//    }

//     // Lấy thông tin hiển thị màn hình
//    fun layThongTinManHinh(): MutableMap<String, Any> {
//        val rootView = getRootView()
//        val target = rootView.rootView
//        val ketQua = mutableMapOf<String, Any>(
//            "o" to if( lastOrientation == Configuration.ORIENTATION_PORTRAIT) "p" else "l",
//            "kb_h" to kbHeight,
//            "scr_w" to target.width,
//            "scr_h" to target.height,
//            "w" to rootView.width,
//            "h" to rootView.height,
//            "t" to rootView.top,
//            "l" to rootView.left
//        )
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//            val insets = target.rootWindowInsets
//            if (insets != null) {
//                val cutout = insets.displayCutout
//                if (cutout != null) {
//                    ketQua["st"] = cutout.safeInsetTop
//                    ketQua["sb"] = cutout.safeInsetBottom
//                    ketQua["sl"] = cutout.safeInsetLeft
//                    ketQua["sr"] = cutout.safeInsetRight
//                }
//            }
//        }
//        return ketQua
//    }
//
//    /// Xử lý thay đổi hiển thị với Bàn phím và Chiều màn hình
//    private fun xuLyThayDoiHienThi(banPhim: Boolean, chieuManHinh: Boolean) {
//        if (banPhim || chieuManHinh) {
//            val ketQua = layThongTinManHinh()
//            ketQua["bp"] = banPhim
//            ketQua["chieu"] = chieuManHinh
//            HeThongMay.duyNhat.thongBaoCapNhatHienThi(ketQua)
//        }
//    }

    /// Hiển thị màn hình Camera
    /// - [kieu]: kiểu quét mã
    /// - [maTraKetQua]: mã lưu trữ đối tượng Flutter Result để trả lại kết quả cho FLutter module
    fun hienThiManHinhCamera(kieu: KieuQuetMaCamera, maTraKetQua: Int) {
        val intent = Intent(this, ManHinhCamera::class.java)
        intent.putExtra("mode", kieu.giaTri)
        intent.putExtra("response", maTraKetQua)
        startActivity(intent)
    }

}
