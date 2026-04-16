import Foundation

struct ClipboardFile: Identifiable {
    let id = UUID()
    let url: URL

    var name: String {
        url.lastPathComponent
    }

    var childrenCount: Int? {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue else { return nil }
        
        return try? FileManager.default.contentsOfDirectory(atPath: url.path).count
    }

    var formattedSize: String? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return nil }
        
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
