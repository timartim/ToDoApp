//
//  NetworkingService.swift
//  ToDoapp part 1
//
//  Created by Артемий on 17.07.2024.
//

import Foundation
protocol NetworkingService{
    func getListFromServer() async -> ([TodoItem], Int) 
    func getItemFromServer(id: String) async -> TodoItem? 
    func addItemToServer(todoItem: TodoItem, revision: Int) async -> Bool 
    func updateItemOnServer(todoItem: TodoItem, revision: Int) async -> Bool 
    func deleteItemFromServer(id: String, revision: Int) async -> Bool
    func synchronizeItemsWithServer(revision: Int) async -> TodoListResponse?
}
