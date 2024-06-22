//
//  Item.swift
//  ToDoapp part 1
//
//  Created by Артемий on 18.06.2024.
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
