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
                AddWebDavAccountView(identifier: self.credentialIdentifier, backupServiceManager: self.backupServiceManager) // if identifier is se we are updating an account
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

struct AddWebDavAccountView: View {
    let identifier: String?
    var credential: WebDAVCredential? = nil
    @State private var name: String = ""
    @State private var host: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var port: Int? = nil
    @State private var isHttps: Bool = false
    
    private var portFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 9999
        return formatter
    }
    
    init(identifier: String? = nil, backupServiceManager: BackupServiceManager) {
        if let id = identifier {
            self.identifier = id
            // fetch credential and initialize state vars
            self.credential = backupServiceManager.getCredential(for: .webDav, identifier: id)
            if let credential = self.credential {
                _name = State(initialValue: id)
                _host = State(initialValue: credential.baseURL.host() ?? "")
                _username = State(initialValue: credential.username)
                _password = State(initialValue: credential.password)
                _port = State(initialValue: credential.baseURL.port)
                _isHttps = State(initialValue: credential.baseURL.scheme == "https")
            }
            
        } else {
            self.identifier = nil
        }
    }
    
    var body: some View {
        TextField("Configuration name", text: $name)
            .keyboardType(.alphabet)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        TextField("Host", text: $host)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        TextField("Username", text: $username)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        SecureField("Password", text: $password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        TextField("Port", value: $port, formatter: portFormatter)
            .keyboardType(.numberPad)
        Toggle(isOn: $isHttps) {
            Text("Use HTTPS")
        }
        
        Button("Save Account"){
            // TODO: we should implement custom certs for https servers
            var urlComponents: URLComponents = URLComponents()
            let hostPath = host.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
            if let hostname = hostPath.first {
                urlComponents.host = String(hostname)
            }
            if hostPath.count > 1 {
                urlComponents.path = "/" + hostPath[1]
            }
            urlComponents.scheme = isHttps ? "https": "http"
            urlComponents.port = port
            guard self.name != "" else { return }
            guard let url = urlComponents.url else { return }
            if let identifier = self.identifier {
                let credential = WebDAVCredential(baseURL: url, username: username, password: password, allowedCertificate: nil, identifier: identifier)
                //WebDavCredentialManager.shared.updateCredentials()
                debugPrint("Updated account with identifier: \(identifier)")
            } else {
                let credential = WebDAVCredential(baseURL: url, username: username, password: password, allowedCertificate: nil, identifier: name) // TODO: add a number postfix to name or ensure it is unique in some other ways
                //WebDavCredentialManager.shared.addCredentials()
                // TODO: Add a dismiss to cose the sheet
                debugPrint("Updated account with identifier: \(name)")
            }
        }
    }
}
