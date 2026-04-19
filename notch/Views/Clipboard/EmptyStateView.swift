import SwiftUI

struct EmptyStateView: View {
    let isTargeted: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: isTargeted ? "arrow.down.to.line.circle.fill" : "arrow.down.to.line.circle")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary)
                .animation(.easeInOut(duration: 0.25), value: isTargeted)

            Text(isTargeted ? "Release to drop" : "Drop files or text")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if isTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.06))
                    .padding(4)
                    .transition(.opacity)
            }
        }
        .overlay {
            if isTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor.opacity(0.4), lineWidth: 1)
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
