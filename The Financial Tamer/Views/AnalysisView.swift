import UIKit

class AnalysisViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let direction: Direction
    private let transactionService = TransactionsService()
    private let dateService = DateService()
    private let currencyService = CurrencyService()
    
    private var sortType: SortType = .date {
        didSet { reloadData() }
    }
    private var startDate: Date {
        didSet { reloadData() }
    }
    private var endDate: Date {
        didSet { reloadData() }
    }
    
    private var transactions: [Transaction] = []
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let totalLabel = UILabel()
    private let sortSegmented = UISegmentedControl(items: SortType.allCases.map { $0.rawValue })
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    init(direction: Direction) {
        self.direction = direction
        let monthAgo = dateService.calendar.date(byAdding: .month, value: -1, to: dateService.now)!
        self.startDate = dateService.startOfDay(date: monthAgo)
        self.endDate = dateService.endOfDay()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        reloadData()

        
        if let navBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.backgroundColor = .clear
            navBar.prefersLargeTitles = false
        }
    }
    
    
    @objc private func showErrorView() {
        let alert = UIAlertController(title: nil, message: "Скоро здесь будет что-то интересное!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func startDateChanged() {
        startDate = dateService.startOfDay(date: startDatePicker.date)
        if startDate > endDate {
            endDate = startDate
            endDatePicker.date = endDate
        }
    }
    
    @objc private func endDateChanged() {
        endDate = dateService.endOfDay(date: endDatePicker.date)
        if endDate < startDate {
            startDate = endDate
            startDatePicker.date = startDate
        }
    }
    
    @objc private func sortTypeChanged() {
        if let selected = SortType.allCases[safe: sortSegmented.selectedSegmentIndex] {
            sortType = selected
        }
    }
    
    private func reloadData() {
        transactions = transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
        transactions = sortTransactions(transactions, sortType)
        let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        let currency = transactions.first?.account.currency ?? "RUB"
        totalLabel.text = "Сумма: \(total) \(currencyService.getSymbol(for: currency))"
        tableView.reloadData()
    }
    
    private func sortTransactions(_ transactions: [Transaction], _ sortType: SortType) -> [Transaction] {
        switch sortType {
        case .date:
            return transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return transactions.sorted { $0.amount > $1.amount }
        }
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .filters:
            return 1
        case .transactions:
            return transactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .filters:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseId, for: indexPath) as! FilterCell
            cell.configure(
                startDate: startDate,
                endDate: endDate,
                sortType: sortType,
                total: transactions.reduce(Decimal.zero) { $0 + $1.amount },
                currency: transactions.first?.account.currency ?? "RUB",
                onStartDateChanged: { [weak self] date in
                    guard let self = self else { return }
                    self.startDate = self.dateService.startOfDay(date: date)
                    if self.startDate > self.endDate {
                        self.endDate = self.startDate
                    }
                },
                onEndDateChanged: { [weak self] date in
                    guard let self = self else { return }
                    self.endDate = self.dateService.endOfDay(date: date)
                    if self.endDate < self.startDate {
                        self.startDate = self.endDate
                    }
                },
                onSortTypeChanged: { [weak self] type in
                    guard let self = self else { return }
                    self.sortType = type
                },
                currencyService: currencyService
            )
            cell.selectionStyle = .none
            return cell
        case .transactions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
            let transaction = transactions[indexPath.row]
            // Основной текст
            cell.textLabel?.text = "\(transaction.category.emoji)  \(transaction.category.name)"
            cell.detailTextLabel?.text = nil
            // Добавим сумму и процент справа
            let rightLabelTag = 999
            let percentLabelTag = 998
            let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
            let percent: Double = (total != 0) ? (NSDecimalNumber(decimal: transaction.amount).doubleValue / NSDecimalNumber(decimal: total).doubleValue) * 100 : 0
            let percentText = String(format: "%.1f%%", percent)
            var percentLabel: UILabel!
            var rightLabel: UILabel!
            if let label = cell.contentView.viewWithTag(percentLabelTag) as? UILabel {
                percentLabel = label
                percentLabel.text = percentText
            } else {
                percentLabel = UILabel()
                percentLabel.tag = percentLabelTag
                percentLabel.font = .systemFont(ofSize: 17)
                percentLabel.textColor = .label
                percentLabel.textAlignment = .right
                percentLabel.text = percentText
                percentLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(percentLabel)
            }
            if let label = cell.contentView.viewWithTag(rightLabelTag) as? UILabel {
                rightLabel = label
                rightLabel.text = "\(transaction.amount) \(currencyService.getSymbol(for: transaction.account.currency))"
            } else {
                rightLabel = UILabel()
                rightLabel.tag = rightLabelTag
                rightLabel.font = .systemFont(ofSize: 17)
                rightLabel.textColor = .label
                rightLabel.textAlignment = .right
                rightLabel.text = "\(transaction.amount) \(currencyService.getSymbol(for: transaction.account.currency))"
                rightLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(rightLabel)
            }
            // Constraints: процент над суммой
            NSLayoutConstraint.deactivate(percentLabel.constraints)
            NSLayoutConstraint.deactivate(rightLabel.constraints)
            NSLayoutConstraint.activate([
                percentLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                percentLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                rightLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 2),
                rightLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    // MARK: - TableView Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        switch section {
        case .filters:
            return nil
        case .transactions:
            return "Операции"
        }
    }
    
    // MARK: - TableView Delegate (height)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else { return UITableView.automaticDimension }
        switch section {
        case .filters:
            return UITableView.automaticDimension
        case .transactions:
            return 56 // Можно увеличить до 60-64 если нужно больше места
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), section == .transactions else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        showErrorView()
    }
}

