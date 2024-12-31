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
import SwiftUI

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
        var assets: [AssetViewModel]
        var assetsCount: Int {
            get { assets.count }
        }
        var isSelectionActive: Bool = false
        private(set) var isUploadActive: Bool = false
        private(set) var uploadTotalAsset = 0
        private(set) var currentUploadAsset = 0

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
        
        private func createDir(provider: CloudProvider, path: CloudPath) -> Promise<Void> {
            return Promise { fulfill, reject in
                provider.createFolderIfMissing(at: path).then {
                    debugPrint("Folder created successfully at \(path.path)")
                    fulfill(()) // Resolve the promise successfully
                }.catch { error in
                    debugPrint("Error while creating a folder: \(error.localizedDescription)")
                    reject(error) // Reject the promise with the error
                }
            }
        }

        
        func uploadAssets(provider: CloudProvider) {
            debugPrint("Starting upload...")
            self.isUploadActive = true
            self.currentUploadAsset = 0
            let uploadPath = CloudPath("\(self.album.name)")
            let selectedItems = self.isSelectionActive ? self.assets.filter({ $0.isSelected }) : self.assets
            self.isSelectionActive = false
            self.cleanAssetSelection()
            self.uploadTotalAsset = selectedItems.count
            createDir(provider: provider, path: uploadPath).then {
                var lastPromise = Promise<Void>(())  // Start with a resolved promise
                for (idx, assetVM) in selectedItems.enumerated() {
                    lastPromise = lastPromise.then {
                        return Promise { fulfill, reject in
                            if !self.isUploadActive {
                                reject(NSError(domain: "Upload Canceled", code: 0, userInfo: [NSLocalizedDescriptionKey: "Upload task was canceled"]))
                                return
                            }
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
                                    self.currentUploadAsset = idx + 1
                                    fulfill(())
                                }.catch{ error in
                                    debugPrint("Error in upload: \(error)")
                                    reject(error)
                                }
                            }
                        }
                    }
                }
                lastPromise.then {
                    print("All assets uploaded successfully")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.cancelUploads()
                        }
                    }
                }.catch { error in
                    print("An error occurred: \(error)")
                    DispatchQueue.main.async {
                        withAnimation {
                            self.cancelUploads()
                        }
                    }
                }
            }.catch { error in
                DispatchQueue.main.async {
                    withAnimation {
                        self.cancelUploads()
                    }
                }
                print("An error occurred while creating the directory: \(error)")
            }
        }
        
        func cancelUploads() {
            self.isUploadActive = false
        }
    }
        
}
