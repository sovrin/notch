import AppKit
import SwiftUI

enum DragPayload {
    case file(URL)
    case text(String)
}

/// Invisible overlay that initiates an AppKit drag session and reports
/// the outcome via `onDragSucceeded`. Uses `hitTest → nil` so SwiftUI's
/// own hover/click handling is fully unaffected.
struct AppKitDragHandler: NSViewRepresentable {
    let payload: DragPayload
    let onDragSucceeded: () -> Void

    func makeNSView(context: Context) -> DragHandlerView {
        DragHandlerView(payload: payload, onDragSucceeded: onDragSucceeded)
    }

    func updateNSView(_ nsView: DragHandlerView, context: Context) {
        nsView.payload = payload
        nsView.onDragSucceeded = onDragSucceeded
    }
}

final class DragHandlerView: NSView, NSDraggingSource {
    var payload: DragPayload
    var onDragSucceeded: () -> Void

    private var eventMonitor: Any?
    private var dragStartLocation: NSPoint?
    private var isDragging = false

    private static let dragThreshold: CGFloat = 3
    private static let dragIconSize = CGSize(width: 32, height: 32)

    init(payload: DragPayload, onDragSucceeded: @escaping () -> Void) {
        self.payload = payload
        self.onDragSucceeded = onDragSucceeded
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        removeMonitor()
        guard window != nil else { return }
        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        ) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { removeMonitor() }
        super.viewWillMove(toWindow: newWindow)
    }

    private func removeMonitor() {
        if let m = eventMonitor { NSEvent.removeMonitor(m) }
        eventMonitor = nil
    }

    private func handle(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            let pt = convert(event.locationInWindow, from: nil)
            if bounds.contains(pt) { dragStartLocation = event.locationInWindow }

        case .leftMouseDragged:
            guard let start = dragStartLocation, !isDragging else { return }
            let cur = event.locationInWindow
            let d = hypot(cur.x - start.x, cur.y - start.y)
            guard d > Self.dragThreshold else { return }
            isDragging = true
            dragStartLocation = nil
            startDrag(with: event)

        case .leftMouseUp:
            dragStartLocation = nil

        default:
            break
        }
    }

    private func startDrag(with event: NSEvent) {
        let size = Self.dragIconSize
        let loc = convert(event.locationInWindow, from: nil)
        let frame = CGRect(
            x: loc.x - size.width / 2,
            y: loc.y - size.height / 2,
            width: size.width,
            height: size.height
        )

        let item: NSDraggingItem
        let icon: NSImage
        switch payload {
        case .file(let url):
            item = NSDraggingItem(pasteboardWriter: url as NSURL)
            icon = NSWorkspace.shared.icon(forFile: url.path)
        case .text(let text):
            item = NSDraggingItem(pasteboardWriter: text as NSString)
            icon = NSImage(systemSymbolName: "text.quote", accessibilityDescription: nil)
                ?? NSImage(size: NSSize(width: size.width, height: size.height))
        }
        item.setDraggingFrame(frame, contents: icon)
        beginDraggingSession(with: [item], event: event, source: self)
    }

    // MARK: NSDraggingSource

    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        switch payload {
        case .file: return [.copy, .move, .link]
        case .text: return [.copy, .move]
        }
    }

    func draggingSession(
        _ session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        isDragging = false
        guard !operation.isEmpty else { return }
        DispatchQueue.main.async { self.onDragSucceeded() }
    }
}
