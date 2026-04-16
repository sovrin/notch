import SwiftUI

struct NotchContainer: View {
    var dragState: PanelDragState

    @State private var isHovering = false
    @State private var isDraggingLatch = false
    @State private var intendedHeight: CGFloat = 120
    @State private var collapseTask: Task<Void, Never>?

    private let minHeight: CGFloat = 80
    private let maxHeight: CGFloat = 400

    private var isExpanded: Bool {
        isHovering || dragState.isDraggingOver || isDraggingLatch
    }

    private func handleHover(_ inside: Bool) {
        collapseTask?.cancel()
        if inside {
            isHovering = true
        } else if !isDraggingLatch {
            collapseTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                isHovering = false
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ClipboardPanel(dragState: dragState)
                .opacity(isExpanded ? 1 : 0)
                .onHover { inside in
                    handleHover(inside)
                }

            LatchView(
                isExpanded: isExpanded,
                onDragChanged: { delta in
                    if !isDraggingLatch {
                        isDraggingLatch = true
                        intendedHeight = dragState.contentHeight
                        collapseTask?.cancel()
                    }
                    intendedHeight += delta
                    let newHeight = max(minHeight, min(maxHeight, intendedHeight))
                    withAnimation(nil) {
                        dragState.contentHeight = newHeight
                    }
                    dragState.onHeightChanged?(newHeight)
                },
                onDragEnded: {
                    isDraggingLatch = false
                    intendedHeight = dragState.contentHeight
                }
            )
            .onHover { inside in
                handleHover(inside)
            }
        }
        .offset(y: isExpanded ? 0 : -dragState.contentHeight)
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: isExpanded)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NotchContainer(dragState: PanelDragState())
        .frame(width: 320, height: 140)
        .padding()
        .background(.black)
}
