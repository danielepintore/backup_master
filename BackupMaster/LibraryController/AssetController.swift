//
//  AssetController.swift
//  BackupMaster
//
//  Created by daniele on 07/12/24.
//

import Foundation
import Photos

class AssetController: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var assets: [PHAsset] = []
    @Published var albumNames: [String] = []
    
    override init() {
        super.init()
        loadPhotos()
        loadAlbumNames()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.loadPhotos()
        }
    }
    
    func loadPhotos() {
        self.assets.removeAll()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        allPhotos.enumerateObjects { (asset, index, stop) in
            DispatchQueue.main.async {
                self.assets.append(asset)
            }
        }
    }
    
    func loadPhotos(fromAlbum albumName: String, completion: @escaping ([PHAsset]) -> Void){
        var albumAssets: [PHAsset] = []
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // Fetch all albums
        // Fetch all albums on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            albums.enumerateObjects { (collection, index, stop) in
                if collection.localizedTitle == albumName {
                    // Fetch photos from album
                    let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    assets.enumerateObjects { (asset, index, stop) in
                        albumAssets.append(asset)
                        // Update UI in chunks to keep it responsive
                        if albumAssets.count % 20 == 0 || index == assets.count - 1 {
                            DispatchQueue.main.async {
                                completion(Array(albumAssets.prefix(albumAssets.count)))
                            }
                        }
                    }
                    stop.pointee = true // Stop the enumeration once the album is found
                }
            }
            // Check in users collection // TODO: optimize this mess
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            userAlbums.enumerateObjects { (collection, index, stop) in
                if collection.localizedTitle == albumName {
                    // Fetch photos from album
                    let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    assets.enumerateObjects { (asset, index, stop) in
                        albumAssets.append(asset)
                        // Update UI in chunks to keep it responsive
                        if albumAssets.count % 20 == 0 || index == assets.count - 1 {
                            DispatchQueue.main.async {
                                completion(Array(albumAssets.prefix(albumAssets.count)))
                            }
                        }
                    }
                    stop.pointee = true // Stop the enumeration once the album is found
                }
            }
        }
    }
    
    public func loadAlbumNames() {
        self.albumNames.removeAll()
        // Fetch Recents smart album
        let recentsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        recentsAlbum.enumerateObjects { (collection, index, stop) in
            DispatchQueue.main.async {
                self.albumNames.append(collection.localizedTitle ?? "Unknown Album Title")
            }
        }
        
        // Fetch Favorite smart album
        let favoriteAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        favoriteAlbum.enumerateObjects { (collection, index, stop) in
            DispatchQueue.main.async {
                self.albumNames.append(collection.localizedTitle ?? "Unknown Album Title")
            }
        }
        
        // Fetch user collections
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        userCollections.enumerateObjects { (collection, index, stop) in
            if let assetCollection = collection as? PHAssetCollection {
                DispatchQueue.main.async {
                    self.albumNames.append(assetCollection.localizedTitle ?? "Unknown Album Title")
                }
            }
        }
    }
    
    public func checkPermissions() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            return false
        case .restricted:
            return false
        case .denied:
            return false
        case .authorized:
            return true
        case .limited:
            return true
        @unknown default:
            return false
        }
    }
    
    public func askPermissions() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
}
