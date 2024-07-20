//
//  NetworkingService.swift
//  ToDoapp part 1
//
//  Created by Артемий on 17.07.2024.
//

import Foundation
protocol NetworkingService{
    func getListFromServer() async -> ([TodoItem], String)
    func getItemFromServer(id: String) async -> TodoItem?
    func addItemToServer(todoItem: TodoItem, revision: String) async -> Bool
    func updateItemOnServer(todoItem: TodoItem) async -> Bool
    func deleteItemFromServer(id: String) async -> Bool
    func synchronizeItemsWithServer(revision: String) async -> Bool
}
