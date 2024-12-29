//
//  UpdateWebDavServiceView.swift
//  BackupMaster
//
//  Created by daniele on 29/12/24.
//

import SwiftUI
import CryptomatorCloudAccessCore

struct UpdateWebDavServiceView: View {
    let identifier: String?
    var credential: WebDAVCredential? = nil
    @State private var name: String = ""
    @State private var host: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var port: Int? = nil
    @State private var isHttps: Bool = false
    @Environment(\.dismiss) private var dismiss
    
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
            self.credential = backupServiceManager.credentials.webDav.first(where: { $0.identifier == id })
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
        Section {
            TextField("Configuration name", text: $name)
                .keyboardType(.alphabet)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .disabled(self.identifier != nil)
                .foregroundStyle(self.identifier != nil ? .gray : .primary)
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
                
                let credential = WebDAVCredential(baseURL: url, username: username, password: password, allowedCertificate: nil, identifier: name) // TODO: add a number postfix to name or ensure it is unique in some other ways
                if WebDavCredentialManager.shared.saveToKeychain(key: credential.identifier, value: credential) {
                    debugPrint("Credential Added successfully")
                    dismiss()
                    return
                }
                debugPrint("Failed to add the credential: \(name)")
            }
        }
        
        if let identifier = self.identifier {
            Button("Remove Account") {
                if WebDavCredentialManager.shared.deleteFromKeychain(key: identifier) {
                    debugPrint("Credential: \(identifier) deleted.")
                    dismiss()
                } else {
                    debugPrint("Failed to delete the credential: \(identifier)")
                }
            }
            .foregroundStyle(.red)
        }
    }
}
