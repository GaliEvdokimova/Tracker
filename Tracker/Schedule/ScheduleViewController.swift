//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 30.04.2025.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func saveSelectedDays(list: [Int])
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedDays: [Int] = []
    // MARK: - UI-Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypCustomBlack
        label.backgroundColor = .ypCustomWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypCustomWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypCustomBlack
        button.addTarget(self,
                         action: #selector(doneButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypCustomWhite
        setupTableView()
        setupScheduleView()
        setupScheduleViewConstrains()
    }
    // MARK: - Actions
    @objc
    private func doneButtonTapped() {
        for (index, list) in scheduleTableView.visibleCells.enumerated() {
            guard let cell = list as? ScheduleCell else { return }
            if cell.selectedSwitcher {
                selectedDays.append(index)
            }
        }
        self.delegate?.saveSelectedDays(list: selectedDays)
        dismiss(animated: true)
    }
    // MARK: - Setup View
    private func setupTableView() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        scheduleTableView.register(ScheduleCell.self,
                                   forCellReuseIdentifier: ScheduleCell.cellIdentifier)
    }
    
    private func setupScheduleView() {
        view.backgroundColor = .ypCustomWhite
        
        view.addSubview(titleLabel)
        view.addSubview(scheduleTableView)
        view.addSubview(doneButton)
    }
    
    private func setupScheduleViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == 6 {
            tableView.separatorInset = UIEdgeInsets(top: 0,
                                                    left: 0,
                                                    bottom: 0,
                                                    right: 500)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        scheduleTableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.cellIdentifier,
            for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        
        let days = WeekDay.allCases[indexPath.row]
        
        cell.textLabel?.text = "\(days.daysName)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypCustomBlack
        cell.layer.masksToBounds = true
        return cell
    }
}

