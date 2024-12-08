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
    let columns: [GridItem] = [
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible()),
    ]
    @State private var isSheetPresented: Bool = false
    
    var body: some View {
        ScrollView {
            Text("\(album.assets.count) Elements")
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
                .padding()
            LazyVGrid(columns: columns, spacing: 5){
                ForEach(album.assets, id: \.self) { photo in
                    PhotoView(asset: photo)
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
                .animation(.bouncy, value: album.assets)
                //.border(Color.primary, width: 2) // Adding a black border}
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
