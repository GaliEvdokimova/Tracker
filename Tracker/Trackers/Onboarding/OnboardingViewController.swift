//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - UI-Elements
    private lazy var onboardingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .ypCustomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Initializers
    init(onboardingImageName: String, onboardingText: String) {
        super.init(nibName: nil, bundle: nil)
        onboardingImageView.image = UIImage(named: onboardingImageName)
        onboardingLabel.text = onboardingText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingView()
        setupOnboardingViewConstrains()
    }
    // MARK: - Setup View
    private func setupOnboardingView() {
        view.addSubview(onboardingImageView)
        view.addSubview(onboardingLabel)
    }
    
    private func setupOnboardingViewConstrains() {
        NSLayoutConstraint.activate([
            onboardingImageView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onboardingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
}
