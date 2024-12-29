//
//  WebDavCredentialManager.swift
//  BackupMaster
//
//  Created by daniele on 27/12/24.
//

// The credential manager is a singleton that manages all account for the service that handles
import CryptomatorCloudAccessCore
import SwiftUI

class WebDavCredentialManager: ObservableObject {
    static let shared = {
        let instance = WebDavCredentialManager()
        instance.loadProviders()
        return instance
    }()
    private(set) var credentials: [WebDAVCredential] = []
    @Published private(set) var clientProviders: [ClientProvider] = []
    
    private func loadProviders() {
        // Load credentials from keychain
        // Test generate mock credential
        credentials = [.init(baseURL: URL(string: "http://192.168.1.107:9090/")!, username: "daniele", password: "secret", allowedCertificate: nil, identifier: "webdav1-config")]
        // Create a client for each credential
        for credential in credentials {
            self.clientProviders.append(.init(client: .init(credential: credential)))
        }
        
        // We should implement a struct that holds the client and the provider together
        for idx in self.clientProviders.indices {
            WebDAVAuthenticator.verifyClient(client: self.clientProviders[idx].client).then {
                try self.clientProviders[idx].provider = .init(with: self.clientProviders[idx].client)
            }.catch { error in
                debugPrint("Error in loadProviders() of WebDavCredentialManager: \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: These fuctions needs to be checked, for the moment they work as placeholders
//    func saveToKeychain<T: Codable>(key: String, value: T) -> Bool {
//        // Serialize the object to Data
//        guard let valueData = try? JSONEncoder().encode(value) else {
//            return false
//        }
//        
//        // Create a dictionary with the keychain item attributes
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecValueData as String: valueData
//        ]
//        
//        // First, try to delete any existing item with the same key
//        SecItemDelete(query as CFDictionary)
//        
//        // Add the new item to the Keychain
//        let status = SecItemAdd(query as CFDictionary, nil)
//        
//        return status == errSecSuccess
//    }
//    
//    func retrieveFromKeychain<T: Codable>(key: String, type: T.Type) -> T? {
//        // Create a query to find the data
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        
//        // Check if the operation was successful
//        guard status == errSecSuccess, let data = result as? Data else {
//            return nil
//        }
//        
//        // Deserialize the data into the specified type
//        return try? JSONDecoder().decode(type, from: data)
//    }
}

extension WebDavCredentialManager {
    struct ClientProvider {
        var client: WebDAVClient
        var provider: WebDAVProvider?
        // provider is loaded in an async fashion
        var isProviderLoaded: Bool = false
    }
}
