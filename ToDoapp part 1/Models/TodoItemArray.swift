//
//  TodoItemArray.swift
//  ToDoapp part 1
//
//  Created by Артемий on 28.06.2024.
//

import Foundation
class TodoItemArray: ObservableObject, Codable {
    @Published public var todoItems: [TodoItem]
    public var isDirty: Bool = false
    init(todoItems: [TodoItem] = []) {
        self.todoItems = todoItems
    }

    enum CodingKeys: String, CodingKey {
        case todoItems
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        todoItems = try container.decode([TodoItem].self, forKey: .todoItems)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(todoItems, forKey: .todoItems)
    }

    public func addNewTask(task: TodoItem) {
        todoItems.append(task)
    }

    public func deleteTask(idx: Int) {
        todoItems.remove(at: idx)
    }

    var completedCount: Int {
        print(todoItems.filter { $0.complete }.count)
        return todoItems.filter { $0.complete }.count
    }
}
