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
    private var cancellable: AnyCancellable?
    @Published var userServices: [ServiceProvider] = []
    
    init() {
        // Subscribe to updates from the singleton
        cancellable = WebDavCredentialManager.shared.$clientProviders
            .sink { [weak self] clientProviders in
                self?.userServices = clientProviders.compactMap({ ServiceProvider(serviceType: .webDav, provider: $0.provider ?? nil) })
                debugPrint("Updated services!")
            }
    }
    
    func getCredentials<T>(for service: BackupService) -> [T] {
        switch service {
        case .webDav:
            if T.self == WebDAVCredential.self {
                if let credential = WebDavCredentialManager.shared.credentials as? [T] {
                    return credential
                }
            }
            return []
        default:
            return []
        }
    }
    
    func getCredential<T>(for service: BackupService, identifier: String) -> T? {
        switch service {
        case .webDav:
            if T.self == WebDAVCredential.self {
                if let credential = WebDavCredentialManager.shared.credentials.filter({ $0.identifier == identifier }).first as? T? {
                    return credential
                }
            }
            return nil
        default:
            return nil
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
