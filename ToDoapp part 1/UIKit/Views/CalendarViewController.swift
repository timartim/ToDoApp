import Foundation
import UIKit
import SwiftUI

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var scrollView: UIScrollView!
    var selectedButton: UIButton?
    var buttons: [UIButton] = []
    let backColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
    let textColor = UIColor(red: 0.58, green: 0.58, blue: 0.55, alpha: 1)
    let scrollViewHeight: CGFloat = 75

    var onClose: (() -> Void)?
    var todoItemList = TodoItemArray(todoItems: [])

    func close() {
        onClose?()
    }

    func roundDateToHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: components)!
    }

    let tolerance: TimeInterval = 3600

    let diffrentConst = "Другое"
    var dates: [String] = []
    var data: [String: [TodoItem]] = [:]

    convenience init(todoItemList: TodoItemArray) {
        self.init()
        self.todoItemList = todoItemList
        organizeData()
    }

    func organizeData() {
        var sectionArray: Set<Date> = []
        var diffrentSection: [TodoItem] = []
        var dateDict: Dictionary<Date, [TodoItem]> = [:]
        for element in todoItemList.todoItems {
            if let deadline = element.deadline {
                let roundedDeadline = roundDateToHour(deadline)
                sectionArray.insert(roundedDeadline)
                if dateDict[roundedDeadline] != nil {
                    dateDict[roundedDeadline]?.append(element)
                } else {
                    dateDict[roundedDeadline] = [element]
                }
            } else {
                diffrentSection.append(element)
            }
        }
        dates = sectionArray.sorted().map({ TodoItem.formattedDateRu($0) })
        let sortedDateDictionary = dateDict.sorted { $0.key < $1.key }
        let mappedDictionary = sortedDateDictionary.map { (key, value) in
            (TodoItem.formattedDateRu(key), value)
        }
        data = Dictionary(uniqueKeysWithValues: mappedDictionary)
        if diffrentSection.count != 0 {
            if !dates.contains(diffrentConst) {
                dates.append(diffrentConst)
            }
            data[diffrentConst] = diffrentSection
        }
    }

    func setupSeparator() {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .lightGray
        view.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHorizontalScrollView()
        setupSeparator()
        setupTableView()
        setupBottomButton()
        view.backgroundColor = backColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight + 8),
            tableView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -66)
        ])
    }

    func setupBottomButton() {
        let button = UIButton(type: .system)
        if let image = UIImage(named: "AddNewTodoItem") {
            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            print("Ошибка: изображение 'AddNewTodoItem' не найдено")
        }
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(openSwiftUIView), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 120),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    @objc func openSwiftUIView() {
        let newItem = TodoItem()
        let isPresentingAddView = Binding<Bool>(
            get: { return true },
            set: { newValue in
                if !newValue {
                    self.dismiss(animated: true) {
                        if !newItem.text.isEmpty {
                            self.todoItemList.todoItems.append(newItem)
                            self.organizeData()
                            self.reloadData()
                        }
                    }
                }
            }
        )
        let swiftUIView = EditTaskView(item: newItem, isPresented: isPresentingAddView)
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true, completion: nil)
    }

    func setupHorizontalScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: scrollViewHeight))
        scrollView.showsHorizontalScrollIndicator = false
        let buttonWidth: CGFloat = 75
        let buttonHeight: CGFloat = scrollViewHeight

        for (index, date) in dates.enumerated() {
            let button = UIButton(type: .system)
            let split = date.split(separator: " ")
            if split.count >= 2 {
                let title = "\(split[0])\n\(split[1])"
                button.setTitle(title, for: .normal)
            } else {
                button.setTitle(date, for: .normal)
            }
            button.setTitleColor(textColor, for: .normal)
            button.setTitleColor(textColor, for: .highlighted)
            button.setTitleColor(textColor, for: .selected)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
            button.tag = index
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.tintColor = .clear
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
            button.layer.borderWidth = 0
            button.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            buttons.append(button)
        }

        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(dates.count), height: buttonHeight)
        scrollView.backgroundColor = backColor
        view.addSubview(scrollView)
        if let firstButton = buttons.first {
            selectButton(firstButton)
        }
    }

    @objc func dateButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: NSNotFound, section: sender.tag)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        selectButton(sender)
    }

    func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RoundedTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = backColor
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates[section]
        return data[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RoundedTableViewCell

        let date = dates[indexPath.section]
        let task = data[date]?[indexPath.row] ?? TodoItem()
        cell.configure(with: task)
        cell.taskLabel.text = task.text
        if task.complete {
            cell.taskLabel.textColor = .gray
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: task.text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.taskLabel.attributedText = attributeString
        } else {
            cell.taskLabel.textColor = .black
            cell.taskLabel.attributedText = nil
            cell.taskLabel.text = task.text
        }

       

        cell.configureRoundedCorners(for: indexPath, tableView: tableView)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dates[section]
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let roundedCell = cell as? RoundedTableViewCell else { return }
        roundedCell.configureRoundedCorners(for: indexPath, tableView: tableView)
        cell.contentView.backgroundColor = .white
        cell.backgroundColor = .clear
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows,
           let firstVisibleIndexPath = visibleIndexPaths.first {
            let section = firstVisibleIndexPath.section
            if section < buttons.count {
                let button = buttons[section]
                selectButton(button)
            }
        }
    }

    func selectButton(_ button: UIButton) {
        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
        buttons.forEach { btn in
            btn.backgroundColor = btn.isSelected ? UIColor(red: 0.84, green: 0.84, blue: 0.79, alpha: 1) : .clear
            btn.layer.borderWidth = btn.isSelected ? 1.5 : 0
            btn.layer.borderColor = CGColor(gray: 0.62, alpha: 1)
        }
        let buttonFrame = button.frame
        scrollView.scrollRectToVisible(buttonFrame, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Выполнено") { [self] (action, view, handler) in
            let date = dates[indexPath.section]
            let task = self.data[date]?[indexPath.row] ?? TodoItem()
            task.complete = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
            handler(true)
        }

        completeAction.backgroundColor = .systemGreen

        let configuration = UISwipeActionsConfiguration(actions: [completeAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addAction = UIContextualAction(style: .normal, title: "Не выполнено") { (action, view, handler) in
            let date = self.dates[indexPath.section]
            let task = self.data[date]?[indexPath.row] ?? TodoItem()
            task.complete = false
            tableView.reloadRows(at: [indexPath], with: .automatic)
            handler(true)
        }

        addAction.backgroundColor = .systemBlue

        let configuration = UISwipeActionsConfiguration(actions: [addAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        header.textLabel?.textColor = textColor
    }

    func reloadData() {
        organizeData()
        tableView.reloadData()
    }
}
