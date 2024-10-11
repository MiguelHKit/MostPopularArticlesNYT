//
//  AlertManager.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import Foundation
import UIKit

final class AlertManager {
    static let shared = AlertManager()
    private init() {}
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    func displayExampleAlert() {
        self.displayAlert(title: "Title", message: "Message")
    }
}
