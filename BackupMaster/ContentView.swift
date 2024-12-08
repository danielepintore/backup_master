//
//  ContentView.swift
//  BackupMaster
//
//  Created by daniele on 06/12/24.
//

import SwiftUI
import Photos

struct ContentView: View {
    let services: [BackupServices] = [.init(name: "WebDav", imageName: "server.rack", color: .blue), .init(name: "FTP", imageName: "server.rack", color: .green), .init(name: "BackBlaze B2", imageName: "server.rack", color: .red)]
    
    @StateObject var assetController = AssetController()
    
    let colors: [Color] = [Color.green, Color.red, Color.blue, Color.yellow, Color.orange]
    
    var body: some View {
        let libraryAccessProvided = assetController.checkPermissions()
        NavigationStack {
            List {
                Section("Photo albums") {
                    if (libraryAccessProvided) {
                        ForEach(assetController.albumNames, id: \.self) { albumName in
                            NavigationLink(value: albumName){
                                Label(albumName, systemImage: "photo.on.rectangle.angled")
                            }
                        }
                    } else {
                        Text("Please provide access to your photos library.")
                        Button("Ask permissions") {
                            Task {
                                await assetController.askPermissions()
                            }
                        }
                    }
                }
                Section("Services") {
                    ForEach(services, id: \.name){ service in
                        NavigationLink(value: service){
                            Label(service.name, systemImage: service.imageName)
                        }
                    }
                }
                Section("Other") {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("Backup Master")
            .navigationDestination(for: BackupServices.self) { service in
                Text(service.name)
            }
            .navigationDestination(for: String.self) { selectedAlbum in
                AlbumLoaderView(albumName: selectedAlbum, assetController: assetController)
            }
        }
    }
}

struct AlbumLoaderView: View {
    let albumName: String
    @ObservedObject var assetController: AssetController
    @State private var photos: [PHAsset] = []
    var body: some View {
        AlbumView(albumName: albumName, photos: photos)
            .onAppear {
                assetController.loadPhotos(fromAlbum: albumName) { assets in
                    self.photos = assets
                }
            }
    }
}

struct BackupServices: Hashable {
    let name: String
    let imageName: String
    let color: Color
}
#Preview {
    ContentView()
}
