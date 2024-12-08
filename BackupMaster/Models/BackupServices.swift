//
//  BackupServices.swift
//  BackupMaster
//
//  Created by daniele on 08/12/24.
//

import Foundation
import SwiftUI

struct BackupServices: Hashable {
    var name: String
    var imageName: String
    var isConfigured: Bool
    
    init(name: String, imageName: String, isConfigured: Bool = false) {
        self.name = name
        self.imageName = imageName
        self.isConfigured = isConfigured
    }
}
