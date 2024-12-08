//
//  AlbumModel.swift
//  BackupMaster
//
//  Created by daniele on 08/12/24.
//

import Foundation
import Photos

class Album: Identifiable, Equatable {
    var id: String
    private(set) var name: String
    private(set) var collection: PHAssetCollection
    private(set) var assets: [PHAsset]
    private(set) var creationDate: Date?
    
    init(name: String?, collection: PHAssetCollection, assets: [PHAsset]) {
        self.id = collection.localIdentifier
        self.name = name ?? "Unnamed Album"
        self.collection = collection
        self.assets = assets
        self.creationDate = collection.startDate
    }
    
    init(name: String?, collection: PHAssetCollection) {
        self.id = collection.localIdentifier
        self.name = name ?? "Unnamed Album"
        self.collection = collection
        self.assets = []
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.loadAssets(fetchOptions: fetchOptions)
        self.creationDate = collection.startDate
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id && lhs.collection.estimatedAssetCount == rhs.collection.estimatedAssetCount
    }
    
    private func loadAssets(fetchOptions: PHFetchOptions) {
        // Fetch assets from album
            let fetchedAssets = PHAsset.fetchAssets(in: self.collection, options: fetchOptions)
            fetchedAssets.enumerateObjects { (asset, index, stop) in
                self.assets.append(asset)
        }
    }
}
