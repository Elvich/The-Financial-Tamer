//
//  OfflineIndicatorView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import SwiftUI

struct OfflineIndicatorView: View {
    @ObservedObject var networkStatusService = NetworkStatusService()
    
    var body: some View {
        if !networkStatusService.isOnline {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("Offline Mode")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red)
                
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: networkStatusService.isOnline)
        }
    }
}

#Preview {
    VStack {
        OfflineIndicatorView()
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
} 
