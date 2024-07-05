import SwiftUI

struct EditTaskView: View {
    @ObservedObject var item: TodoItem
    @Binding var isPresented: Bool
    @State private var taskText: String
    @State private var importancy: Importance
    @State private var deadlineEnabled: Bool
    @State private var deadline: Date
    @State private var category: ItemCategory?
    @State private var selectedCategoryColor: Color = .black
    @State private var categories: [ItemCategory] = [
        ItemCategory(name: "Work", color: .blue),
        ItemCategory(name: "Personal", color: .green)
    ]
    @State private var showNewCategoryFields = false
    @State private var newCategoryName: String = ""

    init(item: TodoItem, isPresented: Binding<Bool>) {
        self.item = item
        _isPresented = isPresented
        _taskText = State(initialValue: item.text)
        _importancy = State(initialValue: item.importancy)
        _deadlineEnabled = State(initialValue: item.deadline != nil)
        _deadline = State(initialValue: item.deadline ?? Date().addingTimeInterval(86400))
        _category = State(initialValue: item.category)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextEditor(text: $taskText)
                    .frame(minHeight: 100, maxHeight: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)

                List {
                    HStack {
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
                    Picker("Категория", selection: Binding(
                        get: { category?.name ?? "None" },
                        set: { newValue in
                            if newValue == "None" {
                                category = nil
                            } else if let selectedCategory = categories.first(where: { $0.name == newValue }) {
                                category = selectedCategory
                                selectedCategoryColor = Color(selectedCategory.color)
                            }
                        }
                    )) {
                        Text("None").tag("None")
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    .padding()
                    if let category = category {
                        HStack {
                            Text("Цвет категории")
                            Spacer()
                            Circle()
                                .fill(Color(category.color))
                                .frame(width: 20, height: 20)
                        }
                        .padding()
                    }
                    if showNewCategoryFields {
                        TextField("Имя новой категории", text: $newCategoryName)
                            .padding()
                        ColorPicker("Цвет новой категории", selection: $selectedCategoryColor)
                            .padding()
                        Button("Добавить категорию") {
                            let newCategory = ItemCategory(name: newCategoryName, color: UIColor(selectedCategoryColor))
                            categories.append(newCategory)
                            category = newCategory
                            showNewCategoryFields = false
                            newCategoryName = ""
                        }
                        .padding()
                    } else {
                        Button("Создать новую категорию") {
                            showNewCategoryFields = true
                        }
                        .padding()
                    }
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
                            item.category = category
                            isPresented = false
                        }
                    }
                    .disabled(taskText.isEmpty)
                }
            }
        }
    }
}

struct EditTaskView_Previews: PreviewProvider {
    static var previews: some View {
        EditTaskView(item: TodoItem(id: "1", text: "123", creationDate: Date()), isPresented: .constant(true))
    }
}
