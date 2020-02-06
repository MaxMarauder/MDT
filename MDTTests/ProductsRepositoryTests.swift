//
//  ProductsRepositoryTests.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import XCTest
@testable import MDT

class ProductsRepositoryTests: XCTestCase {
    var mockCoreDataManager: MockCoreDataManager!
    var mockAPIClient: MockAPIClient!
    var sut: ProductsRepository!

    override func setUp() {
        mockAPIClient = MockAPIClient()
        mockCoreDataManager = MockCoreDataManager()
        sut = ProductsRepository(apiClient: mockAPIClient, coreDataManager: mockCoreDataManager)
    }

    override func tearDown() {
        sut = nil
    }

    func testRequestProducts() {
        let exp = expectation(description: "Products fetched")
        sut.requestProducts { result in
            switch result {
            case .success:
                self.assert(products: self.mockCoreDataManager.savedProducts)
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testSetNote() {
        sut.set(note: "123", product: Product())
        XCTAssertEqual(mockCoreDataManager.productNote, "123")
    }
    
    private func assert(products: [APIPayload.Product]) {
        XCTAssertEqual(products.count, 2)
        XCTAssertEqual(products[0].identifier, "1")
        XCTAssertEqual(products[0].name, "QWERTY")
        XCTAssertEqual(products[0].brand, "Brand 1")
        XCTAssertEqual(products[0].original_price, 99.95)
        XCTAssertEqual(products[0].current_price, 59.95)
        XCTAssertEqual(products[0].currency, "EUR")
        XCTAssertEqual(products[0].image.id, 101)
        XCTAssertEqual(products[0].image.url, "https://qwerty/101.jpg")
        XCTAssertEqual(products[1].identifier, "2")
        XCTAssertEqual(products[1].name, "ASDFGH")
        XCTAssertEqual(products[1].brand, "Brand 2")
        XCTAssertEqual(products[1].original_price, 199.95)
        XCTAssertEqual(products[1].current_price, 199.95)
        XCTAssertEqual(products[1].currency, "USD")
        XCTAssertEqual(products[1].image.id, 201)
        XCTAssertEqual(products[1].image.url, "https://asdfgh/201.jpg")
    }
}
