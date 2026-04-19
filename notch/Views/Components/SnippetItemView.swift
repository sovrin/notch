import SwiftUI

struct SnippetItemView: View {
    let snippet: ClipboardSnippet
    let onDelete: () -> Void

    var body: some View {
        ClipboardItemRow(
            onDelete: onDelete,
            dragOverlay: AnyView(AppKitDragHandler(payload: .text(snippet.text), onDragSucceeded: onDelete))
        ) {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.primary.opacity(0.08))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            Text(snippet.text)
                .font(.system(size: 12))
                .lineLimit(2)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SnippetItemView(snippet: ClipboardSnippet(text: "Hello, world! This is a sample text snippet.")) {}
        .frame(width: 300)
        .padding()
}
