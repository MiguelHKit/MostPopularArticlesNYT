//
//  Optional.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import Foundation

extension Optional {
    var isNotNil: Bool {
        return self != nil
    }
}

extension Optional where Wrapped: Sequence {
    func removeOptionals() -> [Wrapped.Element] {
        return self?.compactMap { $0 } ?? []
    }
}

extension Optional where Wrapped == String {
    var unwrapped: String { self ?? "" }
}
