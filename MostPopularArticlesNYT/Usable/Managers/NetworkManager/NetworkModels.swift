//
//  NetworkModels.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

struct ErrorMessageItem: Identifiable {
    let id = UUID()
    let message: String
    let tryAgainAction: (() -> Void)? = nil
}

public typealias Parameters = [String: Any]

struct NetworkResponse {
    let status: Int
    let time: Int
    let size: Int64
    let data: Data
    //    let cookies:
    //    let headers:
    static let empty = Self(status: 0, time: 0, size: 0, data: Data())
    static let status200 = Self(status: 200, time: 0, size: 0, data: Data())
    static let status401 = Self(status: 401, time: 0, size: 0, data: Data())
    static let status429 = Self(status: 429, time: 0, size: 0, data: Data())
    static let status500 = Self(status: 500, time: 0, size: 0, data: Data())
}