extension AnalysisViewController {
    enum SortType: String, CaseIterable {
        case date = "дате"
        case amount = "сумме"
    }
    
    private enum Section: Int, CaseIterable {
        case filters
        case transactions
    }
}

// MARK: - Safe Array Indexing
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 

// MARK: - FilterCell
class FilterCell: UITableViewCell {
    static let reuseId = "FilterCell"
    private let filterRowVerticalPadding: CGFloat = 5
    private let startDateButton = UIButton(type: .system)
    private let endDateButton = UIButton(type: .system)
    private var startDate: Date = Date()
    private var endDate: Date = Date()
    private let sortSegmented = UISegmentedControl(items: AnalysisViewController.SortType.allCases.map { $0.rawValue })
    private let totalTitleLabel = UILabel()
    private let totalValueLabel = UILabel()
    private var onStartDateChanged: ((Date) -> Void)?
    private var onEndDateChanged: ((Date) -> Void)?
    private var onSortTypeChanged: ((AnalysisViewController.SortType) -> Void)?
    private var currencyService: CurrencyService?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let background = UIView()
        background.backgroundColor = .systemBackground
        background.layer.cornerRadius = 16
        background.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Start
        let startLabel = UILabel()
        startLabel.text = "Период: Начало"
        startLabel.setContentHuggingPriority(.required, for: .horizontal)
        startLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        startDateButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        startDateButton.layer.cornerRadius = 8
        startDateButton.clipsToBounds = true
        startDateButton.setTitleColor(.label, for: .normal)
        startDateButton.titleLabel?.font = .systemFont(ofSize: 17)
        startDateButton.setContentHuggingPriority(.required, for: .horizontal)
        startDateButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        startDateButton.addTarget(self, action: #selector(startDateButtonTapped), for: .touchUpInside)
        startDateButton.translatesAutoresizingMaskIntoConstraints = false
        startDateButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
        let startSpacer = UIView()
        startSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        startSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let startStack = UIStackView(arrangedSubviews: [startLabel, startSpacer, startDateButton])
        startStack.axis = .horizontal
        startStack.spacing = 0
        startStack.alignment = .center
        startStack.isLayoutMarginsRelativeArrangement = true
        startStack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding, left: 0, bottom: filterRowVerticalPadding, right: 0)
        startStack.setCustomSpacing(8, after: startLabel)
        
        // End
        let endLabel = UILabel()
        endLabel.text = "Период: Конец"
        endLabel.setContentHuggingPriority(.required, for: .horizontal)
        endLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        endDateButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        endDateButton.layer.cornerRadius = 8
        endDateButton.clipsToBounds = true
        endDateButton.setTitleColor(.label, for: .normal)
        endDateButton.titleLabel?.font = .systemFont(ofSize: 17)
        endDateButton.setContentHuggingPriority(.required, for: .horizontal)
        endDateButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        endDateButton.addTarget(self, action: #selector(endDateButtonTapped), for: .touchUpInside)
        endDateButton.translatesAutoresizingMaskIntoConstraints = false
        endDateButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
        let endSpacer = UIView()
        endSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        endSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let endStack = UIStackView(arrangedSubviews: [endLabel, endSpacer, endDateButton])
        endStack.axis = .horizontal
        endStack.spacing = 0
        endStack.alignment = .center
        endStack.isLayoutMarginsRelativeArrangement = true
        endStack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding, left: 0, bottom: filterRowVerticalPadding, right: 0)
        endStack.setCustomSpacing(8, after: endLabel)
        
