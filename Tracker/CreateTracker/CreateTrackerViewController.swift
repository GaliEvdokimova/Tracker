//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 30.04.2025.
//

import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func createNewTracker(tracker: Tracker, category: String?)
    func updateTracker(tracker: Tracker, editingTracker: Tracker?, category: String?)
    func reloadCollectionView()
}

final class CreateTrackerViewController: UIViewController {
    weak var delegate: CreateTrackerViewControllerDelegate?
    var irregularEvent: Bool = false
    // MARK: - Private Properties
    private var editTracker: Bool?
    private var editTrackerId: UUID?
    private var editingTracker: Tracker?
    private var cellButtonText: [String] = ["Категория", "Расписание"]
    private var selectedCategory: TrackerCategory?
    private var selectedDays: [WeekDay] = []
    private let categoryViewController = CategoryViewController()
    private let colorMarshalling = UIColorMarshalling()
    private var limitTrackerNameLabelHeightConstraint: NSLayoutConstraint!
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    private var isEmojiSelected: IndexPath? = nil
    private var isColorSelected: IndexPath? = nil
    private let emojies = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝","😪"
    ]
    private let colors: [UIColor] = [
        .ypcolorSelection1, .ypcolorSelection2, .ypcolorSelection3,
        .ypcolorSelection4, .ypcolorSelection5, .ypcolorSelection6,
        .ypcolorSelection7, .ypcolorSelection8, .ypcolorSelection9,
        .ypcolorSelection10, .ypcolorSelection11, .ypcolorSelection12,
        .ypcolorSelection13, .ypcolorSelection14, .ypcolorSelection15,
        .ypcolorSelection16, .ypcolorSelection17, .ypcolorSelection18
    ]
    // MARK: - UI-Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypCustomBlack
        label.backgroundColor = .ypCustomWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 дней"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypCustomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createTrackerName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.textColor = .ypCustomBlack
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackground
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clipsToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var limitTrackerNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createTrackerTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypCustomWhite
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var createTrackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypCustomWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypCustomWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypGray
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    // MARK: - Initializers
    init(editTracker: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.editTracker = editTracker
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToHideKeyboard()
        view.backgroundColor = .ypCustomWhite
        
        setupCreateTrackerNameTextField()
        setupTableView()
        setupCollectionView()
        setupCreateTrackerView()
        setupCreateTrackerViewConstrains()
        createTrackerCollectionViewHeight()
        trackerTypeIrregularEvent()
    }
    // MARK: - Setup View
    private func setupCreateTrackerNameTextField() {
        createTrackerName.delegate = self
    }
    
    private func setupTableView() {
        createTrackerTableView.delegate = self
        createTrackerTableView.dataSource = self
        
        createTrackerTableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: "cell")
        createTrackerTableView.register(CreateTrackerCell.self,
                                        forCellReuseIdentifier: CreateTrackerCell.cellIdentifier)
    }
    
    private func setupCollectionView() {
        self.createTrackerCollectionView.delegate = self
        self.createTrackerCollectionView.dataSource = self
        
        createTrackerCollectionView.register(EmojiCollectionViewCell.self,
                                             forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        createTrackerCollectionView.register(ColorsCollectionViewCell.self,
                                             forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        createTrackerCollectionView.register(HeaderViewCell.self,
                                             forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                             withReuseIdentifier: HeaderViewCell.identifier)
        collectionViewHeightConstraint = createTrackerCollectionView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    private func setupCreateTrackerView() {
        view.backgroundColor = .ypCustomWhite
        
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        
        scrollView.addSubview(createTrackerName)
        scrollView.addSubview(limitTrackerNameLabel)
        limitTrackerNameLabel.isHidden = true
        scrollView.addSubview(createTrackerTableView)
        scrollView.addSubview(createTrackerCollectionView)
        
        scrollView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func createTrackerCollectionViewHeight() {
        createTrackerCollectionView.collectionViewLayout.invalidateLayout()
        createTrackerCollectionView.layoutIfNeeded()
        collectionViewHeightConstraint.constant = createTrackerCollectionView.contentSize.height
    }
    
    private func setupCreateTrackerViewConstrains() {
        limitTrackerNameLabelHeightConstraint = limitTrackerNameLabel.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            createTrackerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createTrackerName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createTrackerName.heightAnchor.constraint(equalToConstant: 75),
            
            limitTrackerNameLabelHeightConstraint,
            limitTrackerNameLabel.centerXAnchor.constraint(equalTo: createTrackerName.centerXAnchor),
            limitTrackerNameLabel.topAnchor.constraint(equalTo: createTrackerName.bottomAnchor),
            
            createTrackerTableView.topAnchor.constraint(equalTo: limitTrackerNameLabel.bottomAnchor, constant: 24),
            createTrackerTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createTrackerTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createTrackerTableView.heightAnchor.constraint(equalToConstant: irregularEvent ? 75 : 150),
            
            collectionViewHeightConstraint,
            createTrackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createTrackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createTrackerCollectionView.topAnchor.constraint(equalTo: createTrackerTableView.bottomAnchor, constant: 16),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.topAnchor.constraint(equalTo: createTrackerCollectionView.bottomAnchor, constant: 16)
        ])
        
        if editTracker ?? false {
            scrollView.addSubview(daysCountLabel)
            NSLayoutConstraint.activate([
                daysCountLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
                daysCountLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                createTrackerName.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 102)
            ])
        } else {
            NSLayoutConstraint.activate([
                createTrackerName.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24)
            ])
        }
    }
    // MARK: - Public Methods
    func editTracker(tracker: Tracker, category: TrackerCategory?, completedCount: Int) {
        titleLabel.text = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
        editingTracker = tracker
        editTrackerId = tracker.id
        createTrackerName.text = tracker.title
        selectedCategory = category
        selectedDays = tracker.schedule
        isEmojiSelected?.row = emojies.firstIndex(of: tracker.emoji) ?? 0
        isColorSelected?.row = colors.firstIndex(where: {
            colorMarshalling.hexString(from: $0) == colorMarshalling.hexString(from: tracker.color)
        }) ?? 0
        daysCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: ""), completedCount)
    }
    // MARK: - Private Methods
    private func trackerTypeIrregularEvent() {
        if irregularEvent == true {
            cellButtonText = ["Категория"]
            self.titleLabel.text = "Новое нерегулярное событие"
        }
    }
    
    private func updateCreateButton() {
        if createTrackerName.text?.isEmpty == true &&
            irregularEvent == false ? selectedDays.count > 0 : true &&
            isEmojiSelected != nil &&
            isColorSelected != nil
        {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypCustomBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    // MARK: - Actions
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func createButtonTapped() {
        guard let trackerName = createTrackerName.text, !trackerName.isEmpty else {
            return
        }
        guard let selectedCategory = selectedCategory else {
            return
        }
        guard let selectedEmoji = isEmojiSelected,
              let selectedColor = isColorSelected else {
            return
        }
        let emoji = emojies[selectedEmoji.row]
        let color = colors[selectedColor.row]
        
        if irregularEvent == false {
            guard !selectedDays.isEmpty else {
                return
            }
            let newTracker = Tracker(
                id: editTrackerId ?? UUID(),
                title: trackerName,
                color: color,
                emoji: emoji,
                schedule: self.selectedDays,
                pinned: false)
            if editTracker == true {
                delegate?.updateTracker(
                    tracker: newTracker,
                    editingTracker: editingTracker,
                    category: selectedCategory.title)
                delegate?.reloadCollectionView()
            } else {
                delegate?.createNewTracker(
                    tracker: newTracker,
                    category: selectedCategory.title)
                categoryViewController.categoryViewModel.addTrackerToCategory(
                    to: selectedCategory,
                    tracker: newTracker)
            }
        } else {
            let newTracker = Tracker(
                id: UUID(),
                title: trackerName,
                color: color,
                emoji: emoji,
                schedule: WeekDay.allCases,
                pinned: false)
            delegate?.createNewTracker(
                tracker: newTracker,
                category: selectedCategory.title)
            categoryViewController.categoryViewModel.addTrackerToCategory(
                to: selectedCategory,
                tracker: newTracker)
        }
        delegate?.reloadCollectionView()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maxLength = 38
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        if newText.count >= maxLength {
            limitTrackerNameLabel.isHidden = false
            limitTrackerNameLabelHeightConstraint.constant = 38
        } else {
            limitTrackerNameLabel.isHidden = true
            limitTrackerNameLabelHeightConstraint.constant = 0
        }
        updateCreateButton()
        return newText.count <= maxLength
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        createTrackerName.text = .none
        limitTrackerNameLabel.isHidden = true
        limitTrackerNameLabelHeightConstraint.constant = 0
        updateCreateButton()
        return true
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func saveSelectedDays(list: [Int]) {
        for index in list {
            self.selectedDays.append(WeekDay.allCases[index])
        }
        self.createTrackerTableView.reloadData()
    }
}
// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            categoryViewController.categoryViewModel.$selectedCategory.bind { [weak self] category in
                guard let self = self else { return }
                self.selectedCategory = category
                self.createTrackerTableView.reloadData()
            }
            present(categoryViewController, animated: true, completion: nil)
        } else
        if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true, completion: nil)
            selectedDays = []
        }
        createTrackerTableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if irregularEvent == false {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = cellButtonText[indexPath.row]
        cell.textLabel?.textColor = .ypCustomBlack
        cell.layer.masksToBounds = true
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        
        if indexPath.row == (irregularEvent ? 0 : 1) {
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: 500)
        }
        
        guard let detailTextLabel = cell.detailTextLabel else { return cell }
        detailTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        detailTextLabel.textColor = .ypGray
        
        if indexPath.row == 0 {
            detailTextLabel.text = selectedCategory?.title
        } else if indexPath.row == 1 {
            if selectedDays.count == 7 {
                detailTextLabel.text = "Каждый день"
            } else {
                detailTextLabel.text = selectedDays.map { $0.shortDaysName }.joined(separator: ", ")
            }
        }
        return cell
    }
}
// MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            cell.emojiLabel.text = emojies[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorsCollectionViewCell.identifier,
                for: indexPath) as? ColorsCollectionViewCell else { return UICollectionViewCell() }
            cell.colorView.backgroundColor = colors[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
}
// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let selectedEmoji = isEmojiSelected {
                let cell = collectionView.cellForItem(at: selectedEmoji)
                cell?.backgroundColor = .clear
            }
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.layer.cornerRadius = 16
            cell?.backgroundColor = .ypLightGray
            isEmojiSelected = indexPath
        } else if indexPath.section == 1 {
            if let selectedColor = isColorSelected {
                let cell = collectionView.cellForItem(at: selectedColor)
                cell?.layer.borderWidth = 0
                cell?.layer.borderColor = .none
            }
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell
            cell?.layer.cornerRadius = 11
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            isColorSelected = indexPath
        }
        updateCreateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = HeaderViewCell.identifier
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: id,
                                                                   for: indexPath) as! HeaderViewCell
        if indexPath.section == 0 {
            view.headerTextLabel = "Emoji"
        } else {
            view.headerTextLabel = "Цвет"
        }
        return view
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
