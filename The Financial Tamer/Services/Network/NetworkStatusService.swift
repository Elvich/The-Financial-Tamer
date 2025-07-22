//
//  NetworkStatusService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import Network
import Combine

final class NetworkStatusService: ObservableObject {
    
    @Published var isOnline: Bool = true
    @Published var lastNetworkError: Error?
    
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    func markNetworkError(_ error: Error) {
        DispatchQueue.main.async {
            self.lastNetworkError = error
            self.isOnline = false
        }
    }
    
    func clearNetworkError() {
        DispatchQueue.main.async {
            self.lastNetworkError = nil
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
} 
