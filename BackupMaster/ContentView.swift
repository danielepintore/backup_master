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
    @State private var editMode: EditMode = .inactive;
    var body: some View {
        NavigationStack {
            List {
                BMSection("Albums") {
                    if (viewModel.photoAccessGranted) {
                        ForEach($viewModel.albums, id: \.album.id) { $albumVM in
                            if (albumVM.shouldShowAlbum || editMode.isEditing) {
                                HStack {
                                    if editMode.isEditing {
                                        BMCheckmarkButton(isChecked: $albumVM.shouldShowAlbum)
                                            .padding(.trailing)
                                            .transition(.opacity)
                                            .transition(.move(edge: .leading))
                                    }
                                    NavigationLink(value: albumVM.album) {
                                        Label(albumVM.album.name, systemImage: "photo.on.rectangle.angled")
                                    }
                                }
                                .animation(.default, value: editMode.isEditing)
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
            .navigationDestination(for: Album.self) { album in
                AlbumView(album: album, columns: 5) // Allow user to select how many colums, need to save preference to userdefaults
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Add Service", systemImage: "plus") {
                            // TODO: Open the add service page
                        }
                        let editButtonText = editMode == .active ? "Done" : "Edit"
                        Button(editButtonText, systemImage: "pencil") {
                            withAnimation {
                                editMode = editMode == .active ? EditMode.inactive : EditMode.active
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .environment(\.editMode, $editMode)
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
