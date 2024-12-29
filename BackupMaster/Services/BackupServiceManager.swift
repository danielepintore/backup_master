//
//  ServiceManager.swift
//  BackupMaster
//
//  Created by daniele on 27/12/24.
//

import SwiftUI
import CryptomatorCloudAccessCore
import Combine

class BackupServiceManager: ObservableObject{
    private var webDavCancellable: AnyCancellable?
    @Published var userServices: [ServiceProvider] = []
    @Published var credentials: ServicesCredentials = .init()
    
    init() {
        // Subscribe to updates from the singleton
        webDavCancellable = WebDavCredentialManager.shared.$clientProviders
            .sink { [weak self] clientProviders in
                self?.userServices = clientProviders.compactMap({ ServiceProvider(serviceType: .webDav, provider: $0.provider ?? nil) })
                self?.credentials.webDav = WebDavCredentialManager.shared.credentials
                debugPrint("Updated services!")
            }
    }
    
    struct ServicesCredentials {
        var webDav: [WebDAVCredential]
        
        init(webDavCredentials: [WebDAVCredential] = []) {
            self.webDav = webDavCredentials
        }
    }
}

extension BackupServiceManager {
    class ServiceProvider {
        let serviceType: BackupService
        var provider: CloudProvider?
        
        init(serviceType: BackupService, provider: CloudProvider?) {
            self.serviceType = serviceType
            self.provider = provider
        }
    }
}

enum BackupService: CaseIterable {
    case box
    case dropbox
    case googleDrive
    case oneDrive
    case pCloud
    case s3
    case backblaze
    case webDav
    case lfs // local file system
    
    var name: String {
        switch self {
        case .box:
            "Box"
        case .dropbox:
            "DropBox"
        case .googleDrive:
            "Google Drive"
        case .oneDrive:
            "One Drive"
        case .pCloud:
            "pCloud"
        case .s3:
            "Amazon S3"
        case .backblaze:
            "BackBlaze B2"
        case .webDav:
            "WebDav"
        case .lfs:
            "Local File System"
        }
    }
    
    var imageName: String {
        switch self {
        default:
            "server.rack"
        }
    }
}
