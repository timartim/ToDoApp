import UIKit

class RoundedTableViewCell: UITableViewCell {
    let categoryColorView = UIView()
    let taskLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(taskLabel)
        categoryColorView.translatesAutoresizingMaskIntoConstraints = false
        categoryColorView.layer.cornerRadius = 10
        
        categoryColorView.layer.masksToBounds = true
        contentView.addSubview(categoryColorView)
        NSLayoutConstraint.activate([
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            categoryColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryColorView.widthAnchor.constraint(equalToConstant: 20),
            categoryColorView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureRoundedCorners(for indexPath: IndexPath, tableView: UITableView) {
        let cornerRadius: CGFloat = 10.0
        let maskLayer = CAShapeLayer()
        let bounds = contentView.bounds
        var corners: UIRectCorner = []
        
        if indexPath.row == 0 {
            corners.formUnion([.topLeft, .topRight])
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.formUnion([.bottomLeft, .bottomRight])
        }
        
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        contentView.layer.mask = maskLayer
    }
    
    func configure(with item: TodoItem) {
        taskLabel.text = item.text
        if let category = item.category {
            categoryColorView.backgroundColor = category.color
        } else {
            categoryColorView.backgroundColor = .clear
        }
    }
}
