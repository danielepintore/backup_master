//
//  AddServiceView.swift
//  BackupMaster
//
//  Created by daniele on 28/12/24.
//

import SwiftUI
import CryptomatorCloudAccessCore

// This view allows to add/edit service credentials
struct UpdateServiceAccountView: View {
    // service identifies the service type, it can be nil. When it is nil we show the user a select field to make him choose the service
    @State private var service: BackupService?
    // credentialIdentifier is a String that allows us to retrieve a credential from Keychain
    private var credentialIdentifier: String?
    @ObservedObject private var backupServiceManager: BackupServiceManager
    private var showServicePicker: Bool

    init(identifier: String? = nil, service: BackupService? = nil, backupServiceManager: BackupServiceManager) {
        self.credentialIdentifier = identifier
        self.backupServiceManager = backupServiceManager
        self.showServicePicker = service == nil
        // Sets the state variable to the one passed in init method otherwise it sets it to the first enum value
        _service = State(initialValue: self.showServicePicker ? BackupService.allCases.first : service)
    }
    
    var body: some View {
        Spacer()
            .frame(height: 10)
        Form {
            if showServicePicker {
                BMSection("Select a service") {
                    Picker("Service", selection: $service) {
                        ForEach(BackupService.allCases, id: \.self) { service in
                            Text(service.name).tag(service)
                        }
                    }
                }
            }
            
            switch service {
            case .box:
                Text("Not Implemented")
            case .dropbox:
                Text("Not Implemented")
            case .googleDrive:
                Text("Not Implemented")
            case .oneDrive:
                Text("Not Implemented")
            case .pCloud:
                Text("Not Implemented")
            case .s3:
                Text("Not Implemented")
            case .backblaze:
                Text("Not Implemented")
            case .webDav:
                UpdateWebDavServiceView(identifier: self.credentialIdentifier, backupServiceManager: self.backupServiceManager) // if identifier is se we are updating an account
            case .lfs:
                Text("Not Implemented")
            case nil:
                EmptyView()
            }
        }
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}
