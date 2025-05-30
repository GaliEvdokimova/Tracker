//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 29.05.2025.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    static let cellIdentifier = "StatisticsCell"
    // MARK: - Cell-Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        return countLabel
    }()
    
    private lazy var borderView: UIView = {
        let borderView = UIView()
        borderView.layer.cornerRadius = 16
        borderView.backgroundColor = .ypBlue
        borderView.translatesAutoresizingMaskIntoConstraints = false
        return borderView
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.colorSelection1.cgColor,
                                UIColor.colorSelection9.cgColor,
                                UIColor.colorSelection3.cgColor]
        gradientLayer.cornerRadius = 16
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    private lazy var insideView: UIView = {
        let insideView = UIView()
        insideView.layer.cornerRadius = 16
        insideView.backgroundColor = .ypWhite
        insideView.translatesAutoresizingMaskIntoConstraints = false
        return insideView
    }()
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        clipsToBounds = true
        
        addSubview(borderView)
        addSubview(insideView)
        addSubview(titleLabel)
        addSubview(countLabel)
        borderView.layer.addSublayer(gradientLayer)
        
        NSLayoutConstraint.activate([
            borderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            borderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 90),
            insideView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 1),
            insideView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -1),
            insideView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 1),
            insideView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -1),
            countLabel.leadingAnchor.constraint(equalTo: insideView.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: insideView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: insideView.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = borderView.bounds
    }
    // MARK: - Public Methods
    func updateCell(from title: String, count: String) {
        titleLabel.text = title
        countLabel.text = count
    }
}
