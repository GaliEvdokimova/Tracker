//
//  FilterCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 29.05.2025.
//

import UIKit

final class FilterCell: UITableViewCell {
    static let cellIdentifier = "FilterCell"
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

