//
//  UploadProgressView.swift
//  BackupMaster
//
//  Created by daniele on 31/12/24.
//

import SwiftUI

struct UploadProgressView: View {
    var currentCount: Int
    var maxCount: Int
    var itemProgress: Float
    var errorMsg: String?
    var cancelAction: () -> Void
    
    var body: some View {
        HStack {
            if let errorMessage = errorMsg {
                Text(errorMessage)
            } else {
                Text("\(currentCount)/\(maxCount)")
                ProgressView(value: itemProgress, total: 1)
                    .progressViewStyle(.linear)
            }
            Button {
                cancelAction()
            } label: {
                Image(systemName: "xmark")
            }
            .tint(.red)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .foregroundStyle(Color.primary)
        .background(.regularMaterial, in: Capsule())
        .padding(5)
    }
}
