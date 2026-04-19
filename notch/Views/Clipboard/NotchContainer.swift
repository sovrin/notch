import SwiftUI

struct NotchContainer: View {
    var dragState: PanelDragState

    @State private var isHovering = false
    @State private var isDraggingLatch = false
    @State private var intendedHeight: CGFloat = 120
    @State private var collapseTask: Task<Void, Never>?

    private let minHeight: CGFloat = 80
    private let maxHeight: CGFloat = 400
    private let peekAmount: CGFloat = 20

    private enum ExpandState: Equatable {
        case collapsed, peeking, expanded
    }

    private var expandState: ExpandState {
        if isHovering || dragState.isDraggingOver || isDraggingLatch { return .expanded }
        if dragState.isGlobalDragging { return .peeking }
        return .collapsed
    }

    private var revealOffset: CGFloat {
        switch expandState {
        case .expanded:  return 0
        case .peeking:   return -(dragState.contentHeight - peekAmount)
        case .collapsed: return -dragState.contentHeight
        }
    }

    private var contentOpacity: Double {
        switch expandState {
        case .expanded:  return 1
        case .peeking:   return 0.7
        case .collapsed: return 0
        }
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
                .opacity(contentOpacity)
                .onHover { inside in
                    handleHover(inside)
                }

            LatchView(
                isExpanded: expandState != .collapsed,
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
        .offset(y: revealOffset)
        .animation(.easeInOut(duration: 0.3), value: expandState)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NotchContainer(dragState: PanelDragState())
        .frame(width: 320, height: 140)
        .padding()
        .background(.black)
}
