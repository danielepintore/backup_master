//
//  AlbumView+ViewModel.swift
//  BackupMaster
//
//  Created by daniele on 25/12/24.
//

import Foundation
import Photos
import Promises
import CryptomatorCloudAccessCore

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
        private var observation: NSKeyValueObservation? = nil
        private(set) var album: Album
        private(set) var backupServiceManager: BackupServiceManager
        var assets: [AssetViewModel]
        var assetsCount: Int {
            get { assets.count }
        }
        var isSelectionActive: Bool = false
        
        init(album: Album, backupServiceManager: BackupServiceManager) {
            self.album = album
            self.assets = album.assets.map { asset in
                AssetViewModel(asset: asset, isSelected: false)
            }
            self.backupServiceManager = backupServiceManager
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
        
        // TODO: pass provider to this function as argument
        private func createDir(path: CloudPath) -> Promise<Void> {
            return Promise { fulfill, reject in
                guard let provider = self.backupServiceManager.providers.webdav.first else {
                    reject(NSError(domain: "createDirError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Provider not found"]))
                    return
                }
                
                provider.createFolderIfMissing(at: path).then {
                    debugPrint("Folder created successfully at \(path.path)")
                    fulfill(()) // Resolve the promise successfully
                }.catch { error in
                    debugPrint("Error while creating a folder: \(error.localizedDescription)")
                    reject(error) // Reject the promise with the error
                }
            }
        }

        
        func uploadAssets() {
            debugPrint("Starting upload...")
            if let provider = self.backupServiceManager.providers.webdav.first {
                let serialQueue = DispatchQueue(label: "com.example.uploadQueue")
                let uploadPath = CloudPath("\(self.album.name)")
                let selectedItems = self.isSelectionActive ? self.assets.filter({ $0.isSelected }) : self.assets
                createDir(path: uploadPath).then {
                    var lastPromise = Promise<Void>(())  // Start with a resolved promise
                    for assetVM in selectedItems {
                        lastPromise = lastPromise.then {
                            return Promise { fulfill, reject in
                                serialQueue.async {
                                    assetVM.asset.getFileURL { url in
                                        guard let assetURL = url else {
                                            // no url
                                            debugPrint("Failed to get assetURL")
                                            reject(NSError(domain: "assetGetURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't get the asset URL"]))
                                            return
                                        }
                                        provider.uploadFile(from: assetURL, to: uploadPath.appendingPathComponent(assetURL.lastPathComponent), replaceExisting: true, onTaskCreation: { uploadTask in
                                            uploadTask?.resume()
                                            DispatchQueue.main.async {
                                                guard let uploadTask = uploadTask else { return }
                                                self.observation = uploadTask.progress.observe(\.fractionCompleted) { progress, _ in
                                                    debugPrint("Upload progress of \(assetURL.lastPathComponent) is at: \(Int(progress.fractionCompleted * 100))%")
                                                }
                                            }
                                        }).then{ metadata in
                                            debugPrint("uploading asset: \(metadata.name) complete.")
                                            fulfill(())
                                        }.catch{ error in
                                            debugPrint("Error in upload: \(error)")
                                            reject(error)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    lastPromise.then {
                        print("All assets uploaded successfully")
                    }.catch { error in
                        print("An error occurred: \(error)")
                    }
                }
            }
        }
    }
        
}
