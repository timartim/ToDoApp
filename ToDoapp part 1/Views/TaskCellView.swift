//
//  TaskCellView.swift
//  ToDoapp part 1
//
//  Created by Артемий on 28.06.2024.
//

import SwiftUI
struct TaskCellView: View {
    @ObservedObject var item: TodoItem
    var showCompletedTasks: Bool
    var onToggleComplete: (Bool) -> Void
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    item.complete.toggle()
                    onToggleComplete(item.complete)
                }
            }) {
                Image(systemName: item.complete ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(item.complete ? .green : (item.importancy == .high ? .red : .gray))
                    .background(item.importancy == .high ? Color.red.opacity(0.3) : Color.clear)
                    .clipShape(Circle())
            }
            
            if item.importancy == .high {
                Text("!!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.red)
            } else if item.importancy == .low {
                Image(systemName: "arrow.down")
                    .resizable()
                    .frame(width: 11, height: 16)
                    .foregroundColor(.gray)
                    .font(.system(size: 22, weight: .bold))
            }
            
            VStack(alignment: .leading) {
                Text(item.text)
                    .foregroundColor(item.complete ? .gray : (colorScheme == .dark ? .white : .black))

                    .strikethrough(item.complete)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .animation(.easeInOut, value: item.complete)

                if let deadline = item.deadline {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text(TodoItem.formattedDateRu(deadline))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }
}


struct TaskCellView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCellView(item: TodoItem(id: "1", text: "Купить молоко", importancy: .high, complete: false, creationDate: Date()), showCompletedTasks: false, onToggleComplete: {_ in})
    }
}
