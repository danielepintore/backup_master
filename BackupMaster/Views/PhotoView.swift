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
    @State private var image: UIImage? = nil
    
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
        let scaleFactor = 18;
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth/scaleFactor, height: asset.pixelHeight/scaleFactor), contentMode: .aspectFill, options: options) { (image, info) in
            self.image = image
        }
    }
}
