//
//  CurrencyService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

final class CurrencyService {
    
    private let currencies: [String: String] = [
        "RUB": "₽",
        "USD": "$",
        "EUR": "€",
        "GBP": "£",
        "CNY": "¥",
        "JPY": "¥",
        "KRW": "₩",
        "INR": "₹",
        "BRL": "R$",
        "CAD": "C$",
        "AUD": "A$",
        "CHF": "CHF",
        "SEK": "kr",
        "NOK": "kr",
        "DKK": "kr",
        "PLN": "zł",
        "CZK": "Kč",
        "HUF": "Ft",
        "RON": "lei",
        "BGN": "лв"
    ]
    
    func getSymbol(for code: String) -> String {
        return currencies[code.uppercased()] ?? code
    }
    
} 
