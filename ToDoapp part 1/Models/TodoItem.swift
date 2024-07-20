//
//  Todoitem.swift
//  ToDoapp part 1
//
//  Created by Артемий on 18.06.2024.
//

import Foundation
import SwiftData

enum Importance: String, Codable {
    case low
    case average
    case high

    private enum CodingKeys: String, CodingKey {
        case low = "low"
        case average = "basic"
        case high = "important"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case CodingKeys.low.rawValue:
            self = .low
        case CodingKeys.average.rawValue:
            self = .average
        case CodingKeys.high.rawValue:
            self = .high
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid importance value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .low:
            try container.encode(CodingKeys.low.rawValue)
        case .average:
            try container.encode(CodingKeys.average.rawValue)
        case .high:
            try container.encode(CodingKeys.high.rawValue)
        }
    }
}

class TodoItem: Identifiable, ObservableObject, Codable {
    var id: String
    var text: String
    var importancy: Importance
    var deadline: Date?
    @Published var complete: Bool
    var creationDate: Date
    var editDate: Date
    var color: String?
    var lastUpdatedBy: String
    var category: ItemCategory?

    static let dateFormatter = ISO8601DateFormatter()

    static func formattedDateRu(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    init(id: String = UUID().uuidString, text: String = "", importancy: Importance = .average, deadline: Date? = nil, complete: Bool = false, creationDate: Date = Date(), editDate: Date = Date(), color: String? = nil, lastUpdatedBy: String = "1", category: ItemCategory? = nil) {
        self.id = id
        self.text = text
        self.importancy = importancy
        self.deadline = deadline
        self.complete = complete
        self.creationDate = creationDate
        self.editDate = editDate
        self.color = color
        self.lastUpdatedBy = lastUpdatedBy
        self.category = category
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importancy = "importance"
        case deadline
        case complete = "done"
        case creationDate = "created_at"
        case editDate = "changed_at"
        case color
        case lastUpdatedBy = "last_updated_by"
        case category = "category_info"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        importancy = try container.decode(Importance.self, forKey: .importancy)
        if let deadlineTimestamp = try container.decodeIfPresent(Int.self, forKey: .deadline) {
            deadline = Date(timeIntervalSince1970: TimeInterval(deadlineTimestamp))
        } else {
            deadline = nil
        }
        complete = try container.decode(Bool.self, forKey: .complete)
        let creationDateTimestamp = try container.decode(Int.self, forKey: .creationDate)
        creationDate = Date(timeIntervalSince1970: TimeInterval(creationDateTimestamp))
        let editDateTimestamp = try container.decode(Int.self, forKey: .editDate)
        editDate = Date(timeIntervalSince1970: TimeInterval(editDateTimestamp))
        color = try container.decodeIfPresent(String.self, forKey: .color)
        lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
        category = try container.decodeIfPresent(ItemCategory.self, forKey: .category)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importancy, forKey: .importancy)
        if let deadline = deadline {
            try container.encode(Int(deadline.timeIntervalSince1970), forKey: .deadline)
        }
        try container.encode(complete, forKey: .complete)
        try container.encode(Int(creationDate.timeIntervalSince1970), forKey: .creationDate)
        try container.encode(Int(editDate.timeIntervalSince1970), forKey: .editDate)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
        try container.encodeIfPresent(category, forKey: .category)
    }
}
extension TodoItem {
    static private func getTodoitemFromDict(dict: [String: Any]) -> TodoItem? {
        guard let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let creationDateString = dict["creationDate"] as? String,
              let creationDate = TodoItem.dateFormatter.date(from: creationDateString) else {
            return nil
        }
        let complete: Bool
        if let completeBool = dict["complete"] as? Bool {
            complete = completeBool
        } else if let completeString = dict["complete"] as? String {
            complete = (completeString as NSString).boolValue
        } else {
            return nil
        }
        let editDate: Date?
        if let editDateString = dict["editDate"] as? String {
            editDate = TodoItem.dateFormatter.date(from: editDateString)
        } else {
            editDate = nil
        }
        let deadline: Date?
        if let deadlineString = dict["deadline"] as? String {
            deadline = TodoItem.dateFormatter.date(from: deadlineString)
        } else{
            deadline = nil
        }
        let importancyRaw = dict["importancy"] as? String ?? "average"
        guard let importancy = Importance(rawValue: importancyRaw) else { return nil }
        return TodoItem(id: id, text: text, importancy: importancy, deadline: deadline, complete: complete, creationDate: creationDate, editDate: editDate ?? Date.now)
    }
    var json: Any {
        return """
        {"id": "\(id)","text": "\(text)",\(importancy != .average ? "\"importancy\": \"\(importancy.rawValue)\"," : "")"deadline": "\(deadline != nil ? TodoItem.dateFormatter.string(from: deadline!) : "")","complete": \(complete),"creationDate": "\(TodoItem.dateFormatter.string(from: creationDate))","editDate": "\(editDate != nil ? TodoItem.dateFormatter.string(from: editDate) : "")"}
        """
    }
    var csv: Any {
        let editDateString =  TodoItem.dateFormatter.string(from: editDate)
        return """
                id,text,importancy,deadline,complete,creationDate,editDate\n
                \(id),\(text),\(importancy),\(deadline != nil ? TodoItem.dateFormatter.string(from: deadline!) : ""),\(complete),\(TodoItem.dateFormatter.string(from: creationDate)),\(editDateString)
                """
    }
    static func parse(csv: Any) -> TodoItem? {
        guard let csvString = csv as? String else {
            return nil
        }
        let lines = csvString.split(separator: "\n")
        var todoItemDict: [String: Any] = [:]
        if lines.count == 2 {
            let columns = lines[0].split(separator: ",")
            let values = lines[1].split(separator: ",")
            if(columns.count != values.count) {
                return nil
            }
            var idx = 0
            for column in columns {
                todoItemDict[String(column)] = String(values[idx])
                idx += 1
            }
            return getTodoitemFromDict(dict: todoItemDict)
        }
        return nil
    }
    static func parse(json: Any) -> TodoItem? {
        guard let jsonString = json as? String else {
            return nil
        }
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return getTodoitemFromDict(dict: jsonObject)
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
        return nil
    }
}

