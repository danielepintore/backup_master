//
//  AlbumView+ViewModel.swift
//  BackupMaster
//
//  Created by daniele on 25/12/24.
//

import Foundation
import Photos

extension AlbumView {
    struct AssetViewModel {
        let asset: PHAsset
        var isSelected: Bool
        var location: CGRect = .zero
        
        mutating func setLocation(_ location: CGRect) {
            self.location = location
        }
    }
    
    @Observable
    class ViewModel: ObservableObject {
        private(set) var album: Album
        var assets: [AssetViewModel]
        var assetsCount: Int {
            get { assets.count }
        }
        var isSelectionActive: Bool = false

        init(album: Album) {
            self.album = album
            self.assets = album.assets.map { asset in
                AssetViewModel(asset: asset, isSelected: false)
            }
        }
        
        func setAssetSelection(in range: ClosedRange<Int>, value: Bool) {
            for index in range {
                guard index >= 0 && index < self.assetsCount else { break }
                self.assets[index].isSelected = value
            }
        }
        
        func cleanAssetSelection() {
            for index in self.assets.indices {
                if self.assets[index].isSelected {
                    self.assets[index].isSelected = false
                }
            }
        }
    }
}
