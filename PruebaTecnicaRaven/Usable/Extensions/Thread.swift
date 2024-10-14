//
//  Thread.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 10/10/24.
//

import Foundation

extension Thread {
    nonisolated(unsafe) static let actualCurrent = Thread.current
}
