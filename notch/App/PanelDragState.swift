import Observation
import Foundation

@Observable
final class PanelDragState {
    var isDraggingOver = false
    var isGlobalDragging = false
    var pendingDrops: [URL] = []
    var pendingSnippets: [String] = []
    var contentHeight: CGFloat = 120

    @ObservationIgnored var onHeightChanged: ((CGFloat) -> Void)?
}
