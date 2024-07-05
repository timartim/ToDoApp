//
//  CalendarViewControllerRepresentable.swift
//  ToDoapp part 1
//
//  Created by Артемий on 03.07.2024.
//

import Foundation
import UIKit
import SwiftUI
struct CalendarViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var todoItemList: TodoItemArray
    let diffrentConst = "Другое"
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController(todoItemList: todoItemList)
    }
    
    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
    }
}
