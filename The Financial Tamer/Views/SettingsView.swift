//
//  SettingsView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import SwiftUI

struct SettingsView: View {
    
    typealias Dependency = StorageManagerProtocol & NetworkStatusServiceProtocol
    
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var networkStatusService: NetworkStatusService
    
    init(container: Dependency) {
        self.storageManager = container.storageManage
        self.networkStatusService = container.networkStatus
    }
        
    
    var body: some View {
        NavigationStack {
            List {
                Section("Data Storage") {
                    Picker("Storage Method", selection: $storageManager.currentStorageType) {
                        ForEach(StorageType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text("Current: \(storageManager.currentStorageType.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Network Status") {
                    HStack {
                        Image(systemName: networkStatusService.isOnline ? "wifi" : "wifi.slash")
                            .foregroundColor(networkStatusService.isOnline ? .green : .red)
                        Text(networkStatusService.isOnline ? "Online" : "Offline")
                        Spacer()
                    }
                    
                    if let error = networkStatusService.lastNetworkError {
                        Text("Last error: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(container: AppDependency())
}
