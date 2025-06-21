//
//  DateService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 21.06.2025.
//

import Foundation

final class DateService {
    
    static let shared = DateService()
    
    let dateFormatter: DateFormatter
    let calendar : Calendar
    
    let now: Date = Date()
    
    init(){
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        calendar = Calendar.current
    }
    
    func toDate(from: String) -> Date? {
        return dateFormatter.date(from: from)
    }
    
    func toString(from: Date) -> String {
        return dateFormatter.string(from: from)
    }
    
    func startOfDay(date: Date = Date()) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func endOfDay(date: Date = Date()) -> Date {
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
}
