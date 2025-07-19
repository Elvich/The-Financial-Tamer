//
//  DateService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 21.06.2025.
//

import Foundation

final class DateService {
    
    let dateFormatter: DateFormatter
    let calendar : Calendar
    
    let now: Date = Date()
    
    init(){
        dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        
        calendar = Calendar.current
    }
    
    func toDate(from: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.date(from: from)
    }
    
    func toString(from: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: from)
    }

    func toStringDay(from: Date = Date()) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringDate = dateFormatter.string(from: from)
        return stringDate
    }
    
    func startOfDay(date: Date = Date()) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return calendar.startOfDay(for: date)
    }
    
    func endOfDay(date: Date = Date()) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
}
