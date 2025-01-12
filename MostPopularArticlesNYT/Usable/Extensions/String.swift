//
//  String.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import Foundation

enum DateFormat: String {
    case yyyyMMddHHHyphen = "yyyy-MM-dd"
    case yyyyMMddHHSlash = "yyyy/MM/dd"
    case yyyyMMddHHmmssHyphen = "yyyy-MM-dd HH:mm:ss"
    case yyyyMMddHHmmssSlash = "yyyy/MM/dd HH:mm:ss"
    case ISO8601 = "yyyy-mm-ddthh:mm:ssZ"
}

extension String {
    var isNotEmpty: Bool { !isEmpty }
    func toDate(format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self) ?? Date()
    }
    func mapfromNYTAspectRatio() -> CGFloat {
        switch self {
        case "mediumThreeByTwo210": return 3/2
        default: return 1
        }
    }
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
