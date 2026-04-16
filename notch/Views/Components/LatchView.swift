import SwiftUI

/// A small pill-shaped handle that peeks below the notch panel.
/// Hovering it (or the panel) triggers the slide-down reveal.
struct LatchView: View {
    let isExpanded: Bool
    var onDragChanged: ((CGFloat) -> Void)?
    var onDragEnded: (() -> Void)?

    @State private var lastTranslation: CGFloat = 0

    var body: some View {
        Capsule()
            .fill(.white.opacity(isExpanded ? 0.5 : 0.25))
            .frame(width: isExpanded ? 48 : 36, height: 4)
            .shadow(color: .white.opacity(isExpanded ? 0.25 : 0), radius: 4, y: 1)
            .padding(.vertical, 5)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
            .gesture(
                DragGesture(minimumDistance: 2, coordinateSpace: .global)
                    .onChanged { value in
                        let delta = value.translation.height - lastTranslation
                        lastTranslation = value.translation.height
                        onDragChanged?(delta)
                    }
                    .onEnded { _ in
                        lastTranslation = 0
                        onDragEnded?()
                    }
            )
            .onHover { inside in
                if inside { NSCursor.resizeUpDown.push() } else { NSCursor.pop() }
            }
    }
}

#Preview {
    VStack(spacing: 8) {
        LatchView(isExpanded: false)
        LatchView(isExpanded: true)
    }
    .padding()
}
