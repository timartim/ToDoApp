//
//  TodoitemTest.swift
//  ToDoapp part 1Tests
//
//  Created by Артемий on 21.06.2024.
//

import XCTest
@testable import ToDoapp_part_1
final class TodoItemTest: XCTestCase {
    func testInitialization() throws {
        let todo = TodoItem(
            id: "1",
            text: "Test Task",
            importancy: .high,
            deadline: Date(timeIntervalSince1970: 1622563200),
            complete: false,
            creationDate: Date(timeIntervalSince1970: 1622563200),
            editDate: nil
        )

        XCTAssertEqual(todo.id, "1")
        XCTAssertEqual(todo.text, "Test Task")
        XCTAssertEqual(todo.importancy, .high)
        XCTAssertEqual(todo.deadline, Date(timeIntervalSince1970: 1622563200))
        XCTAssertFalse(todo.complete)
        XCTAssertEqual(todo.creationDate, Date(timeIntervalSince1970: 1622563200))
        XCTAssertNil(todo.editDate)
    }
    func testExample() throws {

    }
    func testInitializationFromJSON() throws {
        let jsonString = """
        {
            "id": "123",
            "text": "Complete project",
            "importancy": "high",
            "deadline": "2024-06-18T12:00:00Z",
            "complete": true,
            "creationDate": "2024-06-01T09:00:00Z",
            "editDate": "2024-06-10T14:00:00Z"
        }
        """

        guard let todo = TodoItem.parse(json: jsonString) else {
            XCTFail("Failed to initialize TodoItem from JSON")
            return
        }

        XCTAssertEqual(todo.id, "123")
        XCTAssertEqual(todo.text, "Complete project")
        XCTAssertEqual(todo.importancy, .high)
        XCTAssertEqual(todo.deadline, TodoItem.dateFormatter.date(from: "2024-06-18T12:00:00Z"))
        XCTAssertTrue(todo.complete)
        XCTAssertEqual(todo.creationDate, TodoItem.dateFormatter.date(from: "2024-06-01T09:00:00Z"))
        XCTAssertEqual(todo.editDate, TodoItem.dateFormatter.date(from: "2024-06-10T14:00:00Z"))
    }
    func testInitializationFromCSV() throws {
        let csvData = """
                        id,text,importancy,deadline,complete,creationDate,editDate\n
                        123,Complete project,high,2024-06-18T12:00:00Z,true,2024-06-01T09:00:00Z,2024-06-10T14:00:00Z
                        """
        guard let todo = TodoItem.parse(csv: csvData) else {
            XCTFail("Failed to initialize TodoItem from CSV")
            return
        }
        XCTAssertEqual(todo.id, "123")
        XCTAssertEqual(todo.text, "Complete project")
        XCTAssertEqual(todo.importancy, .high)
        XCTAssertEqual(todo.deadline, TodoItem.dateFormatter.date(from: "2024-06-18T12:00:00Z"))
        XCTAssertTrue(todo.complete)
        XCTAssertEqual(todo.creationDate, TodoItem.dateFormatter.date(from: "2024-06-01T09:00:00Z"))
        XCTAssertEqual(todo.editDate, TodoItem.dateFormatter.date(from: "2024-06-10T14:00:00Z"))
        
        
        print("1234")
    }
}
