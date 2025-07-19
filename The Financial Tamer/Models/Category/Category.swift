//
//  Category.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 07.06.2025.
//

import Foundation

struct Category: Hashable, Codable{
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


extension Character: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let first = string.first else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Пустая строка вместо Character"
            )
        }
        self = first
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }
}
