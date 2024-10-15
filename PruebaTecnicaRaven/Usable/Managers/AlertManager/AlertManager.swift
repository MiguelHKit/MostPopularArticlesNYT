//
//  AlertManager.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import Foundation
import UIKit

final class AlertManager: Sendable {
    static let shared = AlertManager()
    private init() {}
    func displayAlert(title: String, message: String, confirmAction: (@Sendable () -> Void)? = nil, cancelAction: (@Sendable () -> Void)? = nil) {
        Task(priority: .userInitiated) { @Sendable in
            // Alert creation
            let alert = await UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            // Confirm Action
            if let confirmAction {
                await alert.addAction(
                    UIAlertAction(title:  String(localized: "ok"), style: .default, handler: { _ in
                        confirmAction()
                    })
                )
            } else {
                await alert.addAction(
                    UIAlertAction(title: String(localized: "ok"), style: .default)
                )
            }
            // Cancel action
            if let cancelAction {
                await alert.addAction(
                    UIAlertAction(
                        title: String(localized: "cancel"),
                        style: .cancel,
                        handler: { _ in
                            cancelAction()
                        })
                )
            }
            // Present alert
            await MainActor.run {
                self.presentAlert(alert)
            }
        }
    }
    @MainActor
    func displayTextFieldAlert(title: String, message: String, onTextfieldSubmit: @escaping @Sendable (String) -> Void) {
        Task(priority: .userInitiated) { @Sendable in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            // Add textfield
            alert.addTextField { textField in
//                await MainActor.run {
                    textField.placeholder = String(localized: "generalPlaceholderMessage")
//                }
                // Observer
                let observer = NotificationCenter.default
                    .addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: nil) { _ in
                        DispatchQueue.main.async {
                            let text = textField.text ?? ""
                            let isEmpty = text.isEmpty
                            // enagle button)
                            alert.actions.first?.isEnabled = !isEmpty
                        }
                    }
                // Confirm action
                let okAction = UIAlertAction(title: String(localized: "ok"), style: .default) { _ in
                    onTextfieldSubmit(textField.text ?? "")
                    // Remover el observer
                    NotificationCenter.default.removeObserver(observer)
                }
                okAction.isEnabled = false
                alert.addAction(okAction)
                // Cancel action
                alert.addAction(UIAlertAction(title: String(localized: "cancel"), style: .cancel) { _ in
                    NotificationCenter.default.removeObserver(observer)
                })
            }
            // Present alert
            await MainActor.run {
                self.presentAlert(alert)
            }
        }
    }
    func displayExampleAlert() {
        self.displayAlert(title: "Title", message: "Message")
    }
    @MainActor
    private func presentAlert(_ alert: UIAlertController) {
        if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController != nil {
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alert, animated: true)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
}
