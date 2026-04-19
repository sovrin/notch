import SwiftUI

/// Visual-only pill that peeks below the notch to signal the panel is there.
struct LatchView: View {
    let isExpanded: Bool

    var body: some View {
        Capsule()
            .fill(.white.opacity(isExpanded ? 0.5 : 0.25))
            .frame(width: isExpanded ? 48 : 36, height: 4)
            .shadow(color: .white.opacity(isExpanded ? 0.25 : 0), radius: 4, y: 1)
            .padding(.vertical, 5)
            .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

#Preview {
    VStack(spacing: 8) {
        LatchView(isExpanded: false)
        LatchView(isExpanded: true)
    }
    .padding()
}
