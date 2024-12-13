//
//  BMSection.swift
//  BackupMaster
//
//  Created by Developer on 12/12/24.
//

import SwiftUI

struct BMSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        Section {
            content
        } header: {
            BMSectionHeaderView(title)
                .foregroundStyle(.primary)
                .textCase(.none)
        }
    }
}

#Preview {
    BMSection("Section Title") {
        Text("Test")
    }
}
