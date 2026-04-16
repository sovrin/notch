import SwiftUI

struct FileItemView: View {
    let file: ClipboardFile
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
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
                    Text(size)
                        .font(.caption2)
                }
            }

            Spacer()

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
            AppKitDragHandler(url: file.url, onDragSucceeded: onDelete)
        }
    }
}

#Preview {
    FileItemView(file: ClipboardFile(url: URL(fileURLWithPath: "/Users/test/Documents/example.swift"))) {}
        .frame(width: 300)
        .padding()
}
