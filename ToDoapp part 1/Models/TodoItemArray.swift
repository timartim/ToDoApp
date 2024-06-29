//
//  TodoItemArray.swift
//  ToDoapp part 1
//
//  Created by Артемий on 28.06.2024.
//

import Foundation
class TodoItemArray: ObservableObject{
    @Published public var todoItems: [TodoItem]
    init(todoItems: [TodoItem]) {
        self.todoItems = todoItems
    }
    public func addNewTask(task: TodoItem){
        todoItems.append(task)
    }
    public func deleteTask(idx: Int){
        todoItems.remove(at: idx)
    }
    var completedCount: Int {
        print(todoItems.filter { $0.complete }.count)
        return todoItems.filter { $0.complete }.count
    }
}
