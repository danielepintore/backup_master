//
//  ContentView+ViewModel.swift
//  BackupMaster
//
//  Created by daniele on 08/12/24.
//

import Foundation
import Photos
import UIKit

private let services: [BackupServices] = [
    BackupServices(name: "WebDAV", imageName: "server.rack"),
    BackupServices(name: "FTP", imageName: "server.rack"),
    BackupServices(name: "SMB", imageName: "server.rack"),
    BackupServices(name: "BackBlaze", imageName: "server.rack"),
    BackupServices(name: "Amazon S3", imageName: "server.rack"),
    BackupServices(name: "Google Photos", imageName: "server.rack"),
]

extension ContentView {
    @Observable
    class ViewModel: NSObject, PHPhotoLibraryChangeObserver {
        private(set) var backupServices: [BackupServices] = []
        private(set) var albums: [Album] = []
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
            backupServices = services
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
            var fetchedAlbums: [Album] = []
            // Fetch Recents smart album
            let recentsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            recentsAlbum.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(Album(name: collection.localizedTitle, collection: collection))
            }
            
            // Fetch Favorite smart album
            let favoriteAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
            favoriteAlbum.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(Album(name: collection.localizedTitle, collection: collection))
            }
            
            // Fetch Hidden smart album
            let hiddenAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAllHidden, options: nil)
            hiddenAlbum.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(Album(name: collection.localizedTitle, collection: collection))
            }
            
            // Fetch User created albums
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            userAlbums.enumerateObjects { (collection, index, stop) in
                fetchedAlbums.append(Album(name: collection.localizedTitle, collection: collection))
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
