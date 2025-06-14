//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func reload()
}

final class CreateCategoryViewController: UIViewController {
    weak var delegate: CreateCategoryViewControllerDelegate?
    var existingCategory: TrackerCategory?
    private var categoryViewModel = CategoryViewModel()
    private let errorReporting = ErrorReporting()
    var isEditCategory = Bool()
    // MARK: - UI-Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypCustomBlack
        label.backgroundColor = .ypCustomWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createCategoryName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.textColor = .ypCustomBlack
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypContext
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
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypCustomWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypCustomBlack
        button.addTarget(self, action: #selector(didTapCreateCategoryButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypCustomWhite
        addTapGestureToHideKeyboard()
        setupCreateCategoryView()
        setupCreateCategoryViewConstrains()
        updateCreateCategoryButton()
    }
    // MARK: - Public Methods
    func editCategory(_ category: TrackerCategory) {
        titleLabel.text = "Редактирование категории"
        existingCategory = category
        createCategoryName.text = category.title
    }
    
    // MARK: - Actions
    @objc
    private func didTapCreateCategoryButton() {
        guard let newCategory = createCategoryName.text, !newCategory.isEmpty else {
            return
        }
        if isEditCategory {
            categoryViewModel.editCategory(category: existingCategory, title: newCategory)
        } else if categoryViewModel.checkingSavedCategory(newCategory) {
            errorReporting.showAlert(
                title: "Warning!",
                message: "This category already exists.\nPlease, create another name.",
                controller: self)
        } else {
            categoryViewModel.addCategory(newCategory)
        }
        delegate?.reload()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func updateCreateCategoryButton() {
        if createCategoryName.text?.isEmpty == true {
            createCategoryButton.isEnabled = false
            createCategoryButton.backgroundColor = .ypGray
        } else {
            createCategoryButton.isEnabled = true
            createCategoryButton.backgroundColor = .ypCustomBlack
        }
    }
    // MARK: - Setup View
    private func setupCreateCategoryView() {
        view.backgroundColor = .ypCustomWhite
        createCategoryName.delegate = self
        createCategoryName.addTarget(self,
                                     action: #selector(updateCreateCategoryButton),
                                     for: .editingChanged)
        view.addSubview(titleLabel)
        view.addSubview(createCategoryName)
        view.addSubview(createCategoryButton)
    }
    
    private func setupCreateCategoryViewConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createCategoryName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createCategoryName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createCategoryName.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            createCategoryName.heightAnchor.constraint(equalToConstant: 75),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
// MARK: - UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
    ) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        currentText.replacingCharacters(in: range, with: string)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


