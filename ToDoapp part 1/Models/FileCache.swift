//
//  FileCaсhe.swift
//  ToDoapp part 1
//
//  Created by Артемий on 18.06.2024.
//

import Foundation
import SwiftData
import CoreData

class FileCache: ObservableObject {

    public private(set) var todoItemDict: [String: TodoItem]
    public let modelContainer: ModelContainer
    init(todoItem: [TodoItem]) {
        self.todoItemDict = [:]
        for item in todoItem {
            if (self.todoItemDict[item.id] == nil) {
                self.todoItemDict[item.id] = item
            } else {
                print("The item with id: \(item.id) already exists, rewriting task")
            }
        }
        do {
            self.modelContainer = try ModelContainer(for: TodoItem.self, configurations: ModelConfiguration())
        } catch {
            fatalError("Failed to initialize model container \(error)")
        }
    }
    public func loadTasks(fileURL: URL) {
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = fileContent.split(separator: "\n")
            for line in lines {
                let components = line.split(separator: "\\\\")
                if components.count == 2 {
                    let id = components[0]
                    let todoItem = TodoItem.parse(json: String(components[1]))
                    self.todoItemDict[String(id)] = todoItem
                }
            }
        } catch {
            print("Ошибка при загрузке словаря из файла: \(error)")
        }
    }
    public func saveTasks(fileURL: URL) {
        var fileContent = "{\n"
        for (key, item) in todoItemDict {
            fileContent += "\(key)\\\\\(item.json)\n"
        }
        fileContent += "}\n"
        do {
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Ошибка при записи в файл: \(error)")
        }
    }
    public func addNewTask(task: TodoItem) -> Bool {
        let ans: Bool = (self.todoItemDict[task.id] == nil);
        self.todoItemDict[task.id] = task
        return ans
    }
    public func deleteTask(id: String) -> TodoItem? {
        return self.todoItemDict.removeValue(forKey: id)
    }
    public func insert(_ todoItem: TodoItem) async throws {
        try await MainActor.run {
            let context = modelContainer.mainContext
            context.insert(todoItem)
            addNewTask(task: todoItem)
            try context.save()
            print("Item saved locally \(todoItem)")
        }
    }
    public func updateStorage(_ todoItems: [TodoItem]) async throws {
        try await MainActor.run {
            let context = modelContainer.mainContext
            for key in todoItemDict.keys{
                context.delete(todoItemDict[key]!)
                todoItemDict.removeValue(forKey: key)
            }
            for element in todoItems {
                context.insert(element)
                todoItemDict[element.id] = element
            }
            try context.save()
        }
    }
    public func fetch() async throws -> [TodoItem] {
        return try await MainActor.run {
            let context = modelContainer.mainContext
            context.autosaveEnabled = true
            let fetchRequest = FetchDescriptor<TodoItem>()
            let result = try context.fetch(fetchRequest)
            print("DEBUG: \(context.debugDescription)")
            print("Items sucsessfully fetched: \(result)")
            return result
        }
    }

    public func delete (_ todoItem: TodoItem) async throws {
        try await MainActor.run {
            let context = modelContainer.mainContext
            context.delete(todoItem)
            try context.save()
        }
    }
    public func update (_ newTodoItem: TodoItem) async throws {
        try await MainActor.run {
            let context = modelContainer.mainContext
            var predicate: Predicate<TodoItem>?
            predicate = #Predicate { $0.id == newTodoItem.id }
            let request = FetchDescriptor<TodoItem>(predicate: predicate)
            let results = try context.fetch(request)
            if let todoItem = results.first {
                todoItem.complete = newTodoItem.complete
                todoItem.text = newTodoItem.text
                todoItem.deadline = newTodoItem.deadline
                todoItem.importancy = newTodoItem.importancy
                todoItem.category = newTodoItem.category
                todoItem.color = newTodoItem.color
                todoItem.creationDate = newTodoItem.creationDate
                todoItem.editDate = newTodoItem.editDate
                todoItem.lastUpdatedBy = newTodoItem.lastUpdatedBy
                if context.hasChanges {
                    try context.save()
                }
            } else {
                throw NSError(domain: "TodoItemErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "TodoItem not found"])
            }
            todoItemDict[newTodoItem.id] = newTodoItem
        }
    }
    func fetchTodoFilterAndSortItems(isCompleted: Bool? = nil, sortedByTitle: Bool = false) async throws -> ([TodoItem], [TodoItem]) {
        return try await MainActor.run {
            let context = modelContainer.mainContext
            var predicate: Predicate<TodoItem>?
            if let isCompleted = isCompleted {
                predicate = #Predicate { $0.complete == isCompleted }
            }
            var sortDescriptors: [SortDescriptor<TodoItem>] = []
            if sortedByTitle {
                sortDescriptors.append(SortDescriptor(\.text))
            }

            let request = FetchDescriptor<TodoItem>(predicate: predicate)
            let sortRequest = FetchDescriptor<TodoItem>(sortBy: sortDescriptors)
            return (try context.fetch(request), try context.fetch(sortRequest))
        }
    }
}
