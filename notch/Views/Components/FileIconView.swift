import SwiftUI
import AppKit

struct FileIconView: View {
    let url: URL

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
}

#Preview {
    FileIconView(url: URL(fileURLWithPath: "/Applications/Safari.app"))
        .padding()
}
