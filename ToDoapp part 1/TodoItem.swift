//
//  Todoitem.swift
//  ToDoapp part 1
//
//  Created by Артемий on 18.06.2024.
//

import Foundation
enum Importance: String, Equatable {
    case low
    case average
    case high
}
struct TodoItem {
    var id: String
    var text: String
    var importancy: Importance
    var deadline: Date?
    var complete: Bool
    var creationDate: Date
    var editDate: Date?
    static let dateFormatter = ISO8601DateFormatter()
    init(id: String = UUID().uuidString, text: String = "",
        importancy: Importance = .average,
        deadline: Date? = nil,
        complete: Bool = false,
        creationDate: Date = Date.now,
        editDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importancy = importancy
        self.deadline = deadline
        self.complete = complete
        self.creationDate = creationDate
        self.editDate = editDate
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
        return TodoItem(id: id, text: text, importancy: importancy, deadline: deadline, complete: complete, creationDate: creationDate, editDate: editDate)
    }
    var json: Any {
        let editDateString = editDate.map { TodoItem.dateFormatter.string(from: $0) } ?? "nil"
        return """
        {"id": "\(id)","text": "\(text)",\(importancy != .average ? "\"importancy\": \"\(importancy.rawValue)\"," : "")"deadline": "\(deadline != nil ? TodoItem.dateFormatter.string(from: deadline!) : "")","complete": \(complete),"creationDate": "\(TodoItem.dateFormatter.string(from: creationDate))","editDate": "\(editDate != nil ? TodoItem.dateFormatter.string(from: editDate!) : "")"}
        """
    }
    var csv: Any {
        let editDateString = editDate.map { TodoItem.dateFormatter.string(from: $0) } ?? "nil"
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

