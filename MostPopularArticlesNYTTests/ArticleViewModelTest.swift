//
//  ArticleViewModelTest.swift
//  PruebaTecnicaRavenTests
//
//  Created by Miguel T on 15/10/24.
//

import XCTest
@testable import MostPopularArticlesNYT

final class ArticleViewModelTest: XCTestCase {
//    private var mockService: ArticlesMockService!
//    private var vm: MainViewModel!
    
    override func setUpWithError() throws {
//        let expectation = XCTestExpectation(description: "Initialize")
//        Task {
//            self.mockService = ArticlesMockService()
//            self.vm = await MainViewModel(articlesService: self.mockService)
//            expectation.fulfill()
//        }
//        wait(for: [expectation],timeout: 1)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testInitialStateViewModel() async throws {
        // Given
        let mockService = ArticlesMockService()
        let keychainManager = KeychainManagerMock()
        let localFileManager = LocalFileManagerMock()
        let vm = await ArticlesViewModel(articlesService: mockService, keychainManager: keychainManager, localFileManager: localFileManager)
        // When
        await vm.initData()
        // Then
        let articlesAreNotEmpty = await vm.articles.isNotEmpty
        let isNotLoading = await vm.isLoading == false
        XCTAssert(isNotLoading)
        XCTAssert(articlesAreNotEmpty)
    }
    func testGetAPIKeyFromKeychain() async throws {
        // Given
        let mockService = ArticlesMockService()
        let keychainManager = KeychainManagerMock()
        let localFileManager = LocalFileManagerMock()
        let vm = await ArticlesViewModel(articlesService: mockService, keychainManager: keychainManager, localFileManager: localFileManager)
        // When
        try await vm.getAPIKeyFromKeychain()
        let apiKey = await vm.apiKeyFromKeychain
        // Then
        XCTAssertNotNil(apiKey)
        XCTAssert(apiKey!.isNotEmpty)
    }
    func testGetArticlesSuccess() async throws {
        // Given
        let mockService = ArticlesMockService()
        let keychainManager = KeychainManagerMock()
        let localFileManager = LocalFileManagerMock()
        let vm = await ArticlesViewModel(articlesService: mockService, keychainManager: keychainManager, localFileManager: localFileManager)
        // When
        await vm.getArticles()
        // Then
        let articlesAreNotEmpty = await vm.articles.isNotEmpty
        XCTAssert(articlesAreNotEmpty, "Articles are empty when they should not be")
    }
    func testGetDataLocallyWhenNoInternetConection() async throws {
        // Given
        let mockService = ArticlesMockService()
        let keychainManager = KeychainManagerMock()
        let localFileManager = LocalFileManagerMock()
        let vm = await ArticlesViewModel(articlesService: mockService, keychainManager: keychainManager, localFileManager: localFileManager)
        // When
        await vm.initData()
        await MainActor.run {
            vm.hasInternet = false
        }
        await vm.onInternetLost()
        // Then
        let articles = await vm.articles
        XCTAssert(articles.isNotEmpty, "Data empty after losing internet connection")
    }
    func testGetDataLocallyWhenInternetConectionIsRestored() async throws {
        // Given
        let mockService = ArticlesMockService()
        let keychainManager = KeychainManagerMock()
        let localFileManager = LocalFileManagerMock()
        let vm = await ArticlesViewModel(articlesService: mockService, keychainManager: keychainManager, localFileManager: localFileManager)
        // When
        await vm.initData()
        await MainActor.run {
            vm.hasInternet = false
        }
        await vm.onInternetLost()
        await MainActor.run {
            vm.hasInternet = true
        }
        await vm.onInternetRestored()
        // Then
        let articles = await vm.articles
        XCTAssert(articles.isNotEmpty, "Data empty after enabling internet connection")
    }
}
