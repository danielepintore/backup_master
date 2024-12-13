//
//  SectionHeaderView.swift
//  BackupMaster
//
//  Created by Developer on 12/12/24.
//

import SwiftUI

struct BMSectionHeaderView: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    var body: some View {
        Text(title)
            .font(.title3)
            .bold()
    }
}

#Preview {
    BMSectionHeaderView("Albums")
}
