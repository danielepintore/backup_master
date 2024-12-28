//
//  BackupMasterApp.swift
//  BackupMaster
//
//  Created by daniele on 06/12/24.
//

import SwiftUI

@main
struct BackupMasterApp: App {
    @ObservedObject private var backupServiceManager = BackupServiceManager()
    var body: some Scene {
        WindowGroup {
            ContentView(backupServiceManager: backupServiceManager)
                //.tint(.red)
        }
    }
}
