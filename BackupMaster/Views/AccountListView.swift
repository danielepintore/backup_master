//
//  AccountListView.swift
//  BackupMaster
//
//  Created by daniele on 28/12/24.
//

import SwiftUI
import CryptomatorCloudAccessCore

struct AccountListView: View {
    private let service: BackupService
    @ObservedObject private var backupServiceManager: BackupServiceManager
    
    init(service: BackupService, backupServiceManager: BackupServiceManager) {
        self.service = service
        self.backupServiceManager = backupServiceManager
    }
    
    var body: some View {
        List {
            BMSection("\(service.name) Accounts") {
                switch service {
                case .box:
                    Text("Need Implementation")
                case .dropbox:
                    Text("Need Implementation")
                case .googleDrive:
                    Text("Need Implementation")
                case .oneDrive:
                    Text("Need Implementation")
                case .pCloud:
                    Text("Need Implementation")
                case .s3:
                    Text("Need Implementation")
                case .backblaze:
                    Text("Need Implementation")
                case .webDav:
                    let credentials: [WebDAVCredential] = backupServiceManager.credentials.webDav
                    ForEach(credentials, id: \.identifier) { credential in
                        NavigationLink(destination: UpdateServiceAccountView(identifier: credential.identifier, service: .webDav, backupServiceManager: backupServiceManager)) {
                            VStack(alignment: .leading){
                                Text(credential.identifier)
                                    .font(.title3)
                                Text(credential.baseURL.absoluteString)
                                    .font(.footnote)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                case .lfs:
                    Text("Need Implementation")
                }
            }
        }
        .navigationTitle("Accounts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    AccountListView(service: .webDav)
//}
