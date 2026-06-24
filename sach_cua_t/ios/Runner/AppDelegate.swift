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

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    static var app: AppDelegate { UIApplication.shared.delegate! as! AppDelegate }
    var rootViewController: FlutterViewController? {
        for schene in UIApplication.shared.connectedScenes {
            if let winSchene = schene as? UIWindowScene {
               for win in winSchene.windows {
                   if let root = win.rootViewController as? FlutterViewController {
                       return root
                   }
               }
            }
        }
        return nil
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UINavigationBar.appearance().backgroundColor = .blue
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: any FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        HeThongMay.register(with: engineBridge.applicationRegistrar.messenger())
    }

}

final class SceneDelegate: FlutterSceneDelegate {

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let dsDuongDan = URLContexts.map({ $0.url.path });
        HeThongMay.duyNhat.nhanDuocTep(dsDuongDan: dsDuongDan)
    }

}
