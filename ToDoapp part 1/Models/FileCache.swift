//
//  FileCaсhe.swift
//  ToDoapp part 1
//
//  Created by Артемий on 18.06.2024.
//

import Foundation
internal class FileCache{
    public private(set) var todoItem: [String: TodoItem]
    init(todoItem: [TodoItem]) {
        self.todoItem = [:]
        for item in todoItem{
            if (self.todoItem[item.id] == nil){
                self.todoItem[item.id] = item
            }else{
                print("The item with id: \(item.id) already exists, rewriting task")
            }
        }
    }
    public func loadTasks(fileURL: URL){
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = fileContent.split(separator: "\n")
            for line in lines {
                let components = line.split(separator: "\\\\")
                if components.count == 2 {
                    let id = components[0]
                    let todoItem = TodoItem.parse(json: String(components[1]))
                    self.todoItem[String(id)] = todoItem
                }
            }
        } catch{
            print("Ошибка при загрузке словаря из файла: \(error)")
        }
    }
    public func saveTasks(fileURL: URL){
        var fileContent = "{\n"
        for (key, item) in todoItem{
            fileContent += "\(key)\\\\\(item.json)\n"
        }
        fileContent += "}\n"
        do {
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Ошибка при записи в файл: \(error)")
        }
    }
    public func addNewTask(task: TodoItem) -> Bool{
        let ans: Bool = (self.todoItem[task.id] == nil);
        self.todoItem[task.id] = task
        return ans
    }
    public func deleteTask(id: String) -> TodoItem?{
        return self.todoItem.removeValue(forKey: id)
    }
}
