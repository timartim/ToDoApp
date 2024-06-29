//
//  EditTaskView.swift
//  ToDoapp part 1
//
//  Created by Артемий on 28.06.2024.
//

import SwiftUI
struct EditTaskView: View {
    @ObservedObject var item: TodoItem
    @Binding var isPresented: Bool
    @State private var taskText: String
    @State private var importancy: Importance
    @State private var deadlineEnabled: Bool
    @State private var deadline: Date
    
    init(item: TodoItem, isPresented: Binding<Bool>) {
        self.item = item
        _isPresented = isPresented
        _taskText = State(initialValue: item.text)
        _importancy = State(initialValue: item.importancy)
        _deadlineEnabled = State(initialValue: item.deadline != nil)
        _deadline = State(initialValue: item.deadline ?? Date().addingTimeInterval(86400))
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextEditor(text: $taskText)
                    .frame(minHeight: 100, maxHeight: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                List{
                    HStack{
                        Text("Важность ")
                            
                        Picker("Важность", selection: $importancy) {
                            Text("Нет").tag(Importance.average)
                            Label("!!", systemImage: "exclamationmark.circle").tag(Importance.high)
                            Label("↓", systemImage: "arrow.down").tag(Importance.low)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Toggle("Сделать до", isOn: $deadlineEnabled)
                        .padding()
                }
                
                
                if deadlineEnabled {
                    DatePicker("Дата дедлайна", selection: $deadline, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                }

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Text("Удалить")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Дело")
                        .font(.system(size: 16, weight: .bold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !taskText.isEmpty {
                            item.text = taskText
                            item.importancy = importancy
                            item.deadline = deadlineEnabled ? deadline : nil
                            isPresented = false
                        }
                    }
                    .disabled(taskText.isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditTaskView(item: TodoItem(id: "1",text: "123", creationDate: Date()), isPresented: .constant(true))
}
