import SwiftUI

struct SnippetItemView: View {
    let snippet: ClipboardSnippet
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "text.document")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)

            Text(snippet.text)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isHovering {
                DeleteButtonView(action: onDelete)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color.primary.opacity(0.07) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
        .overlay {
            AppKitTextDragHandler(text: snippet.text, onDragSucceeded: onDelete)
        }
    }
}

#Preview {
    SnippetItemView(snippet: ClipboardSnippet(text: "Hello, world! This is a sample text snippet.")) {}
        .frame(width: 300)
        .padding()
}
