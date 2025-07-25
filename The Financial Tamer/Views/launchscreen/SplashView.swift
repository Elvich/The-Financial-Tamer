//
//  SplashView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 25.07.2025.
//

import SwiftUI
import Lottie

struct SplashView: View {
    @State private var showMainView = false
    @EnvironmentObject var appDependency: AppDependency
    
    var body: some View {
        Group {
            if showMainView {
                // Здесь будет твой основной экран
                ContentView()
            } else {
                // Экран с анимацией
                VStack {
                    Spacer()
                    Text("The Financial Tamer")
                        .fontWeight(.black)
                        .foregroundColor(Color("AccentColor"))
                        .font(.largeTitle)
                        .padding(.top, 150.0)
                        
                    
                    LottieView(filename: "ScreenSaver")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    checkStorageSettings()
                }
                .preferredColorScheme(colorScheme)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showMainView = true
                        }
                    }
                }
            }
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appDependency.appSettings.appTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private func checkStorageSettings() {
        // Проверяем, изменились ли настройки хранения
        let savedType = UserDefaults.standard.string(forKey: "StorageType") ?? StorageType.swiftData.rawValue
        _ = StorageType(rawValue: savedType) ?? .swiftData
    }
}

#Preview{
    SplashView()
        .environmentObject(AppDependency())
}
