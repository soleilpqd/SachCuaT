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

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        HeThongMay.register(flutterEngine, this)
    }

    fun hienThiManHinhCamera(kieu: KieuQuetMaCamera, maTraKetQua: Int) {
        val intent = Intent(this, ManHinhCamera::class.java)
        intent.putExtra("mode", kieu.giaTri)
        intent.putExtra("response", maTraKetQua)
        startActivity(intent)
    }

}
