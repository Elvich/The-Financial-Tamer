//
//  Item.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 06.06.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
