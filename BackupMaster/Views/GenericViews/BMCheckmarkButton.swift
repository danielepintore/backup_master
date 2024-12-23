//
//  BMCheckmarkButton.swift
//  BackupMaster
//
//  Created by daniele on 23/12/24.
//

import SwiftUI

struct BMCheckmarkButton: View {
    @Binding var isChecked: Bool
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isChecked ? .accentColor : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
