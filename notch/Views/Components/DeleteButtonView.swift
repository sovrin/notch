import SwiftUI

struct DeleteButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DeleteButtonView(action: {})
        .padding()
}
