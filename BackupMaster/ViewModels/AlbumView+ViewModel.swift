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
        let isSelected: Bool
    }
    
    @Observable
    class ViewModel {
        private(set) var album: Album
        private(set) var selection: Set<PHAsset> = Set()
        var isSelectionActive: Bool = false
        
        init(album: Album) {
            self.album = album
        }
        
        func toggleAssetSelection(for asset: PHAsset) {
            if isSelectionActive {
                if self.selection.contains(asset) {
                    self.selection.remove(asset)
                } else {
                    self.selection.insert(asset)
                }
            }
        }
    }
}
