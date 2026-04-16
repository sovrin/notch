import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: DragAwarePanel?
    private let dragState = PanelDragState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        setupMenu()
    }

    private func setupPanel() {
        // NotchContainer height:
        //   136 pt — ClipboardPanel (120 frame + 8 padding top/bottom)
        //    14 pt — LatchView (4pt pill + 5pt padding × 2)
        // Total: 150 pt
        //
        // The panel is pinned flush to the top of the screen.
        // NotchContainer offsets itself upward by 136 pt when collapsed,
        // so only the 14 pt latch protrudes below the physical notch bar.
        let panelContent = NotchContainer(dragState: dragState)

        let dragPanel = DragAwarePanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 150),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        dragPanel.onDragEntered  = { [weak self] in self?.dragState.isDraggingOver = true }
        dragPanel.onDragExited   = { [weak self] in self?.dragState.isDraggingOver = false }
        dragPanel.onFilesDropped = { [weak self] urls in self?.dragState.pendingDrops.append(contentsOf: urls) }
        dragPanel.onTextDropped  = { [weak self] text in self?.dragState.pendingSnippets.append(text) }
        dragState.onHeightChanged = { [weak self] newHeight in
            self?.resizePanel(contentHeight: newHeight)
        }
        panel = dragPanel

        guard let panel = panel else { return }

        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true

        panel.contentView = NSHostingView(rootView: panelContent)

        positionPanelBelowNotch()
        panel.orderFrontRegardless()
    }

    private func positionPanelBelowNotch() {
        guard let panel = panel, let screen = NSScreen.main else { return }

        let panelX = screen.frame.midX - 160
        let panelY = screen.frame.maxY - 140

        panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
    }

    // Keep panel top edge fixed; grow downward as contentHeight increases.
    // Panel height = contentHeight + 16 (padding) + 14 (latch) = contentHeight + 30
    // Panel top = screen.frame.maxY + 10 (constant)
    // Panel originY = top - newHeight = screen.frame.maxY - 20 - contentHeight
    private func resizePanel(contentHeight: CGFloat) {
        guard let panel = panel, let screen = NSScreen.main else { return }
        let newHeight = contentHeight + 30
        let panelX = screen.frame.midX - 160
        let panelY = screen.frame.maxY - 20 - contentHeight
        panel.setFrame(NSRect(x: panelX, y: panelY, width: 320, height: newHeight), display: true, animate: false)
    }

    private func setupMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        appMenu.addItem(withTitle: "Show/Hide", action: #selector(togglePanel), keyEquivalent: "h")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc private func togglePanel() {
        panel?.orderFrontRegardless()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
