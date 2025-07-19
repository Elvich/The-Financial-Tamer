//
//  Category.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 07.06.2025.
//

import Foundation

struct Category: Hashable{
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction 
}

extension Category{
    static func parse(jsonObject: Any) -> Category?{
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }

        guard let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let emojiString = dict["emoji"] as? String,
              let emoji = emojiString.first,
              let direction = dict["isIncome"] as? Bool
        else {
            print("Error parsing Categoty")
            return nil
        }

        return Category(
            id: id,
            name: name,
            emoji: emoji,
            direction: direction ? Direction.income : Direction.outcome
        )
    }
}
