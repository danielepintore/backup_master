//
//  AlbumModel.swift
//  BackupMaster
//
//  Created by daniele on 08/12/24.
//

import Foundation
import Photos

class Album: Identifiable, Equatable, Hashable {
    var id: String
    private(set) var name: String
    private(set) var collection: PHAssetCollection
    private(set) var assets: [PHAsset]
    private(set) var creationDate: Date?
    
    init(name: String?, collection: PHAssetCollection, assets: [PHAsset]) {
        self.id = collection.localIdentifier + "-" + String(assets.count)
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
        self.id = collection.localIdentifier + "-" + String(assets.count)
        self.creationDate = collection.startDate
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private func loadAssets(fetchOptions: PHFetchOptions) {
        // Fetch assets from album
            let fetchedAssets = PHAsset.fetchAssets(in: self.collection, options: fetchOptions)
            fetchedAssets.enumerateObjects { (asset, index, stop) in
                self.assets.append(asset)
        }
    }
}

extension PHAsset {
    // TODO: write this as promise
    // TODO: move this to another place
    func getFileURL(completion: @escaping (URL?) -> Void) {
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true // Allow fetching from iCloud if needed
        
        let resources = PHAssetResource.assetResources(for: self)
        guard let resource = resources.first(where: { $0.type == .photo || $0.type == .video }) else {
            completion(nil)
            return
        }
        
        // Create a temporary directory to store the file
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(resource.originalFilename)
        
        // Remove the file if it already exists
        // if we already have a file we get a strange error in writeData
        // we should find a better way to
        if FileManager.default.fileExists(atPath: tempFileURL.path) {
            do {
                try FileManager.default.removeItem(at: tempFileURL)
//                print("Existing file removed: \(tempFileURL)")
            } catch {
//                print("Error removing existing file: \(error)")
                completion(nil)
                return
            }
        }
        
        // Write the asset resource to the temp file
        PHAssetResourceManager.default().writeData(for: resource, toFile: tempFileURL, options: options) { error in
            if let error = error {
                print("Error writing asset to file: \(error)")
                completion(nil)
            } else {
                completion(tempFileURL)
            }
        }
    }
}
