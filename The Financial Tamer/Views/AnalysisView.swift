import UIKit

// MARK: - AnalysisViewController
class AnalysisViewController: UIViewController {
    
    // MARK: - Properties
    private let direction: Direction
    private let transactionService: TransactionsService
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
    
    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - Initialization
    init(direction: Direction, transactionService: TransactionsService) {
        self.direction = direction
        let monthAgo = dateService.calendar.date(byAdding: .month, value: -1, to: dateService.now)!
        self.startDate = dateService.startOfDay(date: monthAgo)
        self.endDate = dateService.endOfDay()
        self.transactionService = transactionService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        setupTableView()
        setupNavigationBar()
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
    
    private func setupNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.backgroundColor = .clear
        navBar.prefersLargeTitles = false
    }
    
    // MARK: - Data Management
    private func reloadData() {
        Task{
            transactions = try await transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
            transactions = sortTransactions(transactions, sortType)
            tableView.reloadData()
        }
    }
    
    private func sortTransactions(_ transactions: [Transaction], _ sortType: SortType) -> [Transaction] {
        switch sortType {
        case .date:
            return transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return transactions.sorted { $0.amount > $1.amount }
        }
    }
    
    private func updateDateRange(start: Date, end: Date) {
        startDate = dateService.startOfDay(date: start)
        endDate = dateService.endOfDay(date: end)
        
        // Ensure valid date range
        if startDate > endDate {
            endDate = startDate
        } else if endDate < startDate {
            startDate = endDate
        }
    }
    
    // MARK: - Date Picker
    private func showDatePicker(
        date: Date,
        minimumDate: Date?,
        maximumDate: Date?,
        onDateSelected: @escaping (Date) -> Void
    ) {
        let overlay = OverlayDatePickerView(
            date: date,
            minimumDate: minimumDate,
            maximumDate: maximumDate
        )
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.onDateSelected = onDateSelected
        overlay.onDismiss = { [weak overlay] in
            overlay?.removeFromSuperview()
        }
        view.addSubview(overlay)
    }
    
    // MARK: - Actions
    @objc private func showErrorView() {
        let alert = UIAlertController(
            title: nil,
            message: "Скоро здесь будет что-то интересное!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension AnalysisViewController: UITableViewDataSource {
    
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
        guard let section = Section(rawValue: indexPath.section) else { 
            return UITableViewCell() 
        }
        
        switch section {
        case .filters:
            return createFilterCell(for: indexPath)
        case .transactions:
            return createTransactionCell(for: indexPath)
        }
    }
    
    private func createFilterCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseId, for: indexPath) as! FilterCell
        
        let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        let currency = transactions.first?.account.currency ?? "RUB"
        
        cell.configure(
            startDate: startDate,
            endDate: endDate,
            sortType: sortType,
            total: total,
            currency: currency,
            onStartDateChanged: { [weak self] date in
                self?.updateDateRange(start: date, end: self?.endDate ?? date)
            },
            onEndDateChanged: { [weak self] date in
                self?.updateDateRange(start: self?.startDate ?? date, end: date)
            },
            onSortTypeChanged: { [weak self] type in
                self?.sortType = type
            },
            currencyService: currencyService,
            onShowStartPicker: { [weak self] in
                self?.showDatePicker(
                    date: self?.startDate ?? Date(),
                    minimumDate: nil,
                    maximumDate: nil,
                    onDateSelected: { [weak self] date in
                        self?.updateDateRange(start: date, end: self?.endDate ?? date)
                        self?.tableView.reloadData()
                    }
                )
            },
            onShowEndPicker: { [weak self] in
                self?.showDatePicker(
                    date: self?.endDate ?? Date(),
                    minimumDate: nil,
                    maximumDate: nil,
                    onDateSelected: { [weak self] date in
                        self?.updateDateRange(start: self?.startDate ?? date, end: date)
                        self?.tableView.reloadData()
                    }
                )
            }
        )
        
