import AppKit
import Foundation
import UniformTypeIdentifiers

/// Handles all drag-and-drop at the window level so SwiftUI subviews don't
/// register competing NSDraggingDestinations (which would cause draggingExited
/// to fire on this panel whenever the cursor moved over a child drop zone,
/// producing the expand/collapse oscillation bug).
final class DragAwarePanel: NSPanel, NSDraggingDestination {
    var onDragEntered: (() -> Void)?
    var onDragExited: (() -> Void)?
    var onFilesDropped: (([URL]) -> Void)?
    var onTextDropped: ((String) -> Void)?

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        registerForDraggedTypes([.fileURL, .string])
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pb = sender.draggingPasteboard
        let acceptsFiles = pb.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true])
        let acceptsText = pb.availableType(from: [.string]) != nil
        guard acceptsFiles || acceptsText else { return [] }
        onDragEntered?()
        
        return .copy
    }

    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    func draggingExited(_ sender: NSDraggingInfo?) {
        onDragExited?()
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pb = sender.draggingPasteboard

        if let urls = pb.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
           !urls.isEmpty {
            onFilesDropped?(urls)
            
            return true
        }

        if let text = pb.string(forType: .string), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onTextDropped?(text)
            
            return true
        }

        return false
    }

    func draggingEnded(_ sender: NSDraggingInfo) {
        onDragExited?()
    }
}
