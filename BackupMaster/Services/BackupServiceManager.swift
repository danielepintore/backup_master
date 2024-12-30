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
    @Published var credentials: ServicesCredentials = .init()
    @Published var providers: ServiceProviders = .init()
    
    init() {
        // Subscribe to updates from the singleton
        webDavCancellable = WebDavCredentialManager.shared.$clientProviders
            .sink { [weak self] clientProviders in
                self?.providers.webdav = clientProviders.compactMap({ $0.provider })
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
    
    struct ServiceProviders {
        var webdav: [CloudProvider]
        var activeServices: [BackupService] {
            get {
                var services: [BackupService] = []
                if webdav.count > 0 { services.append(.webDav) }
                // implement for other services
                return services
            }
        }
        init(webdav: [CloudProvider] = []) {
            self.webdav = webdav
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
