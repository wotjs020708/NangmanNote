import Foundation
import OSLog

extension Logger {
    private static let appSubsystem = "com.jaesuneo.NangmanNote"

    nonisolated static let parsing = Logger(subsystem: appSubsystem, category: "parsing")
    nonisolated static let ocr = Logger(subsystem: appSubsystem, category: "ocr")
    nonisolated static let cardStore = Logger(subsystem: appSubsystem, category: "cardStore")
    nonisolated static let ui = Logger(subsystem: appSubsystem, category: "ui")
}
