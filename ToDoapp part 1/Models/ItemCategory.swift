//
//  ItemCategory.swift
//  ToDoapp part 1
//
//  Created by Артемий on 05.07.2024.
//

import Foundation
import UIKit
struct ItemCategory: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var color: UIColor

    init(id: UUID = UUID(), name: String, color: UIColor) {
        self.id = id
        self.name = name
        self.color = color
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let colorHex = try container.decode(String.self, forKey: .color)
        color = UIColor(hex: colorHex) ?? .black
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color.toHexString(), forKey: .color)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func toHexString() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }

        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])

        return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
}
