//
//  ContentView.swift
//  BackupMaster
//
//  Created by daniele on 06/12/24.
//

import SwiftUI
import Photos

struct ContentView: View {
    @ObservedObject private(set) var backupServiceManager: BackupServiceManager
    @State private var viewModel: ViewModel = ViewModel()
    @State private var editMode: EditMode = .inactive;
    @State private var showAddServiceSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                BMSection("Albums") {
                    if (viewModel.photoAccessGranted) {
                        ForEach($viewModel.albums, id: \.album.name) { $albumVM in // The id needs to be name and not id otherwise photos aren't updated when deleted or created
                            if (albumVM.shouldShowAlbum || editMode.isEditing) {
                                HStack {
                                    if editMode.isEditing {
                                        BMCheckmarkButton(isChecked: $albumVM.shouldShowAlbum)
                                            .padding(.trailing)
                                            .transition(.opacity)
                                            .transition(.move(edge: .leading))
                                    }
                                    NavigationLink {
                                        AlbumView(album: albumVM.album, backupServiceManager: backupServiceManager, columns: 5)
                                    } label: {
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
                    ForEach(BackupService.allCases, id: \.self){ service in
                        NavigationLink {
                            AccountListView(service: service, backupServiceManager: backupServiceManager)
                        } label: {
                            Label(service.name, systemImage: service.imageName)
                        }
                    }
                }
                BMSection("Other") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Backup Master")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if editMode == .inactive {
                        Menu {
                            Button("Add Service", systemImage: "plus") {
                                showAddServiceSheet.toggle()
                            }
                            Button("Edit", systemImage: "pencil") {
                                toggleEditMode()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    } else {
                        Button("Done") {
                            toggleEditMode()
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddServiceSheet) {
                UpdateServiceAccountView(backupServiceManager: backupServiceManager)
            }
            .environment(\.editMode, $editMode)
            .onAppear {
                Task {
                    await viewModel.requestPhotoLibraryAccess()
                }
            }
        }
    }
    
    private func toggleEditMode() {
        withAnimation {
            editMode = editMode == .active ? EditMode.inactive : EditMode.active
        }
    }
}

//#Preview {
//    ContentView()
//}
