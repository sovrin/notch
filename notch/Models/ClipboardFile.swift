import Foundation
import UniformTypeIdentifiers
import ImageIO

struct ClipboardFile: Identifiable {
    let id = UUID()
    let url: URL

    var name: String { url.lastPathComponent }

    var fileType: UTType? { UTType(filenameExtension: url.pathExtension) }

    var isImage: Bool { fileType?.conforms(to: .image) ?? false }

    var fileKind: String? { fileType?.localizedDescription }

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

    var modificationDate: Date? {
        (try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date
    }

    var imageDimensions: CGSize? {
        guard isImage,
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let w = props[kCGImagePropertyPixelWidth] as? Int,
              let h = props[kCGImagePropertyPixelHeight] as? Int
        else { return nil }
        return CGSize(width: w, height: h)
    }

    var subtitle: String {
        var parts: [String] = []
        if let count = childrenCount {
            parts.append("\(count) item\(count == 1 ? "" : "s")")
        } else {
            if let dims = imageDimensions {
                parts.append("\(Int(dims.width)) × \(Int(dims.height))")
            } else if let kind = fileKind {
                parts.append(kind)
            }
            if let size = formattedSize { parts.append(size) }
        }
        if let date = modificationDate { parts.append(date.relativeFormatted) }
        return parts.joined(separator: " · ")
    }
}