        cell.selectionStyle = .none
        return cell
    }
    
    private func createTransactionCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        
        // Clear old subviews to avoid reuse issues
        cell.contentView.subviews.forEach { subview in
            if subview.tag == 998 || subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
        
        // Main content
        cell.textLabel?.text = "\(transaction.category.emoji)  \(transaction.category.name)"
        cell.detailTextLabel?.text = nil
        
        // Add amount and percentage on the right
        let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        let percent = calculatePercentage(transaction.amount, of: total)
        
        let percentLabel = createRightLabel(
            text: String(format: "%.1f%%", percent),
            tag: 998,
            position: .top
        )
        
        let amountLabel = createRightLabel(
            text: "\(transaction.amount) \(currencyService.getSymbol(for: transaction.account.currency))",
            tag: 999,
            position: .bottom
        )
        
        cell.contentView.addSubview(percentLabel)
        cell.contentView.addSubview(amountLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            percentLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            percentLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            amountLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 2),
            amountLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
        ])
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func createRightLabel(text: String, tag: Int, position: LabelPosition) -> UILabel {
        let label = UILabel()
        label.tag = tag
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.textAlignment = .right
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func calculatePercentage(_ amount: Decimal, of total: Decimal) -> Double {
        guard total != 0 else { return 0 }
        return (NSDecimalNumber(decimal: amount).doubleValue / NSDecimalNumber(decimal: total).doubleValue) * 100
    }
}

// MARK: - UITableViewDelegate
extension AnalysisViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        
        switch section {
        case .filters:
            return nil
        case .transactions:
            return "Операции"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else { 
            return UITableView.automaticDimension 
        }
        
        switch section {
        case .filters:
            return UITableView.automaticDimension
        case .transactions:
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), section == .transactions else { 
            return 
        }
        tableView.deselectRow(at: indexPath, animated: true)
        showErrorView()
    }
}

// MARK: - Supporting Types
extension AnalysisViewController {
    enum SortType: String, CaseIterable {
        case date = "дате"
        case amount = "сумме"
    }
    
    private enum Section: Int, CaseIterable {
        case filters
        case transactions
    }
    
    private enum LabelPosition {
        case top
        case bottom
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
    
    // MARK: - UI Components
    private let startDateButton = UIButton(type: .system)
    private let endDateButton = UIButton(type: .system)
    private let sortSegmented = UISegmentedControl(items: AnalysisViewController.SortType.allCases.map { $0.rawValue })
    private let totalTitleLabel = UILabel()
    private let totalValueLabel = UILabel()
    
    // MARK: - Callbacks
    private var onStartDateChanged: ((Date) -> Void)?
    private var onEndDateChanged: ((Date) -> Void)?
    private var onSortTypeChanged: ((AnalysisViewController.SortType) -> Void)?
    private var onShowStartPicker: (() -> Void)?
    private var onShowEndPicker: (() -> Void)?
    private var currencyService: CurrencyService?
    
    // MARK: - Constants
    private let filterRowVerticalPadding: CGFloat = 5
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        let background = createBackgroundView()
        let stack = createMainStack()
        
        background.addSubview(stack)
        contentView.addSubview(background)
        
        setupConstraints(background: background, stack: stack)
    }
    
    private func createBackgroundView() -> UIView {
        let background = UIView()
        background.backgroundColor = .systemBackground
        background.layer.cornerRadius = 16
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }
    
