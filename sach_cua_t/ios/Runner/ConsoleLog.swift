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

import Foundation
import OSLog

#warning("This log will be not auto-disabled in release build")
/// Log to MacOS Console app or Flutter console
/// Notes:
/// - May use only in Development version.
/// - Log without XCode (that means logging without debugging)
/// - Be careful about what info will be logged (sensitive data).
/// - Available from iOS 14.0 and later.
/// - Use filter `SubSystem` with app Bundle ID or `Category` with `DevLog` in Console app.
/// - This log will be displayed in XCode console as well in Debug mode.
class ConsoleLog {

    static let shared = ConsoleLog()

    private let logger: Any?

    private init() {
        if #available(iOS 14.0, *) {
            logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ConsoleLog", category: "DevLog")
        } else {
            logger = nil
        }
    }

    func devLog(_ message: String, fnc: String = #function, fil: String = #file, lin: Int = #line) {
        let url = URL(fileURLWithPath: fil)
        if #available(iOS 14.0, *), let log = logger as? Logger {
            log.log("\(url.lastPathComponent, privacy: .public) [\(lin, privacy: .public)] \(fnc, privacy: .public):\n\(message, privacy: .public)")
        } else {
            print("\(url.lastPathComponent) [\(lin)] \(fnc):\n\(message)")
        }
    }

    func log(_ message: String) {
        if #available(iOS 14.0, *), let log = logger as? Logger {
            log.log("\(message, privacy: .public)")
        } else {
            print(message)
        }
    }

}
