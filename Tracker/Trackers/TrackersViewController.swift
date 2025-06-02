//
//  ViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 22.03.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private var trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    private let errorReporting = ErrorReporting()
    private var trackers: [Tracker] = []
    private var pinnedTrackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var pinnedCategory: TrackerCategory?
    private let pinnedCategoryName = "Закрепленные"
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private var selectedDay: Int?
    private var filterText: String?
    private var currentFilterMode: Filters = .allTrackers
    private let analyticsService = AnalyticsService()
    // MARK: - UI-Elements
    private lazy var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .date
        date.preferredDatePickerStyle = .compact
        date.calendar.firstWeekday = 2
        date.addTarget(self, action: #selector(dateSelection), for: .valueChanged)
        date.locale = Locale(identifier: "ru_RU")
        date.tintColor = .ypBlue
        date.clipsToBounds = true
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("searchBar.placeholder", comment: "")
        searchController.searchBar.searchTextField.clearButtonMode = .never
        searchController.searchBar.setValue(NSLocalizedString("cancel.button", comment: ""), forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .ypBlue
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var initialImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub tracker")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var initialLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.initial.label.text", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypCustomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub search")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.nothing.found", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypCustomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filter.title", comment: ""),
                        for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(filterButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypCustomWhite
        addTapGestureToHideKeyboard()
        dateFiltering()
        coreDataSetup()
        reloadVisibleCategories(filterCompletedTrackers: nil)
        if trackerStore.trackers.count > 0 {
            showSearchStub()
        } else {
            showInitialStub()
        }
        setupNavBar()
        setupTrackersView()
        setupCollectionView()
        setupTrackersViewConstrains()
        filterButtonVisibility()
        analyticsService.report(event: Event.open, screen: Screen.main)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, screen: .main)
    }
    // MARK: - CoreDataSetup
    private func coreDataSetup() {
        trackerStore.delegate = self
        trackers = trackerStore.trackers.filter { !$0.pinned }
        pinnedTrackers = trackerStore.trackers.filter { $0.pinned }
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.trackerCategories
        trackerRecordStore.delegate = self
        completedTrackers = trackerRecordStore.trackerRecords
    }
    // MARK: - Setup View
    private func setupNavBar() {
        navigationItem.title = NSLocalizedString("app.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .ypCustomBlack
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Add tracker"),
            style: .plain,
            target: self,
            action: #selector(didTapAddTrackerButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchResultsUpdater = self
    }
    
    private func setupTrackersView() {
        view.backgroundColor = .ypCustomWhite
        
        view.addSubview(initialImage)
        view.addSubview(initialLabel)
        view.addSubview(searchImage)
        view.addSubview(searchLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(HeaderViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderViewCell.identifier)
    }
    
    private func setupTrackersViewConstrains() {
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
            initialImage.heightAnchor.constraint(equalToConstant: 80),
            initialImage.widthAnchor.constraint(equalToConstant: 80),
            initialImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialLabel.topAnchor.constraint(equalTo: initialImage.bottomAnchor, constant: 8),
            
            searchImage.heightAnchor.constraint(equalToConstant: 80),
            searchImage.widthAnchor.constraint(equalToConstant: 80),
            searchImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            searchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchLabel.topAnchor.constraint(equalTo: searchImage.bottomAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    // MARK: - Actions
    @objc
    private func didTapAddTrackerButton() {
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.trackersViewController = self
        present(addTrackerViewController, animated: true, completion: nil)
        analyticsService.report(event: .click, screen: .main, item: .add_track)
    }
    
    @objc
    private func dateSelection() {
        dateFiltering()
        filterNotActive()
        showSearchStub()
        collectionView.reloadData()
        filteringTrackers()
    }
    @objc
    private func filterButtonTapped() {
        analyticsService.report(event: .click, screen: .main, item: .filter)
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        present(filterViewController, animated: true, completion: nil)
    }
    // MARK: - Private Methods
    private func showInitialStub() {
        let emptyVisibleCategories = trackerStore.trackers.count > 0 ||
        visibleCategories.isEmpty
        collectionView.isHidden = emptyVisibleCategories
        searchImage.isHidden = emptyVisibleCategories
        searchLabel.isHidden = emptyVisibleCategories
        filterButtonVisibility()
    }
    
    private func filterButtonVisibility() {
        let shouldShowFilterButton = trackerStore.trackers.count > 0
        filterButton.isHidden = !shouldShowFilterButton
        collectionView.reloadData()
    }
    
    private func showSearchStub() {
        let emptyVisibleCategories = visibleCategories.isEmpty
        collectionView.isHidden = emptyVisibleCategories
        initialImage.isHidden = true
        initialLabel.isHidden = true
        searchImage.isHidden = !emptyVisibleCategories
        searchLabel.isHidden = !emptyVisibleCategories
    }
    
    private func dateFiltering() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        self.selectedDay = filterWeekday
    }
    
    private func filteringTrackers() {
        reloadVisibleCategories(filterCompletedTrackers: nil)
        showSearchStub()
        collectionView.reloadData()
    }
    
    private func filterNotActive() {
        switch currentFilterMode {
        case .allTrackers:
            reloadVisibleCategories(filterCompletedTrackers: nil)
        case .trackersToday:
            reloadVisibleCategories(filterCompletedTrackers: nil)
        case .completedTrackers:
            reloadVisibleCategories(filterCompletedTrackers: true)
        case .unCompletedTrackers:
            reloadVisibleCategories(filterCompletedTrackers: false)
        }
    }
    
    private func reloadVisibleCategories(filterCompletedTrackers: Bool?) {
        pinnedCategory = TrackerCategory(title: pinnedCategoryName, trackers: pinnedTrackers)
        categories = trackerCategoryStore.trackerCategories
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = tracker.title.contains(filterText ?? "") ||
                (filterText ?? "").isEmpty
                let dateCondition = tracker.schedule.contains { day in
                    guard let currentDate = self.selectedDay else {
                        return true
                    }
                    return day.rawValue == currentDate
                }
                var pinnedCondition = true
                if category.title != pinnedCategoryName {
                    pinnedCondition = tracker.pinned == false
                }
                guard let filterCompletedTrackers = filterCompletedTrackers else {
                    return textCondition && dateCondition && pinnedCondition
                }
                let completedTracker = completedTrackers.first { trackerRecord in
                    let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
                    return tracker.id == trackerRecord.trackerId && isSameDay
                } != nil
                let filterCondition = completedTracker == filterCompletedTrackers
                
                return textCondition && dateCondition && pinnedCondition && filterCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                title: category.title,
                trackers: trackers)
        }
        if let pinCategory = pinnedCategory, !pinCategory.trackers.isEmpty {
            visibleCategories.insert(pinCategory, at: 0)
        }
        filterButtonVisibility()
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.trackerId == id && isSameDay
    }
}
// MARK: - UISearchControllerDelegate
extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        dateFiltering()
    }
}
// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterText = searchController.searchBar.searchTextField.text?.description
        filteringTrackers()
    }
}
// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func store() {
        let trackerStore = trackerStore.trackers
        trackers = trackerStore.filter { !$0.pinned }
        pinnedTrackers = trackerStore.filter { $0.pinned }
        filterNotActive()
        collectionView.reloadData()
    }
}
// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func categoryStore() {
        categories = trackerCategoryStore.trackerCategories
        collectionView.reloadData()
    }
}
// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func recordStore() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}
// MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let selectedDate = datePicker.date
        let currentCalendar = Calendar.current
        let trackerRecord = TrackerRecord(trackerId: id, date: selectedDate)
        
        guard currentCalendar.compare(selectedDate,
                                      to: currentDate,
                                      toGranularity: .day
        ) == .orderedDescending else {
            do {
                try self.trackerRecordStore.addTrackerRecord(trackerRecord)
            } catch {
                errorReporting.showAlert(
                    title: "Error!",
                    message: "Error add a record to TrackerRecord: \(error)",
                    controller: self)
            }
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let uncomplete = completedTrackers.first {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
        do {
            if let removeComplete = uncomplete {
                try self.trackerRecordStore.deleteTrackerRecord(removeComplete)
            }
        } catch {
            errorReporting.showAlert(
                title: "Error!",
                message: "Error deleting a record TrackerRecord: \(error)",
                controller: self)
        }
    }
}
// MARK: - CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func createNewTracker(tracker: Tracker, category: String?) {
        guard let newCategory = category else { return }
        let savedCategory = self.categories.first { category in
            category.title == newCategory
        }
        if savedCategory != nil {
            self.categories = self.categories.map { category in
                if (category.title == newCategory) {
                    var updateTrackers = category.trackers
                    updateTrackers.append(tracker)
                    return TrackerCategory(title: category.title, trackers: updateTrackers)
                } else {
                    return TrackerCategory(title: category.title, trackers: category.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(title: newCategory, trackers: [tracker]))
        }
        filteringTrackers()
    }
    
    func updateTracker(tracker: Tracker, editingTracker: Tracker?, category: String?) {
        guard let category = category, let editingTracker = editingTracker else { return }
        try? self.trackerStore.editTracker(tracker, editingTracker: editingTracker)
        let foundCategory = self.categories.first { ctgry in
            ctgry.title == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { ctgry in
                if (ctgry.title == category) {
                    var updatedTrackers = ctgry.trackers
                    updatedTrackers.append(tracker)
                    return TrackerCategory(title: ctgry.title, trackers: updatedTrackers)
                } else {
                    return TrackerCategory(title: ctgry.title, trackers: ctgry.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(title: category, trackers: [tracker]))
        }
        filteringTrackers()
    }
    
    func reloadCollectionView() {
        filteringTrackers()
    }
}
// MARK: - FilterViewControllerDelegate
extension TrackersViewController: FilterViewControllerDelegate {
    func allTrackers() {
        currentFilterMode = .allTrackers
        reloadVisibleCategories(filterCompletedTrackers: nil)
        collectionView.reloadData()
    }
    
    func trackersToday() {
        currentFilterMode = .trackersToday
        datePicker.date = currentDate
        dateFiltering()
        filteringTrackers()
    }
    
    func completedTrackersToday() {
        currentFilterMode = .completedTrackers
        reloadVisibleCategories(filterCompletedTrackers: true)
        showSearchStub()
        collectionView.reloadData()
    }
    
    func unCompletedTrackersToday() {
        currentFilterMode = .unCompletedTrackers
        reloadVisibleCategories(filterCompletedTrackers: false)
        showSearchStub()
        collectionView.reloadData()
    }
}
// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        cell.contentView.backgroundColor = .clear
        cell.prepareForReuse()
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        
        let isCopletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count
        
        cell.updateTrackerDetail(
            tracker: tracker,
            isCompletedToday: isCopletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
}
// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
        let index = "\(indexPath.row):\(indexPath.section)" as NSString
        let configuration = UIContextMenuConfiguration(identifier: index,
                                                       previewProvider: nil) { _ -> UIMenu? in
            var pinAction: UIAction
            if !tracker.pinned {
                pinAction = UIAction(title: "Закрепить", handler: { [weak self] _ in
                    guard let self = self else { return }
                    do {
                        try self.trackerStore.pinTracker(tracker, value: true)
                    } catch {
                        errorReporting.showAlert(
                            title: "Error!",
                            message: "Ошибка закрепления трекера",
                            controller: self)
                    }
                })
            } else {
                pinAction = UIAction(title: "Открепить", handler: { [weak self] _ in
                    guard let self = self else { return }
                    do {
                        try self.trackerStore.pinTracker(tracker, value: false)
                        if trackerStore.trackers.count > 0 {
                            self.showSearchStub()
                        } else {
                            self.showInitialStub()
                        }
                    } catch {
                        errorReporting.showAlert(
                            title: "Error!",
                            message: "Ошибка открепления трекера",
                            controller: self)
                    }
                })
            }
            
            let editAction = UIAction(title: "Редактировать", handler: { [weak self] _ in
                guard let self = self else { return }
                let createTrackerViewController = CreateTrackerViewController(editTracker: true)
                createTrackerViewController.delegate = self
                createTrackerViewController.editTracker(
                    tracker: tracker,
                    category: self.categories.first {
                        $0.trackers.contains {
                            $0.id == tracker.id
                        }
                    },
                    completedCount: self.completedTrackers.filter {
                        $0.trackerId == tracker.id
                    }.count
                )
                self.collectionView.reloadData()
                self.present(createTrackerViewController, animated: true)
            })
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                let alertController = UIAlertController(
                    title: nil,
                    message: "Уверены что хотите удалить трекер?",
                    preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(
                    title: "Удалить",
                    style: .destructive) { _ in
                        do {
                            try self.trackerStore.deleteTracker(tracker)
                        } catch {
                            self.errorReporting.showAlert(
                                title: "Error!",
                                message: "Ошибка удаления трекера",
                                controller: self)
                        }
                        self.reloadVisibleCategories(filterCompletedTrackers: nil)
                        self.showInitialStub()
                        self.showSearchStub()
                    }
                alertController.addAction(deleteAction)
                
                let cancelAction = UIAlertAction(
                    title: "Отменить",
                    style: .cancel,
                    handler: nil)
                
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
        self.collectionView.reloadData()
        return configuration
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else {
            return nil
        }
        let components = identifier.components(separatedBy: ":")
        guard let rowString = components.first,
              let sectionString = components.last,
              let row = Int(rowString),
              let section = Int(sectionString) else {
            return nil
        }
        let indexPath = IndexPath(row: row, section: section)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        return UITargetedPreview(view: cell.trackerMenu)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String = ""
        if case UICollectionView.elementKindSectionHeader = kind {
            id = HeaderViewCell.identifier
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath) as! HeaderViewCell
        
        guard indexPath.section < visibleCategories.count else {
            return view
        }
        
        let headerText = visibleCategories[indexPath.section].title
        view.headerTextLabel = headerText
        return view
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 41) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
