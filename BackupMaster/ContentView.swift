//
//  ContentView.swift
//  BackupMaster
//
//  Created by daniele on 06/12/24.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        let appHasAccessToPhotoLibrary = viewModel.appHasAccessToPhotoLibrary()
        NavigationStack {
            List {
                Section("Photo albums") {
                    if (appHasAccessToPhotoLibrary) {
                        ForEach(viewModel.albums, id: \.name) { album in
                            NavigationLink(destination: AlbumView(album: album)) {
                                Label(album.name, systemImage: "photo.on.rectangle.angled")
                            }
                        }
                    } else {
                        Text("Please provide access to your photos library.")
                        Button("Ask permissions") {
                            Task {
                                await viewModel.askForPhotoAccess()
                            }
                        }
                    }
                }
                Section("Services") {
                    ForEach(viewModel.backupServices, id: \.name){ service in
                        NavigationLink(value: service){
                            HStack {
                                Label(service.name, systemImage: service.imageName)
                            }
                        }
                    }
                    .onMove(perform: moveService)
                    .onDelete(perform: deleteService)
                }
                Section("Other") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Backup Master")
            .navigationDestination(for: BackupServices.self) { service in
                Text(service.name)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    private func deleteService(at offsets: IndexSet) {
        offsets.forEach { index in
            let service = viewModel.backupServices[index]
            print("Removing \(service.name)")
        }
    }

    private func moveService(from source: IndexSet, to destination: Int) {
    }
}

#Preview {
    ContentView()
}
