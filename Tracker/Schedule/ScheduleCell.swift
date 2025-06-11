//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.03.2025.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    static let cellIdentifier = "scheduleCell"
    var selectedSwitcher = false
    
    private lazy var switcher: UISwitch = {
        let swith = UISwitch()
        swith.onTintColor = .ypBlue
        swith.addTarget(self,
                        action: #selector(switcherTapped),
                        for: .touchUpInside)
        swith.translatesAutoresizingMaskIntoConstraints = false
        return swith
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .ypContext
        clipsToBounds = true
        
        addSubview(switcher)
        self.accessoryView = switcher
        
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func switcherTapped(_ sender: UISwitch) {
        self.selectedSwitcher = sender.isOn
    }
}
