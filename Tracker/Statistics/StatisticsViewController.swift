//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 24.03.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: [TrackerRecord] = []
    // MARK: - UI-Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypCustomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statisticsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub statistics")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypCustomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statisticsTableView: UITableView = {
        let statisticTableView = UITableView()
        statisticTableView.separatorStyle = .none
        statisticTableView.layer.cornerRadius = 16
        statisticTableView.translatesAutoresizingMaskIntoConstraints = false
        return statisticTableView
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerRecordStore.delegate = self
        completedTrackers = trackerRecordStore.trackerRecords
        view.backgroundColor = .ypCustomWhite
        setupStatisticsTableView()
        setupStatisticsView()
        setupStatisticsViewConstrains()
        showInitialStub()
    }
    // MARK: - Setup View
    private func setupStatisticsTableView() {
        statisticsTableView.backgroundColor = .ypCustomWhite
        statisticsTableView.delegate = self
        statisticsTableView.dataSource = self
        statisticsTableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.cellIdentifier)
        statisticsTableView.reloadData()
    }
    
    private func setupStatisticsView() {
        view.backgroundColor = .ypCustomWhite
        view.addSubview(titleLabel)
        view.addSubview(statisticsImage)
        view.addSubview(statisticsLabel)
        view.addSubview(statisticsTableView)
    }
    
    private func setupStatisticsViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            statisticsImage.heightAnchor.constraint(equalToConstant: 80),
            statisticsImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statisticsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsLabel.topAnchor.constraint(equalTo: statisticsImage.bottomAnchor, constant: 8),
            
            statisticsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsTableView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    private func showInitialStub() {
        let empty = completedTrackers.isEmpty
        statisticsTableView.isHidden = empty
        statisticsImage.isHidden = !empty
        statisticsTableView.isHidden = empty
    }
}
// MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
}
// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsCell.cellIdentifier,
            for: indexPath) as? StatisticsCell else { return UITableViewCell() }
        var title = ""
        
        switch indexPath.row {
        case 0:
            title = "Лучший период"
        case 1:
            title = "Идеальные дни"
        case 2:
            title = "Трекеров завершено"
        case 3:
            title = "Среднее значение"
        default:
            break
        }
        
        showInitialStub()
        
        var count = ""
        
        switch indexPath.row {
        case 0:
            count = "0"
        case 1:
            count = "0"
        case 2:
            count = "\(completedTrackers.count)"
        case 3:
            count = "0"
        default:
            break
        }
        cell.updateCell(from: title, count: count)
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = false
        
        return cell
    }
}
// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewController: TrackerRecordStoreDelegate {
    func recordStore() {
        completedTrackers = trackerRecordStore.trackerRecords
        statisticsTableView.reloadData()
    }
}
