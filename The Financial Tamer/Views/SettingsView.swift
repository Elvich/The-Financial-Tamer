//
//  SettingsView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var appDependency: AppDependency
    
    var body: some View {
        NavigationStack {
            List {
                
                Section("Тема"){
                    Picker("Тема приложения", selection: $appDependency.appSettings.appTheme) {
                        ForEach(AppSettings.Theme.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Хранилище данных") {
                    Picker("Способ хранения", selection: $appDependency.storageManager.currentStorageType) {
                        ForEach(StorageType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Статус соединения") {
                    HStack {
                        Image(systemName: appDependency.networkStatus.isOnline ? "wifi" : "wifi.slash")
                            .foregroundColor(appDependency.networkStatus.isOnline ? .green : .red)
                        Text( appDependency.networkStatus.isOnline ? "Online" : "Offline")
                        Spacer()
                    }
                    
                    if let error = appDependency.networkStatus.lastNetworkError {
                        Text("Last error: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("0.6.1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.bottom)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppDependency())
}
