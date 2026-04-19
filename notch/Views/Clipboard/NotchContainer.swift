import SwiftUI

struct NotchContainer: View {
    var dragState: PanelDragState

    @State private var isHovering = false
    @State private var collapseTask: Task<Void, Never>?

    private let peekAmount: CGFloat = 20

    private enum ExpandState: Equatable {
        case collapsed, peeking, expanded
    }

    private var expandState: ExpandState {
        if isHovering || dragState.isDraggingOver || dragState.isDraggingLatch { return .expanded }
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
        } else if !dragState.isDraggingLatch {
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
                .onHover { handleHover($0) }

            LatchView(isExpanded: expandState != .collapsed)
                .onHover { handleHover($0) }
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
