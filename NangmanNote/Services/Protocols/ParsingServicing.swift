import Foundation

protocol ParsingServicing: Sendable {
    func parse(ocrText: String) async throws -> ParsedCupNoteCard
}
