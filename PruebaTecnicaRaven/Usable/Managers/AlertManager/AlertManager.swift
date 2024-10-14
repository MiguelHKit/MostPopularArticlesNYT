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
    @MainActor
    func displayAlert(title: String, message: String, confirmAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        if let confirmAction {
            alert.addAction(
                UIAlertAction(title:  String(localized: "ok"), style: .default, handler: { _ in
                    confirmAction()
                })
            )
        } else {
            alert.addAction(
                UIAlertAction(title: String(localized: "ok"), style: .default)
            )
        }
        if let cancelAction {
            alert.addAction(
                UIAlertAction(
                    title: String(localized: "cancel"),
                    style: .cancel,
                    handler: { _ in
                        cancelAction()
                    })
            )
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    @MainActor
    func displayTextFieldAlert(title: String, message: String, onTextfieldSubmit: @escaping (String) -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = String(localized: "generalPlaceholderMessage")
            // observer
            let observer = NotificationCenter.default
                .addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: nil) { _ in
                    DispatchQueue.main.async {
                        let text = textField.text ?? ""
                        let isEmpty = text.isEmpty
                        // enagle button)
                        alert.actions.first?.isEnabled = !isEmpty
                    }
                }
            // okAction
            let okAction = UIAlertAction(title: String(localized: "ok"), style: .default) { _ in
                onTextfieldSubmit(textField.text ?? "")
                // Remover el observer
                NotificationCenter.default.removeObserver(observer)
            }
            okAction.isEnabled = false
            alert.addAction(okAction)
            // cancel action
            alert.addAction(UIAlertAction(title: String(localized: "cancel"), style: .cancel) { _ in
                // Remover el observer si se cancela
                NotificationCenter.default.removeObserver(observer)
            })
        }
        // Present alert
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    @MainActor
    func displayExampleAlert() {
        self.displayAlert(title: "Title", message: "Message")
    }
}
