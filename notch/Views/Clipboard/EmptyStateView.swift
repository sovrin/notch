import SwiftUI

struct EmptyStateView: View {
    let isTargeted: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: isTargeted ? "tray.and.arrow.down.fill" : "tray")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(isTargeted ? .primary : .secondary)
                .scaleEffect(isTargeted ? 1.15 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTargeted)

            Text("Drop files here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

#Preview("Empty") {
    EmptyStateView(isTargeted: false)
        .frame(width: 304, height: 104)
        .background(.ultraThinMaterial)
}

#Preview("Targeted") {
    EmptyStateView(isTargeted: true)
        .frame(width: 304, height: 104)
        .background(.ultraThinMaterial)
}
