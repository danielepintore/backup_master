//
//  GalleryView.swift
//  BackupMaster
//
//  Created by daniele on 07/12/24.
//

import SwiftUI
import Photos

struct AlbumView: View {
    let album: Album
    let columnsCount: Int
    let spacingPercentage: Int
    @State private var isSheetPresented: Bool = false
    
    init(album: Album, columns: Int = 4, spacingPercentage: Int = 2) {
        self.album = album
        self.columnsCount = columns
        self.spacingPercentage = spacingPercentage
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text("\(album.assets.count) Elements")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                    .padding()
                let spacingFactor = Double(spacingPercentage) / 100
                // Calculates the image width and height (aspect ratio 1:1)
                let imageWidthHeight = (geometry.size.width - (geometry.size.width * spacingFactor)) / CGFloat(columnsCount)
                let imageSize = CGSize(width: imageWidthHeight, height: imageWidthHeight)
                let spacing = geometry.size.width * spacingFactor / CGFloat(columnsCount)
                let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 50), spacing: 0), count: columnsCount)
                LazyVGrid(columns: columns, spacing: spacing){
                    ForEach(album.assets, id: \.self) { photo in
                        PhotoView(asset: photo, imageSize: imageSize, qualityFactor: 1.5)
                            .scaledToFill()
                            .frame(width: imageSize.width, height: imageSize.height)
                            .clipped()
                        //.border(Color.red, width: 2) // Adding a black border
                    }
                    .animation(.bouncy, value: album.assets)
                    //.border(Color.primary, width: 2) // Adding a black border}
                }
            }
            .navigationTitle(album.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isSheetPresented.toggle()
                    }) {
                        Image(systemName: "icloud.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented, content: {
                UploadSheet()
                    .presentationDetents([.fraction(0.4)])
            })
        }
    }
}

struct UploadSheet: View {
    var photoCount = 23
    var services = ["WebDAV", "FTP", "SMB", "BackBlaze"]
    @State private var selectedService: String = "WebDav"
    var body: some View {
        VStack {
            Text("Upload Photos and Videos")
                .font(.title2)
                .bold()
                .frame(width: .infinity, alignment: .leading)
                .padding()
            VStack(alignment: .leading) {
                Text("Photos and video selected: \(photoCount)")
                Text("Upload size: \(photoCount)GB")
            }
            .frame(alignment: .leading)
            .padding()
            Spacer()
            HStack {
                Text("Upload to: ")
                Menu(selectedService) {
                    ForEach(services, id: \.self) { service in
                        Button(service, action: {
                            selectedService = service
                        })
                    }
                }
                .padding()
            }
            Spacer()
            Button("Start Upload") {
                
            }
            .buttonStyle(BorderedButtonStyle.bordered)
            .frame(width: .infinity)
        }
        .frame(width: .infinity)
    }
}

#Preview {
    UploadSheet() 
}
