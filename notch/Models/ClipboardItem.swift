import Foundation

enum ClipboardItem: Identifiable {
    case file(ClipboardFile)
    case snippet(ClipboardSnippet)

    var id: UUID {
        switch self {
        case .file(let f): return f.id
        case .snippet(let s): return s.id
        }
    }
}
