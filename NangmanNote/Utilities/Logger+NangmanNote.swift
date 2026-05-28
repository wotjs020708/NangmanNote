import Foundation
import OSLog

extension Logger {
    private static let appSubsystem = Bundle.main.bundleIdentifier ?? "com.nangman.note"

    static let parsing = Logger(subsystem: Self.appSubsystem, category: "parsing")
    static let ocr = Logger(subsystem: Self.appSubsystem, category: "ocr")
    static let cardStore = Logger(subsystem: Self.appSubsystem, category: "cardStore")
    static let ui = Logger(subsystem: Self.appSubsystem, category: "ui")
}
