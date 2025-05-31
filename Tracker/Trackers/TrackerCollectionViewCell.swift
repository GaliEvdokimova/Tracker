//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Galina evdokimova on 27.03.2025.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    var trackerMenu: UIView {
        return trackerCard
    }
    static let identifier = "trackerCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private let analyticsService = AnalyticsService()
    // MARK: - UI-Elements
    // Card/Tracker
    private let trackerCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pinTrackerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pin")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackerDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Quantity management
    private let quantityManagementView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let numberOfDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButtonImage: UIImage = {
        let image = UIImage(systemName: "plus")!
        return image
    }()
    
    private let doneButtonImage: UIImage = {
        let image = UIImage(named: "Done")!
        return image
    }()
    
    private lazy var plusTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        button.tintColor = .ypWhite
        button.addTarget(self,
                         action: #selector(plusTrackerButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTrackerCollectionView()
        setupTrackerCollectionViewConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Actions
    @objc
    private func plusTrackerButtonTapped() {
        analyticsService.report(event: .click, screen: .main, item: .track)
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    // MARK: - Public Methods
    func updateTrackerDetail(
        tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        trackerCard.backgroundColor = tracker.color
        trackerDescriptionLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        self.pinTrackerImage.isHidden = tracker.pinned ? false : true
        numberOfDaysLabel.text = String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: ""), completedDays)
        plusButtonSettings()
    }
    // MARK: - Private Methods
    private func plusButtonSettings() {
        plusTrackerButton.backgroundColor = trackerCard.backgroundColor
        let plusTrackerButtonOpacity: Float = isCompletedToday ? 0.3 : 1
        plusTrackerButton.layer.opacity = plusTrackerButtonOpacity
        let image = isCompletedToday ? doneButtonImage : plusButtonImage
        plusTrackerButton.setImage(image, for: .normal)
    }
    // MARK: - Setup View
    private func setupTrackerCollectionView() {
        contentView.addSubview(trackerCard)
        contentView.addSubview(quantityManagementView)
        trackerCard.addSubview(emojiBackgroundView)
        trackerCard.addSubview(emojiLabel)
        trackerCard.addSubview(pinTrackerImage)
        trackerCard.addSubview(trackerDescriptionLabel)
        quantityManagementView.addSubview(numberOfDaysLabel)
        quantityManagementView.addSubview(plusTrackerButton)
    }
    
    private func setupTrackerCollectionViewConstrains() {
        NSLayoutConstraint.activate([
            trackerCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCard.heightAnchor.constraint(equalToConstant: 90),
            
            quantityManagementView.topAnchor.constraint(equalTo: trackerCard.bottomAnchor),
            quantityManagementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityManagementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityManagementView.heightAnchor.constraint(equalToConstant: 58),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: trackerCard.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            
            pinTrackerImage.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -4),
            pinTrackerImage.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            pinTrackerImage.heightAnchor.constraint(equalToConstant: 24),
            pinTrackerImage.widthAnchor.constraint(equalToConstant: 24),
            
            trackerDescriptionLabel.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            trackerDescriptionLabel.bottomAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: -12),
            trackerDescriptionLabel.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -12),
            
            numberOfDaysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberOfDaysLabel.centerYAnchor.constraint(equalTo: plusTrackerButton.centerYAnchor),
            
            plusTrackerButton.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 8),
            plusTrackerButton.trailingAnchor.constraint(equalTo: quantityManagementView.trailingAnchor, constant: -12),
            plusTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            plusTrackerButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
}
