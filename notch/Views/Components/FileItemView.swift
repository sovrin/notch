import SwiftUI

struct FileItemView: View {
    let file: ClipboardFile
    let onDelete: () -> Void

    var body: some View {
        ClipboardItemRow(
            onDelete: onDelete,
            dragOverlay: AnyView(AppKitDragHandler(payload: .file(file.url), onDragSucceeded: onDelete))
        ) {
            if file.isImage {
                ImageThumbnailView(url: file.url)
            } else {
                FileIconView(url: file.url)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(file.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .onTapGesture(count: 2) {
            NSWorkspace.shared.open(file.url)
        }
    }
}

#Preview {
    FileItemView(file: ClipboardFile(url: URL(fileURLWithPath: "/Users/test/Documents/example.swift"))) {}
        .frame(width: 300)
        .padding()
}
