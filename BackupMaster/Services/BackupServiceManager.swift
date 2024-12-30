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
    @Published var services: Services = .init()
    
    init() {
        // Subscribe to updates from the singleton
        webDavCancellable = WebDavCredentialManager.shared.$configClientProviders
            .sink { [weak self] configClientProviders in
                self?.services.webdav.removeAll(keepingCapacity: true)
                self?.services.webdav.append(contentsOf: configClientProviders)
                debugPrint("Updated services!")
            }
    }
    
    struct Services {
        var webdav: [WebDavCredentialManager.ConfigClientProvider]
        var activeServices: [BackupService] {
            get {
                var services: [BackupService] = []
                if webdav.count > 0 { services.append(.webDav) }
                // implement for other services
                return services
            }
        }
        var providers: [CloudProvider] {
            get {
                var providers: [CloudProvider] = []
                if webdav.count > 0 { providers.append(contentsOf: webdav.compactMap({ $0.provider }))}
                // implement for other services
                return providers
            }
        }
        
        init(webdav: [WebDavCredentialManager.ConfigClientProvider] = []) {
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
