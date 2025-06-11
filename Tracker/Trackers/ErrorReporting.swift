//
//  ErrorReporting.swift
//  Tracker
//
//  Created by Galina evdokimova on 18.05.2025.
//

import UIKit

final class ErrorReporting {
    func showAlert(title: String, message: String, controller: UIViewController) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        controller.present(alert, animated: true, completion: nil)
    }
}