    private func createMainStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(createDateRow(title: "Период: Начало", button: startDateButton, action: #selector(startDateButtonTapped)))
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(createDateRow(title: "Период: Конец", button: endDateButton, action: #selector(endDateButtonTapped)))
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(createSortRow())
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(createTotalRow())
        
        return stack
    }
    
    private func createDateRow(title: String, button: UIButton, action: Selector) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20)
            button.configuration = config
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
        }
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [label, spacer, button])
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding, left: 0, bottom: filterRowVerticalPadding, right: 0)
        stack.setCustomSpacing(8, after: label)
        
        return stack
    }
    
    private func createSortRow() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding + 2, left: 0, bottom: filterRowVerticalPadding + 2, right: 0)
        
        let label = UILabel()
        label.text = "Сортировать по"
        sortSegmented.addTarget(self, action: #selector(sortTypeChanged), for: .valueChanged)
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(sortSegmented)
        
        return stack
    }
    
    private func createTotalRow() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: filterRowVerticalPadding, left: 0, bottom: filterRowVerticalPadding, right: 0)
        
        totalTitleLabel.text = "Сумма"
        totalTitleLabel.font = .systemFont(ofSize: 18)
        totalValueLabel.font = .systemFont(ofSize: 18)
        totalValueLabel.textAlignment = .right
        
        stack.addArrangedSubview(totalTitleLabel)
        stack.addArrangedSubview(UIView()) // spacer
        stack.addArrangedSubview(totalValueLabel)
        
        return stack
    }
    
    private func setupConstraints(background: UIView, stack: UIStackView) {
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
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return separator
    }
    
    // MARK: - Configuration
    func configure(
        startDate: Date,
        endDate: Date,
        sortType: AnalysisViewController.SortType,
        total: Decimal,
        currency: String,
        onStartDateChanged: @escaping (Date) -> Void,
        onEndDateChanged: @escaping (Date) -> Void,
        onSortTypeChanged: @escaping (AnalysisViewController.SortType) -> Void,
        currencyService: CurrencyService,
        onShowStartPicker: (() -> Void)? = nil,
        onShowEndPicker: (() -> Void)? = nil
    ) {
        self.onStartDateChanged = onStartDateChanged
        self.onEndDateChanged = onEndDateChanged
        self.onSortTypeChanged = onSortTypeChanged
        self.currencyService = currencyService
        self.onShowStartPicker = onShowStartPicker
        self.onShowEndPicker = onShowEndPicker
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        
        startDateButton.setTitle(formatter.string(from: startDate), for: .normal)
        endDateButton.setTitle(formatter.string(from: endDate), for: .normal)
        sortSegmented.selectedSegmentIndex = AnalysisViewController.SortType.allCases.firstIndex(of: sortType) ?? 0
        totalValueLabel.text = "\(total) \(currencyService.getSymbol(for: currency))"
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Actions
    @objc private func startDateButtonTapped() {
        onShowStartPicker?()
    }
    
    @objc private func endDateButtonTapped() {
        onShowEndPicker?()
    }
    
    @objc private func sortTypeChanged() {
        if let selected = AnalysisViewController.SortType.allCases[safe: sortSegmented.selectedSegmentIndex] {
            onSortTypeChanged?(selected)
        }
    }
}

// MARK: - OverlayDatePickerView
class OverlayDatePickerView: UIView {
    
    // MARK: - Properties
    var onDateSelected: ((Date) -> Void)?
    var onDismiss: (() -> Void)?
    
    private let picker = UIDatePicker()
    private let container = UIView()
    
    // MARK: - Initialization
    init(date: Date, minimumDate: Date?, maximumDate: Date?) {
        super.init(frame: .zero)
        setupUI(date: date, minimumDate: minimumDate, maximumDate: maximumDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI(date: Date, minimumDate: Date?, maximumDate: Date?) {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = date
        picker.minimumDate = minimumDate
        picker.maximumDate = maximumDate
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(picker)
        addSubview(container)
        
        setupGestureRecognizer()
        setupConstraints()
    }
    
    private func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        tap.cancelsTouchesInView = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.widthAnchor.constraint(equalToConstant: 340),
            
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !container.frame.contains(location) {
            onDismiss?()
            removeFromSuperview()
        }
    }
    
    @objc private func dateChanged() {
        onDateSelected?(picker.date)
    }
}

// MARK: - SwiftUI Wrapper
#if canImport(SwiftUI)
import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    
    @EnvironmentObject var appDependency: AppDependency
    
    let direction: Direction

    func makeUIViewController(context: Context) -> UIViewController {
        AnalysisViewController(direction: direction, transactionService: appDependency.transactionsService)
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
    .environmentObject(AppDependency())
}

#endif
