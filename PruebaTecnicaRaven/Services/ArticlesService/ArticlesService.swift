//
//  ArticlesService.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

protocol ArticlesServiceProtocol {
    
}
// MARK: PROD Service
actor ArticlesService: ArticlesServiceProtocol {
    let mainURL: String = NetworkManager.BASE_URL
}
// MARK: MOCK Service
actor ArticlesMockService: ArticlesServiceProtocol {
    
}
