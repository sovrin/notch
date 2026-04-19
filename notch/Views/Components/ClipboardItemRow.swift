import SwiftUI

struct ClipboardItemRow<Content: View>: View {
    let onDelete: () -> Void
    let dragOverlay: AnyView
    @ViewBuilder let content: () -> Content

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            content()
            Spacer()
            if isHovering {
                DeleteButtonView(action: onDelete)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
        .overlay { dragOverlay }
    }
}
