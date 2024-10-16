//
//  UIAplication.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .filter { $0 is UIWindowScene }
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }
}
