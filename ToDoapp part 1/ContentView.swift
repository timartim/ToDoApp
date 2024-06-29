import SwiftUI

struct ContentView: View {
    @StateObject private var todoItems = TodoItemArray(todoItems: [
        ])
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var completedCount: Int = 0
    @State private var selectedItem: TodoItem?
    @State private var showAddNewButtonView: Bool = false
    @State private var showingCompletedTasks: Bool = true
    @State private var isPresentingEditView: Bool = false
    @State private var newItem = TodoItem(id: UUID().uuidString, text: "", importancy: .average, creationDate: Date())

    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color(red: 0.09, green: 0.09, blue: 0.09, opacity: 1.0)
                    .edgesIgnoringSafeArea(.all) : Color(red: 0.97, green: 0.97, blue: 0.95, opacity: 1.0)
                    .edgesIgnoringSafeArea(.all))
                

                VStack {
                    HStack {
                        Text("Выполнено \(completedCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showingCompletedTasks.toggle()
                            }
                        }) {
                            Text(showingCompletedTasks ? "Скрыть" : "Показать")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top)
                        }
                    }
                        .padding(.horizontal)

                    ZStack {
                        Color.white
                            .cornerRadius(15)
                        List {
                            ForEach(todoItems.todoItems) { item in
                                if showingCompletedTasks || !item.complete {
                                    TaskCellView(item: item, showCompletedTasks: showingCompletedTasks) { isComplete in
                                        withAnimation {
                                            if isComplete {
                                                completedCount += 1
                                            } else {
                                                completedCount -= 1
                                            }
                                        }
                                    }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                if let index = todoItems.todoItems.firstIndex(where: { $0.id == item.id }) {
                                                    todoItems.deleteTask(idx: index)
                                                }
                                            } label: {
                                                Label("", systemImage: "trash")
                                            }
                                            Button {
                                                selectedItem = item
                                                isPresentingEditView = true
                                            } label: {
                                                Label("", systemImage: "info.circle")
                                            }
                                                .tint(.gray)
                                        
                                    }
                                        .swipeActions(edge: .leading) {
                                        Button {
                                            withAnimation {
                                                item.complete.toggle()
                                                if item.complete {
                                                    completedCount += 1
                                                } else {
                                                    completedCount -= 1
                                                }
                                            }
                                        } label: {
                                            Label("Complete", systemImage: "checkmark")
                                        }
                                            .tint(.green)
                                    }
                                        .transition(.slide)
                                        .animation(.easeInOut, value: showingCompletedTasks)
                                }
                            }
                                .onDelete(perform: deleteItems)
                        }
                            .listStyle(PlainListStyle())
                            .cornerRadius(15)
                    }
                        .padding(.horizontal)

                    Spacer()
                }

                VStack {
                    Spacer()
                    Button(action: {
                        newItem = TodoItem(id: UUID().uuidString, text: "", importancy: .average, creationDate: Date())
                        isPresentingEditView = true
                    }) {
                        Image("AddNewTodoItem")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 104, height: 104)
                            .padding()
                    }
                }
                    .edgesIgnoringSafeArea(.bottom)
            }
                .navigationTitle("Мои дела")
        }
            .sheet(isPresented: $isPresentingEditView) {
            EditTaskView(item: selectedItem ?? newItem, isPresented: $isPresentingEditView)
                .onDisappear {
                if let selectedItem = selectedItem {
                    if !selectedItem.text.isEmpty {
                        if !todoItems.todoItems.contains(where: { $0.id == selectedItem.id }) {
                            todoItems.addNewTask(task: selectedItem)
                        }
                    }
                } else if !newItem.text.isEmpty {

                    todoItems.addNewTask(task: newItem)
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = TodoItem(id: UUID().uuidString, text: "New Task", creationDate: Date())
            todoItems.addNewTask(task: newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = todoItems.todoItems[index]
                if item.complete {
                    completedCount -= 1
                }
                todoItems.deleteTask(idx: index)
            }
        }
    }
}
#Preview {
    ContentView()
}
