//
//  FileCache.swift
//  ToDoapp part 1Tests
//
//  Created by Артемий on 21.06.2024.
//

import XCTest
@testable import ToDoapp_part_1
final class FileCacheTest: XCTestCase {

    var fileCache: FileCache!
        
    override func setUpWithError() throws {
        fileCache = FileCache(todoItem: [])
    }

    override func tearDownWithError() throws {
        fileCache = nil
    }

    func testAddNewTask() {
        let task = TodoItem(id: "1", text: "Test Task", importancy: .high, deadline: Date(), complete: false, creationDate: Date(), editDate: Date())
        
        let result = fileCache.addNewTask(task: task)
        XCTAssertTrue(result, "Task should be added successfully")
        XCTAssertTrue(fileCache.todoItemDict[task.id] != nil, "The task should be in the todoItems dictionary")
        let duplicateResult = fileCache.addNewTask(task: task)
        XCTAssertFalse(duplicateResult, "Duplicate task should not be added")
    }

    func testDeleteTask() {
        let task = TodoItem(id: "1", text: "Test Task", importancy: .high, deadline: Date(), complete: false, creationDate: Date(), editDate: Date())
        var _ = fileCache.addNewTask(task: task)
        
        let deletedTask = fileCache.deleteTask(id: task.id)
        XCTAssertNotNil(deletedTask, "Task should be deleted successfully")
        XCTAssertEqual(deletedTask?.id ?? (task.id + "0"), task.id, "The deleted task should match the original task")
        
        let nonExistentTask = fileCache.deleteTask(id: task.id)
        XCTAssertNil(nonExistentTask, "Deleting a non-existent task should return nil")
    }

    func testLoadTasks() {
        let fileName = "testLoadTasks.txt"
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        let loadString = """
        {
        1\\\\{"id": "1","text": "Test Task","importancy": "high","deadline": "2024-06-18T12:00:00Z","complete": true,"creationDate": "2024-06-01T09:00:00Z","editDate": "2024-06-10T14:00:00Z"}
        }
        """
        try? loadString.write(to: fileURL, atomically: true, encoding: .utf8)
        fileCache.loadTasks(fileURL: fileURL)
        let task = fileCache.todoItemDict["1"]
        XCTAssertNotNil(task, "Task should be loaded successfully")
        XCTAssertEqual(task?.id, "1", "Task id should match")
    }

    func testSaveTasks() {
        let task = TodoItem(id: "1", text: "Test Task", importancy: .high, deadline: Date(), complete: false, creationDate: Date(), editDate: Date())
        var _ = fileCache.addNewTask(task: task)
        let fileName = "testSaveTasks.txt"
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        fileCache.saveTasks(fileURL: fileURL)
        XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path), "File should be saved successfully")
        let savedData = try? Data(contentsOf: fileURL)
        XCTAssertNotNil(savedData, "Saved file data should not be nil")
        try? fileManager.removeItem(at: fileURL)
    }
    func testSaveAndLoadTask(){
        let task = TodoItem(id: "1", text: "Test Task", importancy: .high, deadline: Date(), complete: false, creationDate: Date(), editDate: Date())
        var _ = fileCache.addNewTask(task: task)
        let fileName = "testSaveTasks.txt"
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        fileCache.saveTasks(fileURL: fileURL)
        let tempFileCashe = FileCache(todoItem: [])
        tempFileCashe.loadTasks(fileURL: fileURL)
        let loadTask = tempFileCashe.todoItemDict["1"]
        XCTAssertNotNil(loadTask, "Task should be loaded successfully")
        XCTAssertEqual(loadTask?.id, "1", "Task id should match")
        try? fileManager.removeItem(at: fileURL)
    }

}
