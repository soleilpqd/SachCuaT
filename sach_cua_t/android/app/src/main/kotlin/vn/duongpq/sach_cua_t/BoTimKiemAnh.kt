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

import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.customtabs.CustomTabsIntent.SHARE_STATE_ON
import androidx.browser.customtabs.CustomTabsService
import androidx.core.net.toUri
import io.flutter.FlutterInjector
import kotlinx.serialization.ExperimentalSerializationApi
import java.io.InputStream
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonIgnoreUnknownKeys
import java.io.File
import java.net.URLEncoder
import kotlin.math.min

@OptIn(ExperimentalSerializationApi::class)
@JsonIgnoreUnknownKeys
@Serializable
internal data class ThongTinWebsite(
    val url: String,
    @SerialName("tham_so") val thamSo: Map<String, String>? = null
) {

    fun xayDungUrl(tuKhoa: String): Uri? {
        val choCanDien = "%TK%"
        try {
            val urlGoc = url.toUri()
            val builder = Uri.Builder()
            builder.scheme(urlGoc.scheme)
            builder.authority(urlGoc.authority)
            var path = urlGoc.path ?: ""
            if (path.contains(choCanDien)) {
                path.replace(choCanDien, URLEncoder.encode(tuKhoa, Charsets.UTF_8.name()))
            }
            builder.path(path)
            if (thamSo != null && thamSo.isNotEmpty()) {
                thamSo!!.forEach { khoa, giaTri ->
                    var gt = giaTri
                    if (gt.contains(choCanDien)) {
                        gt = gt.replace(choCanDien, tuKhoa)
                    }
                    builder.appendQueryParameter(khoa, gt)
                }
            }
            return builder.build()
        } catch (err: Exception) {
            return null
        }
    }
}

//class LangNgheMenuTimKiemAnh: BroadcastReceiver() {
//
//    override fun onReceive(context: Context?, intent: Intent?) {
//        Log.d("TIM ANH", "Broadcast $context $intent")
//        if (intent != null) {
//            BoTimKiemAnh.nhanDuocThaoTac(intent)
//        }
//    }
//
//}

object BoTimKiemAnh {

    private val dsWebsitesTimAnh = mutableListOf<ThongTinWebsite>()
    private var tuKhoa: String? = null
    private var khiXong: ((List<String>?) -> Unit)? = null
    private val soLuongMucThucDonToiDa = 7
    private val hanhDongMucThucDon = "sachcuat.timanh"
    private var sttWebsiteHienTai = 0
    private var intentChrome: CustomTabsIntent? = null
    private var dichVuChrome: ResolveInfo? = null
    private var chuyenDoiWebsite = false

    private fun napDanhSachWebsitesTuNguon(nguon: InputStream) {
        val duLieu = nguon.bufferedReader().use {
            it.readText()
        }
        val dsWeb: List<ThongTinWebsite> = Json.decodeFromString<List<ThongTinWebsite>>(duLieu)
        dsWebsitesTimAnh.addAll(dsWeb)
    }

    private fun napDanhSachWebsites() {
        // Đọc từ Flutter assets
        if (dsWebsitesTimAnh.isNotEmpty()) {
            return
        }
        val tep = File(BoQuanLyThuMuc.thuMucCSDL, "websites.json")
        if (tep.exists()) {
            try {
                val inputStream = tep.inputStream()
                napDanhSachWebsitesTuNguon(inputStream)
                inputStream.close()
            } catch (err: Exception) {
//                Log.d("DEBUG", "Khong doc duoc du lieu website tu dem $err")
            }
//            Log.d("DEBUG", "Nap DS web tu dem: ${dsWebsitesTimAnh.size}; ${dsWebsitesTimAnh.map { it.xayDungUrl("từ khoá thử nghiệm") }}")
        }

        // Đọc từ Flutter assets
        if (dsWebsitesTimAnh.isNotEmpty()) {
            return
        }
        val manHinhChinh = HeThongMay.duyNhat.manHinhChinh
        val assets = manHinhChinh.assets
        val khoa = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset("assets/websites.json")
        try {
            val inputStream = assets.open(khoa)
            napDanhSachWebsitesTuNguon(inputStream)
            inputStream.close()
        } catch (err: Exception) {
//            Log.d("DEBUG", "Khong doc duoc du lieu website tu asset $err")
        }
//        Log.d("DEBUG", "Nap DS web tu assets: ${dsWebsitesTimAnh.size}; ${dsWebsitesTimAnh.map { it.xayDungUrl("từ khoá thử nghiệm") }}")
    }

