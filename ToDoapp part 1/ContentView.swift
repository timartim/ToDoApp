import SwiftUI

struct ContentView: View {
    @StateObject private var todoItems = TodoItemArray(todoItems: [])
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var completedCount: Int = 0
    @State private var selectedItem: TodoItem?
    @State private var showAddNewButtonView: Bool = false
    @State private var showingCompletedTasks: Bool = true
    @State private var isPresentingEditView: Bool = false
    @State private var isPresentingCalendarView: Bool = false
    @State private var newItem = TodoItem(id: UUID().uuidString, text: "", importancy: .average, creationDate: Date())
    @State private var revision: Int = 0
    private let networkingService = DefaultNetworkingService()
    
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
                                            Task {
                                                await updateItemOnServer(item: item)
                                            }
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            Task {
                                                await deleteItemFromServer(id: item.id)
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
                                            Task {
                                                await updateItemOnServer(item: item)
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
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    VStack{
                        Button(action: {
                            withAnimation{
                                isPresentingCalendarView.toggle()
                            }
                        }){
                            HStack {
                                Image(systemName: "calendar")
                            }
                        }
                        .sheet(isPresented: $isPresentingCalendarView, content: {
                            CalendarViewControllerRepresentable(isPresented: $isPresentingCalendarView, todoItemList: .constant(todoItems))
                        })
                    }
                })
            })
        }
        .sheet(isPresented: $isPresentingEditView) {
            EditTaskView(item: selectedItem ?? newItem, isPresented: $isPresentingEditView)
                .onDisappear {
                    Task {
                        if let selectedItem = selectedItem {
                            if !selectedItem.text.isEmpty {
                                if !todoItems.todoItems.contains(where: { $0.id == selectedItem.id }) {
                                    todoItems.addNewTask(task: selectedItem)
                                    await addItemToServer(item: selectedItem)
                                } else {
                                    await updateItemOnServer(item: selectedItem)
                                }
                            }
                        } else if !newItem.text.isEmpty {
                            todoItems.addNewTask(task: newItem)
                            await addItemToServer(item: newItem)
                        }
                    }
                }
        }
        .onAppear {
            Task {
                await loadTodoItems()
            }
        }
    }
    
    private func addItemToServer(item: TodoItem) async {
        await checkIfDirty()
        let success = await networkingService.addItemToServer(todoItem: item, revision: revision)
        if success {
            await loadTodoItems()
        }else{
            todoItems.isDirty = true
        }
    }
    private func updateItemOnServer(item: TodoItem) async {
        await checkIfDirty()
        let success = await networkingService.updateItemOnServer(todoItem: item, revision: revision)
        if success {
            await loadTodoItems()
        }else{
            todoItems.isDirty = true
        }
    }
    
    private func deleteItemFromServer(id: String) async {
        await checkIfDirty()
        let success = await networkingService.deleteItemFromServer(id: id, revision: revision)
        if success {
            await loadTodoItems()
        }else{
            todoItems.isDirty = true
        }
    }
    
    private func loadTodoItems() async {
        let (items, rev) = await networkingService.getListFromServer()
        print("Revision before: \(revision)")
        revision = rev
        print("Revision after: \(revision)")
        DispatchQueue.main.async {
            todoItems.todoItems = items
            completedCount = items.filter { $0.complete }.count
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = todoItems.todoItems[index]
                Task {
                    await deleteItemFromServer(id: item.id)
                }
                if item.complete {
                    completedCount -= 1
                }
                todoItems.deleteTask(idx: index)
            }
        }
    }
    private func checkIfDirty() async{
        if todoItems.isDirty {
            if let answer = await networkingService.synchronizeItemsWithServer(revision: revision){
                todoItems.isDirty = true
                todoItems.todoItems = answer.list
                revision = answer.revision
            }
        }
    }
}
func createTodoItems(_ num: Int) -> [TodoItem] {
    var items = [TodoItem]()
    
    let texts = [
        "Long Task, Buy groceries for the week, including fresh vegetables, fruits, dairy products, and some snacks for the kids. Buy groceries for the week, including fresh vegetables, fruits, dairy products, and some snacks for the kids. Buy groceries for the week, including fresh vegetables, fruits, dairy products, and some snacks for the kids. Buy groceries for the week, including fresh vegetables, fruits, dairy products, and some snacks for the kids.",
        "Call mom to check in and see how she's doing. Don't forget to ask.",
        "Finish homework for the mathematics course, including all exercises from chapter 5 and review the notes for the upcoming test. Finish homework for the mathematics course, including all exercises from chapter 5 and review the notes for the upcoming test. Finish homework for the mathematics course, including all exercises from chapter 5 and review the notes for the upcoming test. Finish homework for the mathematics course, including all exercises from chapter 5 and review the notes for the upcoming test.",
        "Clean the house thoroughly, including dusting all the furniture, vacuuming the carpets, and mopping the floors.",
        "Prepare for the next quarter.",
        "Go for a walk in the park to get some fresh air and a bit of exercise. Aim for at least 30 minutes of brisk walking.",
        "Read a book on personal development.",
        "Write a blog post about the latest trends in technology and how they are impacting our daily lives. Aim for at least 1000 words.",
        "Workout session at the gym, focusing on strength training exercises. Don't forget to do a proper warm-up and cool-down.",
        "Plan the trip to the mountains for the upcoming holiday. Make a list of all the necessary gear and supplies to pack."
    ]
    
    let importanceLevels: [Importance] = [.low, .average, .high]
    
    for idx in 0..<num {
        let text = texts[idx % texts.count]
        let importance = importanceLevels[Int.random(in: 0..<importanceLevels.count)]
        let isDone = Bool.random()
        let creationDate = Date().addingTimeInterval(Double(idx) * 86400)
        let deadline = Bool.random() ? Date().addingTimeInterval(Double(idx % 12) * 86400 + 86400) : nil
        let hexColor = String(format: "#%06X", Int.random(in: 0...0xFFFFFF))
        let item = TodoItem(
            text: text,
            importancy: importance,
            deadline: deadline,
            complete: isDone,
            creationDate: creationDate,
            editDate: Date.now,
            category: nil
        )
        
        items.append(item)
    }
    
    return items
}
#Preview {
    ContentView()
}