        // Sort
        let sortStack = UIStackView()
        sortStack.axis = .horizontal
        sortStack.spacing = 8
        sortStack.isLayoutMarginsRelativeArrangement = true
        sortStack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding+2, left: 0, bottom: filterRowVerticalPadding+2, right: 0)
        let sortLabel = UILabel()
        sortLabel.text = "Сортировать по"
        sortSegmented.addTarget(self, action: #selector(sortTypeChanged), for: .valueChanged)
        sortStack.addArrangedSubview(sortLabel)
        sortStack.addArrangedSubview(sortSegmented)
        
        // Total (two labels on ends)
        let totalStack = UIStackView()
        totalStack.axis = .horizontal
        totalStack.spacing = 8
        totalStack.isLayoutMarginsRelativeArrangement = true
        totalStack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding, left: 0, bottom: filterRowVerticalPadding, right: 0)
        totalTitleLabel.text = "Сумма"
        totalTitleLabel.font = .systemFont(ofSize: 18)
        totalValueLabel.font = .systemFont(ofSize: 18)
        totalValueLabel.textAlignment = .right
        totalStack.addArrangedSubview(totalTitleLabel)
        totalStack.addArrangedSubview(UIView()) // spacer
        totalStack.addArrangedSubview(totalValueLabel)

        stack.addArrangedSubview(startStack)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(endStack)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(sortStack)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(totalStack)

        background.addSubview(stack)
        contentView.addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            stack.topAnchor.constraint(equalTo: background.topAnchor),
            stack.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: background.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(
        startDate: Date,
        endDate: Date,
        sortType: AnalysisViewController.SortType,
        total: Decimal,
        currency: String,
        onStartDateChanged: @escaping (Date) -> Void,
        onEndDateChanged: @escaping (Date) -> Void,
        onSortTypeChanged: @escaping (AnalysisViewController.SortType) -> Void,
        currencyService: CurrencyService
    ) {
        self.onStartDateChanged = onStartDateChanged
        self.onEndDateChanged = onEndDateChanged
        self.onSortTypeChanged = onSortTypeChanged
        self.currencyService = currencyService
        self.startDate = startDate
        self.endDate = endDate
        updateDateButtons()
        sortSegmented.selectedSegmentIndex = AnalysisViewController.SortType.allCases.firstIndex(of: sortType) ?? 0
        totalValueLabel.text = "\(total) \(currencyService.getSymbol(for: currency))"
    }
    
    private func updateDateButtons() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        startDateButton.setTitle(formatter.string(from: startDate), for: .normal)
        endDateButton.setTitle(formatter.string(from: endDate), for: .normal)
    }

    @objc private func startDateButtonTapped() {
        showDatePickerDialog(isStart: true)
    }
    @objc private func endDateButtonTapped() {
        showDatePickerDialog(isStart: false)
    }

    private func showDatePickerDialog(isStart: Bool) {
        guard let parentVC = self.parentViewController else { return }
        let alert = UIAlertController(title: isStart ? "Выберите начало" : "Выберите конец", message: nil, preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = isStart ? startDate : endDate
        picker.maximumDate = isStart ? endDate : nil
        picker.minimumDate = isStart ? nil : startDate
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 48),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.heightAnchor.constraint(equalToConstant: 216)
        ])
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Выбрать", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if isStart {
                self.startDate = picker.date
                self.updateDateButtons()
                self.onStartDateChanged?(self.startDate)
            } else {
                self.endDate = picker.date
                self.updateDateButtons()
                self.onEndDateChanged?(self.endDate)
            }
        }))
        parentVC.present(alert, animated: true)
    }

    // Helper to get parent view controller
    private var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let vc = responder as? UIViewController {
                return vc
            }
            parentResponder = responder.next
        }
        return nil
    }

    @objc private func sortTypeChanged() {
        if let selected = AnalysisViewController.SortType.allCases[safe: sortSegmented.selectedSegmentIndex] {
            onSortTypeChanged?(selected)
        }
    }

    private func makeSeparator() -> UIView {
        let sep = UIView()
        sep.backgroundColor = .separator
        sep.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return sep
    }
}

// MARK: - SwiftUI Wrapper
#if canImport(SwiftUI)
import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction

    func makeUIViewController(context: Context) -> UIViewController {
        AnalysisViewController(direction: direction)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No-op
    }
}

#Preview {
    NavigationStack {
        AnalysisViewControllerWrapper(direction: .outcome)
            .navigationTitle("Анализ")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#endif
