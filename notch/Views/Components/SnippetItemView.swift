import SwiftUI

struct SnippetItemView: View {
    let snippet: ClipboardSnippet
    let onDelete: () -> Void

    var body: some View {
        ClipboardItemRow(
            onDelete: onDelete,
            dragOverlay: AnyView(AppKitDragHandler(payload: .text(snippet.text), onDragSucceeded: onDelete))
        ) {
            Image(systemName: "text.document")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
            Text(snippet.text)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SnippetItemView(snippet: ClipboardSnippet(text: "Hello, world! This is a sample text snippet.")) {}
        .frame(width: 300)
        .padding()
}