    fun nhanDuocThaoTac(intent: Intent): Boolean {
        if (dichVuChrome == null) { return false }
//        var mieuTa = ""
//        if (intent.extras != null) {
//            for (khoa in intent.extras!!.keySet()) {
//                mieuTa += "`${khoa}`:`${intent.extras!!.get(khoa)}`;\n"
//            }
//        }
//        Log.d("TIM ANH", "Nhan thao tac ${intent.action} ${intent.dataString} ${intent.extras?.get("stt")} ${intent.extras?.get("url")}\n$mieuTa")

        if (intent.action == hanhDongMucThucDon) {
            if (intent.hasExtra("stt")) {
                sttWebsiteHienTai = intent.getIntExtra("stt", 0)
                if (taoIntentChrome()) {
                    chuyenDoiWebsite = true
                }
            }
            return true
        } else {
            val kqChiaSe = BoXuLyDuLieuTrungGian.luuAnhChiaSe(intent)
            if (kqChiaSe != null) {
                khiXong?.invoke(listOf(kqChiaSe.path))
                khiXong = null
            }
        }
        return false
    }

    fun khiQuayLaiApp(): Boolean {
        if (dichVuChrome == null) { return false }
        if (chuyenDoiWebsite) {
            chuyenDoiWebsite = false
        } else {
            if (khiXong != null) {
                val xong = khiXong!!
                Handler(Looper.getMainLooper()).postDelayed({
                    BoXuLyDuLieuTrungGian.danUrlSach()
                    BoXuLyDuLieuTrungGian.danAnh() { kqDan ->
                        xong.invoke(kqDan)
                    }
                }, 500)
            }
            donDep()
        }
        return true
    }

    private fun donDep() {
        dichVuChrome = null
        khiXong = null
    }

    private fun timDichVu() {
        if (dichVuChrome != null) {
            return
        }
        val manHinhChinh = HeThongMay.duyNhat.manHinhChinh
        val dsDichVu = manHinhChinh.packageManager.queryIntentServices(Intent(CustomTabsService.ACTION_CUSTOM_TABS_CONNECTION), 0)
        for (muc in dsDichVu) {
            if (muc.serviceInfo.packageName.equals("com.android.chrome", true)) {
                dichVuChrome = muc
                return
            }
        }
    }

    private fun taoIntentChrome(): Boolean {
        if (dsWebsitesTimAnh.isEmpty()) {
            return false
        }
        timDichVu()
        if (dichVuChrome == null) {
            return false
        }
        val uri = dsWebsitesTimAnh[sttWebsiteHienTai].xayDungUrl(tuKhoa!!) ?: return false
        val manHinhChinh = HeThongMay.duyNhat.manHinhChinh
        val intentBuilder = CustomTabsIntent.Builder()
        intentBuilder.setShareState(SHARE_STATE_ON)
        intentBuilder.setShowTitle(true)

        var sttWeb = 0
        if (sttWebsiteHienTai > 0) {
            sttWeb = sttWebsiteHienTai - 1
        }
        var soLuongMenu = 0
        val slToiDa = min(soLuongMucThucDonToiDa, dsWebsitesTimAnh.size - 1) // -1 để loại trừ mục hiện tại
        while (soLuongMenu < slToiDa) {
            if (sttWeb == sttWebsiteHienTai) {
                sttWeb += 1
            }
            if (sttWeb >= dsWebsitesTimAnh.size) {
                sttWeb = 0
            }
            val mucWebsite = dsWebsitesTimAnh[sttWeb]
            val intentMenu = Intent(manHinhChinh, MainActivity::class.java)
            intentMenu.setAction(hanhDongMucThucDon)
            intentMenu.putExtra("stt", sttWeb)
//            intentMenu.putExtra("url", mucWebsite.url)
            val pendingIntent = PendingIntent.getActivity(
                manHinhChinh,
                sttWeb,
                intentMenu,
                PendingIntent.FLAG_IMMUTABLE
            )
            intentBuilder.addMenuItem(
                mucWebsite.url.toUri().host ?: mucWebsite.url,
                pendingIntent
            )
            sttWeb += 1
            soLuongMenu += 1
        }

        intentChrome = intentBuilder.build()
        intentChrome!!.intent.setPackage(dichVuChrome!!.serviceInfo.packageName)
        intentChrome!!.launchUrl(manHinhChinh, uri)
//        Log.d("TIM ANH", "Nap $uri")
        return true
    }

    fun batDau(tuKhoa: String, xong: (List<String>?) -> Unit): Boolean {
        napDanhSachWebsites()
        this.tuKhoa = tuKhoa
        this.khiXong = xong
        sttWebsiteHienTai = 0
        return taoIntentChrome()
    }

}
