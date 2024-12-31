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
    var cancelAction: () -> Void
    var progress: Float {
        get {
            1.00/Float(maxCount)*Float(currentCount)
        }
    }
    
    var body: some View {
        HStack {
            Text("\(currentCount)/\(maxCount)")
            ProgressView(value: progress, total: 1)
                .progressViewStyle(.linear)
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
