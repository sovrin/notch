//
//  ImageThumbnailView.swift
//  notch
//
//  Created by sovrin on 19.04.26.
//

import SwiftUI

struct ImageThumbnailView: View {
    let url: URL
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .task(id: url) {
            image = await Task.detached(priority: .utility) {
                NSImage(contentsOf: url)
            }.value
        }
    }
}
