//
//  AppDependency.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 23.07.2025.
//

import Foundation

struct AppDependency: NetworkClientProtocol, NetworkStatusServiceProtocol, DateServiceProtocol, StorageManagerProtocol
{
    var storageManage: StorageManager
    
    var dateService: DateService
    
    var networkStatus: NetworkStatusService
    
    var networkClient: NetworkClient
    
    init(){
        networkClient = DefaultNetworkClient()
        networkStatus = NetworkStatusService()
        dateService = DateService()
        storageManage = StorageManager()
    }
}
