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
    // qualityFactor is a multiplier applied to image size when retieving the image for the display in the view
    let qualityFactor: Double
    @State private var image: UIImage? = nil
    
    init(asset: PHAsset, imageSize: CGSize? = nil, qualityFactor: Double = 1) {
        self.asset = asset
        self.imageSize = imageSize ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        self.qualityFactor = qualityFactor
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
        options.deliveryMode = .opportunistic
        options.version = .current
        // New target size to improve quality
        let improvedImageSize = CGSize(width: imageSize.width * self.qualityFactor, height: imageSize.height * self.qualityFactor)
        PHImageManager.default().requestImage(for: asset, targetSize: improvedImageSize, contentMode: .aspectFill, options: options) { (image, info) in
            self.image = image
        }
    }
}
