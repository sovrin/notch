import SwiftUI

struct ClipboardPanel: View {
    var dragState: PanelDragState

    @State private var items: [ClipboardItem] = []

    var body: some View {
        GlassEffectContainer {
            DropZoneView(
                isEmpty: items.isEmpty,
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
        .frame(width: 320, height: dragState.contentHeight)
        .clipShape(SeamlessTopShape(bottomRadius: 16))
        .padding(8)
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
