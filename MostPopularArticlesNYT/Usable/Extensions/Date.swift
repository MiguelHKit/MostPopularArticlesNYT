//
//  Date.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import Foundation

extension Date {
    func dateFormatted(withStyle style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
