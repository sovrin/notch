import SwiftUI

struct DropZoneView: View {
    let items: [ClipboardItem]
    let isTargeted: Bool
    let onDelete: (ClipboardItem) -> Void

    var body: some View {
        if items.isEmpty {
            EmptyStateView(isTargeted: isTargeted)
        } else {
            ItemsListView(items: items, isTargeted: isTargeted, onDelete: onDelete)
        }
    }
}

#Preview("Empty") {
    DropZoneView(items: [], isTargeted: false, onDelete: { _ in })
        .frame(width: 304, height: 104)
        .background(.ultraThinMaterial)
        .padding()
}

#Preview("With items") {
    DropZoneView(
        items: [
            .file(ClipboardFile(url: URL(fileURLWithPath: "/Users/test/Documents/report.pdf"))),
            .snippet(ClipboardSnippet(text: "Hello, world!")),
        ],
        isTargeted: false,
        onDelete: { _ in }
    )
    .frame(width: 304, height: 104)
    .padding()
}
