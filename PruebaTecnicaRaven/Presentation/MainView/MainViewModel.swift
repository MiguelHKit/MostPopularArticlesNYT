//
//  MainViewModel.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation
import Observation

@MainActor
@Observable
final class MainViewModel: Sendable {
    var articles: [ArticleModel] = []
    var isLoading: Bool = true
}
