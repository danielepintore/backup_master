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
    @ObservedObject private var viewModel: AlbumView.ViewModel
    @ObservedObject private(set) var backupServiceManager: BackupServiceManager
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var properties: SelectionProperties = .init()
    
    init(album: Album, backupServiceManager: BackupServiceManager, columns: Int = 4, spacingPercentage: Int = 2) {
        self.viewModel = ViewModel(album: album)
        self.backupServiceManager = backupServiceManager
        self.columnsCount = columns
        self.spacingPercentage = spacingPercentage
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text("\(viewModel.assetsCount) Elements")
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
                    ForEach($viewModel.assets, id: \.asset.localIdentifier) { $assetVM in
                        ZStack(alignment: .bottomLeading) {
                            PhotoView(asset: assetVM.asset, imageSize: imageSize, qualityFactor: 1.5)
                            if (viewModel.isSelectionActive && assetVM.isSelected) {
                                Rectangle()
                                    .frame(width: imageSize.width, height: imageSize.height)
                                    .foregroundStyle(Color.white.opacity(0.4))
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
                        .onGeometryChange(for: CGRect.self, of: {
                            $0.frame(in: .global)
                        }, action: { newValue in
                            assetVM.location = newValue
                        })
                        .animation(.default, value: assetVM.isSelected)
                        .animation(.default, value: viewModel.isSelectionActive)
                        .onTapGesture {
                            if viewModel.isSelectionActive {
                                assetVM.isSelected.toggle()
                            }
                        }
                    }
                    .animation(.bouncy, value: viewModel.assetsCount)
                    //.border(Color.primary, width: 2) // Adding a black border}
                }
            }
            .navigationTitle(viewModel.album.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        //                        isSheetPresented.toggle()
                        viewModel.uploadAssets()
                    }) {
                        Image(systemName: "icloud.and.arrow.up")
                    }
                }
            }
            .overlay(alignment: .topTrailing, content: {
                Button {
                    viewModel.isSelectionActive.toggle()
                    // Clean selection
                    if !viewModel.isSelectionActive {
                        viewModel.cleanAssetSelection()
                    }
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
            .onChange(of: viewModel.isSelectionActive, { oldValue, newValue in
                panGesture?.isEnabled = newValue
            })
            .gesture(
                PanGesture { gesture in
                    if panGesture == nil {
                        panGesture = gesture
                        gesture.isEnabled = viewModel.isSelectionActive
                    }
                    let state = gesture.state
                    
                    if state == .began || state == .changed {
                        onGestureChange(viewModel: viewModel, gesture: gesture)
                    } else {
                        onGestureEnded(viewModel: viewModel, gesture: gesture)
                    }
                }
            )
            //            .sheet(isPresented: $isSheetPresented, content: {
            //                UploadSheet()
            //                    .presentationDetents([.fraction(0.4)])
            //            })
        }
    }
    
    // Gesture OnChanged
    private func onGestureChange(viewModel: AlbumView.ViewModel, gesture: UIPanGestureRecognizer) {
        let position = gesture.location(in: gesture.view)
        // fallingIndex is the index where the finger is currently
        if let fallingIndex = viewModel.assets.firstIndex(where: {$0.location.contains(position)}) {
            if properties.start == nil {
                properties.start = fallingIndex
                properties.isDeleteDrag = viewModel.assets[fallingIndex].isSelected
            }
            
            if let maxIndex = properties.maxIndex {
                if maxIndex < fallingIndex {
                    properties.maxIndex = fallingIndex
                }
            } else {
                properties.maxIndex = fallingIndex
            }
            
            if let minIndex = properties.minIndex {
                if minIndex > fallingIndex {
                    properties.minIndex = fallingIndex
                }
            } else {
                properties.minIndex = fallingIndex
            }
            
            properties.end = fallingIndex
            
            // Apply selection and deselection
            if let start = properties.start, let end = properties.end, let maxIndex = properties.maxIndex, let minIndex = properties.minIndex {
                let indices = start > end ? end...start : start...end
                let indicesToRemove = start > end ? minIndex...end : end...maxIndex
                viewModel.setAssetSelection(in: indicesToRemove, value: false)
                viewModel.setAssetSelection(in: indices, value: properties.isDeleteDrag ? false : true)
            }
        }
    }
    
    // Gesture OnEnded
    private func onGestureEnded(viewModel: AlbumView.ViewModel, gesture: UIPanGestureRecognizer) {
        properties.start = nil
        properties.end = nil
        properties.maxIndex = nil
        properties.minIndex = nil
        properties.isDeleteDrag = false
    }
    
    
    struct SelectionProperties {
        var start: Int?
        var end: Int?
        var maxIndex: Int?
        var minIndex: Int?
        var isDeleteDrag: Bool = false
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
