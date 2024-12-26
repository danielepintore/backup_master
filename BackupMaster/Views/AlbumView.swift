//
//  GalleryView.swift
//  BackupMaster
//
//  Created by daniele on 07/12/24.
//

import SwiftUI
import Photos

struct AlbumView: View {
    let columnsCount: Int
    let spacingPercentage: Int
    @State private var viewModel: AlbumView.ViewModel
    
    init(album: Album, columns: Int = 4, spacingPercentage: Int = 2) {
        self.viewModel = ViewModel(album: album)
        self.columnsCount = columns
        self.spacingPercentage = spacingPercentage
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text("\(viewModel.album.assets.count) Elements")
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
                    ForEach(viewModel.album.assets, id: \.self) { asset in
                        ZStack(alignment: .bottomLeading) {
                            PhotoView(asset: asset, imageSize: imageSize, qualityFactor: 1.5)
                            if (viewModel.isSelectionActive && viewModel.selection.contains(asset)) {
                                Rectangle()
                                    .frame(width: imageSize.width, height: imageSize.height)
                                    .foregroundStyle(Color.white.opacity(0.4))
                                    .animation(.default, value: viewModel.selection)
                                    .zIndex(1) // Animation fix
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                    .padding(1)
                                    .foregroundStyle(Color.accentColor)
                                    .background(Color.white, in: Circle())
                                    .padding(5)
                                    .zIndex(1) // Animation fix
                            }
                        }
                        .animation(.default, value: viewModel.selection)
                        .animation(.default, value: viewModel.isSelectionActive)
//                        .border(Color.red, width: 2) // Adding a black border
                        .onTapGesture {
                            viewModel.toggleAssetSelection(for: asset)
                        }
                    }
                    .animation(.bouncy, value: viewModel.album.assets)
                    //.border(Color.primary, width: 2) // Adding a black border}
                }
            }
            .navigationTitle(viewModel.album.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        //                        isSheetPresented.toggle()
                    }) {
                        Image(systemName: "icloud.and.arrow.up")
                    }
                }
            }
            .overlay(alignment: .topTrailing, content: {
                Button {
                    viewModel.isSelectionActive.toggle()
                } label: {
                    Text(viewModel.isSelectionActive ? "Done": "Select")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(Color.primary)
                        .background(.regularMaterial, in: Capsule())
                }
                .padding()
                .animation(.default, value: viewModel.isSelectionActive)
            })
            //            .sheet(isPresented: $isSheetPresented, content: {
            //                UploadSheet()
            //                    .presentationDetents([.fraction(0.4)])
            //            })
        }
    }
}

//struct UploadSheet: View {
//    var photoCount = 23
//    var services = ["WebDAV", "FTP", "SMB", "BackBlaze"]
//    @State private var selectedService: String = "WebDav"
//    var body: some View {
//        VStack {
//            Text("Upload Photos and Videos")
//                .font(.title2)
//                .bold()
//                .frame(width: .infinity, alignment: .leading)
//                .padding()
//            VStack(alignment: .leading) {
//                Text("Photos and video selected: \(photoCount)")
//                Text("Upload size: \(photoCount)GB")
//            }
//            .frame(alignment: .leading)
//            .padding()
//            Spacer()
//            HStack {
//                Text("Upload to: ")
//                Menu(selectedService) {
//                    ForEach(services, id: \.self) { service in
//                        Button(service, action: {
//                            selectedService = service
//                        })
//                    }
//                }
//                .padding()
//            }
//            Spacer()
//            Button("Start Upload") {
//
//            }
//            .buttonStyle(BorderedButtonStyle.bordered)
//            .frame(width: .infinity)
//        }
//        .frame(width: .infinity)
//    }
//}

//#Preview {
//    UploadSheet()
//}
