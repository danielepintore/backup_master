//
//  PhotoView.swift
//  BackupMaster
//
//  Created by daniele on 07/12/24.
//

import SwiftUI
import Photos

struct PhotoView: View {
    let asset: PHAsset
    let imageSize: CGSize
    @State private var image: UIImage? = nil
    
    init(asset: PHAsset, imageSize: CGSize? = nil) {
        self.asset = asset
        self.imageSize = imageSize ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    //.border(Color.red, width: 2) // Adding a black border
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { (image, info) in
            self.image = image
        }
    }
}
