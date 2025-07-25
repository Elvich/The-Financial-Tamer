//
//  AppSettings.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 24.07.2025.
//

import Foundation

class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let appTheme = "appTheme"
    }
    
    
    // MARK: - Properties
    @Published var appTheme: Theme {
        didSet {
            defaults.set(appTheme.rawValue, forKey: Keys.appTheme)
            print("Theme changed to: \(appTheme)") // Для отладки
        }
    }
    
    
    // MARK: - Initialization
    init() {
        
        // Загружаем сохраненное значение или используем значение по умолчанию
        let savedTheme: Theme
        if let rawValue = defaults.string(forKey: Keys.appTheme),
           let theme = Theme(rawValue: rawValue) {
            savedTheme = theme
        } else {
            savedTheme = .system // значение по умолчанию
        }
        
        self.appTheme = savedTheme
        
        // Регистрация значений по умолчанию
        defaults.register(defaults: [
            Keys.appTheme: Theme.system.rawValue
        ])
    }
}


extension AppSettings {
    enum Theme: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Светлая"
            case .dark: return "Темная"
            case .system: return "Как в системе"
            }
        }
    }
}
