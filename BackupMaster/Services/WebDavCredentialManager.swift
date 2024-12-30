//
//  WebDavCredentialManager.swift
//  BackupMaster
//
//  Created by daniele on 27/12/24.
//

// The credential manager is a singleton that manages all account for the service that handles
import CryptomatorCloudAccessCore
import SwiftUI
import Security
import Promises

class WebDavCredentialManager: ObservableObject {
    static let shared = {
        let instance = WebDavCredentialManager()
        instance.loadProviders()
        return instance
    }()
    private(set) var credentials: [WebDAVCredential] = []
    @Published private(set) var clientProviders: [ClientProvider] = []
    
    private func loadProviders() {
        // Changes in clientProvider sends notification in the app
        // Load credentials from keychain
        credentials = retrieveAllFromKeychain(type: WebDAVCredential.self) ?? []
        self.clientProviders.removeAll(keepingCapacity: true)
        // Create a client for each credential
        for credential in credentials {
            let client: WebDAVClient = .init(credential: credential)
            try? self.clientProviders.append(.init(client: client, provider: .init(with: client)))
        }
        
        // We should implement a struct that holds the client and the provider together
        /*
        for idx in self.clientProviders.indices {
            WebDAVAuthenticator.verifyClient(client: self.clientProviders[idx].client).then {
                try self.clientProviders[idx].provider = .init(with: self.clientProviders[idx].client)
            }.catch { error in
                debugPrint("Error in loadProviders() of WebDavCredentialManager: \(error.localizedDescription)")
            }
        }
         */
    }
    
    func saveToKeychain<T: Codable>(key: String, value: T) -> Bool {
        // Serialize the object to Data
        guard let valueData = try? JSONEncoder().encode(value) else {
            return false
        }
        
        // Create a dictionary with the keychain item attributes
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "webdav-credentials", // used to group the same kind of credentials
            kSecValueData as String: valueData
        ]
        
        // First, try to delete any existing item with the same key
        SecItemDelete(query as CFDictionary)
        
        // Add the new item to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status  == errSecSuccess {
            loadProviders()
        }
        
        return status == errSecSuccess
    }
    
    func retrieveFromKeychain<T: Codable>(key: String, type: T.Type) -> T? {
        // Create a query to find the data
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check if the operation was successful
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        // Deserialize the data into the specified type
        return try? JSONDecoder().decode(type, from: data)
    }
    
    private func retrieveAllFromKeychain<T: Codable>(type: T.Type) -> [T]? {
        // Create a query to find the data
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "webdav-credentials", // used to group the same kind of credentials
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check if the operation was successful
        guard status == errSecSuccess, let dataArr = result as? [Data] else {
            debugPrint("Failed to retrieve credentials")
            return []
        }

        // Deserialize the data into the specified type
        let decoder = JSONDecoder()
        return dataArr.map({ try? decoder.decode(type, from: $0) }) as? [T]
    }
    
    func deleteFromKeychain(key: String) -> Bool {
        // Create a dictionary with the keychain item attributes
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "webdav-credentials" // Match the same service used for saving
        ]
        
        // Attempt to delete the item from the Keychain
        let status = SecItemDelete(query as CFDictionary)
        
        if status  == errSecSuccess {
            loadProviders()
        }
        
        // Return true if the item was successfully deleted, or false otherwise
        return status == errSecSuccess || status == errSecItemNotFound
    }

}

extension WebDavCredentialManager {
    class ClientProvider {
        var client: WebDAVClient
        var provider: WebDAVProvider?
        // provider is loaded in an async fashion
        var isProviderLoaded: Bool = false
        
        init(client: WebDAVClient, provider: WebDAVProvider? = nil) {
            self.client = client
            self.provider = provider
            self.isProviderLoaded = provider != nil ? true : false
        }
        
//        func initializeProvider() throws -> Promise<Void> {
//            WebDAVAuthenticator.verifyClient(client: self.client).then {
//                try self.provider = .init(with: self.client)
//                self.isProviderLoaded = true
//            }
//        }
    }
}
