import SwiftUI

struct ClipboardPanel: View {
    var dragState: PanelDragState

    @State private var items: [ClipboardItem] = []
    @State private var intendedHeight: CGFloat = 120
    @State private var heightDragOffset: CGFloat = 0
    // width resize — anchored to screen coords at drag start
    @State private var widthDragStartCursorX: CGFloat = 0
    @State private var widthDragStartWidth: CGFloat = 320
    @State private var widthDragFixedEdgeX: CGFloat = 0  // screen X of the edge that stays put

    private let minHeight: CGFloat = 80
    private let maxHeight: CGFloat = 400
    private let minWidth: CGFloat = 240
    private let maxWidth: CGFloat = 700

    var body: some View {
        GlassEffectContainer {
            DropZoneView(
                items: items,
                isTargeted: dragState.isDraggingOver,
                onDelete: { item in
                    withAnimation {
                        items.removeAll { $0.id == item.id }
                    }
                }
            )
            .background(.ultraThinMaterial)
        }
        .frame(width: dragState.contentWidth, height: dragState.contentHeight)
        .clipShape(SeamlessTopShape(bottomRadius: 16))
        .padding(8)
        .overlay(alignment: .bottom) {
            Color.clear
                .frame(height: 10)
                .contentShape(Rectangle())
                .onHover { inside in
                    if inside { NSCursor.resizeUpDown.push() } else { NSCursor.pop() }
                }
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .global)
                        .onChanged { value in
                            if !dragState.isDraggingLatch {
                                dragState.isDraggingLatch = true
                                intendedHeight = dragState.contentHeight
                                heightDragOffset = 0
                            }
                            let delta = value.translation.height - heightDragOffset
                            heightDragOffset = value.translation.height
                            intendedHeight += delta
                            let newHeight = max(minHeight, min(maxHeight, intendedHeight))
                            withAnimation(nil) { dragState.contentHeight = newHeight }
                            dragState.onHeightChanged?(newHeight)
                        }
                        .onEnded { _ in
                            heightDragOffset = 0
                            dragState.isDraggingLatch = false
                            intendedHeight = dragState.contentHeight
                        }
                )
        }
        .overlay(alignment: .trailing) {
            Color.clear
                .frame(width: 10)
                .contentShape(Rectangle())
                .onHover { inside in
                    if inside { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
                }
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .global)
                        .onChanged { _ in
                            let cursorX = NSEvent.mouseLocation.x
                            if !dragState.isDraggingLatch {
                                dragState.isDraggingLatch = true
                                widthDragStartCursorX = cursorX
                                widthDragStartWidth = dragState.contentWidth
                                // fix the LEFT edge in screen space
                                if let screen = NSScreen.main {
                                    widthDragFixedEdgeX = screen.frame.midX - dragState.contentWidth / 2
                                }
                            }
                            let delta = cursorX - widthDragStartCursorX
                            let newWidth = max(minWidth, min(maxWidth, widthDragStartWidth + delta))
                            withAnimation(nil) { dragState.contentWidth = newWidth }
                            dragState.onWidthChanged?(newWidth, widthDragFixedEdgeX)
                        }
                        .onEnded { _ in
                            dragState.isDraggingLatch = false
                            if let screen = NSScreen.main {
                                let centeredX = screen.frame.midX - dragState.contentWidth / 2
                                dragState.onWidthChanged?(dragState.contentWidth, centeredX)
                            }
                        }
                )
        }
        .overlay(alignment: .leading) {
            Color.clear
                .frame(width: 10)
                .contentShape(Rectangle())
                .onHover { inside in
                    if inside { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
                }
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .global)
                        .onChanged { _ in
                            let cursorX = NSEvent.mouseLocation.x
                            if !dragState.isDraggingLatch {
                                dragState.isDraggingLatch = true
                                widthDragStartCursorX = cursorX
                                widthDragStartWidth = dragState.contentWidth
                                // fix the RIGHT edge in screen space
                                if let screen = NSScreen.main {
                                    widthDragFixedEdgeX = screen.frame.midX + dragState.contentWidth / 2
                                }
                            }
                            let delta = widthDragStartCursorX - cursorX
                            let newWidth = max(minWidth, min(maxWidth, widthDragStartWidth + delta))
                            let newPanelX = widthDragFixedEdgeX - newWidth  // right edge stays fixed
                            withAnimation(nil) { dragState.contentWidth = newWidth }
                            dragState.onWidthChanged?(newWidth, newPanelX)
                        }
                        .onEnded { _ in
                            dragState.isDraggingLatch = false
                            if let screen = NSScreen.main {
                                let centeredX = screen.frame.midX - dragState.contentWidth / 2
                                dragState.onWidthChanged?(dragState.contentWidth, centeredX)
                            }
                        }
                )
        }
        .onChange(of: dragState.pendingDrops) { _, newDrops in
            guard !newDrops.isEmpty else { return }
            for url in newDrops {
                let file = ClipboardFile(url: url)
                items.removeAll { if case .file(let f) = $0 { return f.url == file.url } ; return false }
                items.append(.file(file))
            }
            dragState.pendingDrops.removeAll()
        }
        .onChange(of: dragState.pendingSnippets) { _, newSnippets in
            guard !newSnippets.isEmpty else { return }
            for text in newSnippets {
                items.append(.snippet(ClipboardSnippet(text: text)))
            }
            dragState.pendingSnippets.removeAll()
        }
    }
}

#Preview("Empty") {
    ClipboardPanel(dragState: PanelDragState())
}

#Preview("With files") {
    let state = PanelDragState()
    let panel = ClipboardPanel(dragState: state)
    return panel
        .onAppear {
            state.pendingDrops = [
                URL(fileURLWithPath: "/Users/test/Documents/report.pdf"),
                URL(fileURLWithPath: "/Users/test/Desktop/photo.png"),
                URL(fileURLWithPath: "/Users/test/Downloads/archive.zip"),
            ]
        }
}
