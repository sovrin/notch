import SwiftUI

struct ItemsListView: View {
    let items: [ClipboardItem]
    let isTargeted: Bool
    let onDelete: (ClipboardItem) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(items) { item in
                    switch item {
                    case .file(let file):
                        FileItemView(file: file) { onDelete(item) }
                    case .snippet(let snippet):
                        SnippetItemView(snippet: snippet) { onDelete(item) }
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if isTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                    .padding(4)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isTargeted)
    }
}

#Preview {
    ItemsListView(
        items: [
            .file(ClipboardFile(url: URL(fileURLWithPath: "/Users/test/Documents/report.pdf"))),
            .snippet(ClipboardSnippet(text: "Some selected text from a webpage or document.")),
            .file(ClipboardFile(url: URL(fileURLWithPath: "/Users/test/Downloads/archive.zip"))),
        ],
        isTargeted: false,
        onDelete: { _ in }
    )
    .frame(width: 304, height: 104)
    .background(.ultraThinMaterial)
}
