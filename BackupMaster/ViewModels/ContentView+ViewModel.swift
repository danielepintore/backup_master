//
//  ContentView+ViewModel.swift
//  BackupMaster
//
//  Created by daniele on 08/12/24.
//

import Foundation
import Photos
import UIKit

extension ContentView {
    struct AlbumViewModel {
        let album: Album
        private var key: String {
            get {
                "album-\(album.id)-showStatus"
            }
        }
        var shouldShowAlbum: Bool {
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
            get {
                let isKeySet = UserDefaults.standard.object(forKey: key) != nil
                if !isKeySet {
                    UserDefaults.standard.set(true, forKey: key)
                }
                return UserDefaults.standard.bool(forKey: key)
            }
        }
    }
}

extension ContentView {
    @Observable
    class ViewModel: NSObject, PHPhotoLibraryChangeObserver {
        var albums: [AlbumViewModel] = []
        private let fetchHiddenAlbum: Bool = true
        private(set) var photoAccessGranted: Bool = false
        private var photoLibraryAuthorization: PHAuthorizationStatus {
            get {
                return PHPhotoLibrary.authorizationStatus(for: .readWrite)
            }
        }
        
        override init() {
            super.init()
            PHPhotoLibrary.shared().register(self)
            photoAccessGranted = photoLibraryAuthorization == .authorized || photoLibraryAuthorization == .limited
            loadAlbums()
        }
        
        deinit {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            self.loadAlbums()
        }
        
        func requestPhotoLibraryAccess() async {
            if (photoLibraryAuthorization == .authorized ||
                photoLibraryAuthorization == .limited) {
                photoAccessGranted = true;
                return
            }
            if (photoLibraryAuthorization == .notDetermined) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    if status == .authorized || status == .limited {
                        self.photoAccessGranted = true
                    }
                }
            }
        }
        
        func openSettingsForPermissions() {
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        }
        private func loadAlbums() {
            var fetchedAlbums: [AlbumViewModel] = []
            // Fetch Recents smart album
            let recentsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            recentsAlbum.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(AlbumViewModel(album: Album(name: collection.localizedTitle, collection: collection)))
            }
            
            // Fetch Favorite smart album
            let favoriteAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
            favoriteAlbum.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(AlbumViewModel(album: Album(name: collection.localizedTitle, collection: collection)))
            }
            
            // Fetch Hidden smart album
            // Hidden photos will be displayed only if the user disable the Require Authentication toggle to see the hidden photos
            // Or I should implement the photo picker for manually selecting the photos
            let hiddenFetchOptions = PHFetchOptions()
            hiddenFetchOptions.includeHiddenAssets = true
            let hiddenAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAllHidden, options: hiddenFetchOptions)
            hiddenAlbum.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(AlbumViewModel(album: Album(name: collection.localizedTitle, collection: collection)))
            }
            
            // Fetch User created albums
            let userFetchOptions = PHFetchOptions()
            userFetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: userFetchOptions)
            userAlbums.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(AlbumViewModel(album: Album(name: collection.localizedTitle, collection: collection)))
            }
            self.albums = fetchedAlbums
        }
        
        func appHasAccessToPhotoLibrary() -> Bool {
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
    }
}
