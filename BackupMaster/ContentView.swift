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
        NavigationStack {
            List {
                BMSection("Albums") {
                    if (viewModel.photoAccessGranted) {
                        ForEach(viewModel.albums, id: \.name) { album in
                            NavigationLink(destination: AlbumView(album: album)) { // Allow user to select how many colums, need to save preference to userdefaults
                                Label(album.name, systemImage: "photo.on.rectangle.angled")
                            }
                        }
                    } else {
                        Text("Please provide access to your photos library.")
                        Button("Ask permissions") {
                            viewModel.openSettingsForPermissions()
                        }
                    }
                }
                BMSection("Services") {
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
                BMSection("Other") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Backup Master")
            .navigationDestination(for: BackupServices.self) { service in
                Text(service.name)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .onAppear {
                Task {
                    await viewModel.requestPhotoLibraryAccess()
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
