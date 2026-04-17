import SwiftUI

struct FileItemView: View {
    let file: ClipboardFile
    let onDelete: () -> Void

    var body: some View {
        ClipboardItemRow(
            onDelete: onDelete,
            dragOverlay: AnyView(AppKitDragHandler(payload: .file(file.url), onDragSucceeded: onDelete))
        ) {
            FileIconView(url: file.url)
            VStack(alignment: .leading, spacing: 1) {
                Text(file.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let count = file.childrenCount {
                    Text("\(count) item\(count == 1 ? "" : "s")")
                        .font(.caption2)
                } else if let size = file.formattedSize {
                    Text(size).font(.caption2)
                }
            }
        }
    }
}

#Preview {
    FileItemView(file: ClipboardFile(url: URL(fileURLWithPath: "/Users/test/Documents/example.swift"))) {}
        .frame(width: 300)
        .padding()
}
