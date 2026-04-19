import Observation
import Foundation

@Observable
final class PanelDragState {
    var isDraggingOver = false
    var isGlobalDragging = false
    var isDraggingLatch = false
    var pendingDrops: [URL] = []
    var pendingSnippets: [String] = []
    var contentHeight: CGFloat = 120
    var contentWidth: CGFloat = 320

    @ObservationIgnored var onHeightChanged: ((CGFloat) -> Void)?
    @ObservationIgnored var onWidthChanged: ((_ width: CGFloat, _ panelX: CGFloat) -> Void)?
}
