//
//  GalleryView.swift
//  BackupMaster
//
//  Created by daniele on 07/12/24.
//

import SwiftUI
import Photos

struct AlbumView: View {
    let albumName: String
    let photos: [PHAsset]
    
    let columns: [GridItem] = [
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible()),
    ]
    var body: some View {
        Text("\(photos.count)")
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5){
                ForEach(photos, id: \.self) { photo in
                    PhotoView(asset: photo)
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
                //.border(Color.primary, width: 2) // Adding a black border}
            }
            .navigationTitle(albumName)
        }
    }
}
