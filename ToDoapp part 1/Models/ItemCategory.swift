//
//  ItemCategory.swift
//  ToDoapp part 1
//
//  Created by Артемий on 05.07.2024.
//

import Foundation
import UIKit
struct ItemCategory: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var color: UIColor
}
