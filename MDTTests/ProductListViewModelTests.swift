//
//  ProductListViewModelTests.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 13.08.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import XCTest
@testable import MDT

class ProductListViewModelTests: XCTestCase {
    var mockAppCoordinator: MockAppCoordinator!
    lazy var mockProductsRepository: MockProductsRepository = {
        return mockAppCoordinator.repositories.productsRepository as! MockProductsRepository
    }()
    var sut: ProductListViewModel!
    
    override func setUp() {
        mockAppCoordinator = MockAppCoordinator()
        sut = ProductListViewModel(withCoordinator: mockAppCoordinator)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func testRefresh() {
        let exp = expectation(description: "Refreshed")
        sut.refresh {
            XCTAssertEqual(self.mockProductsRepository.requestProductsCount, 1)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testFilter() {
        let exp = expectation(description: "Products fetched")
        sut.onProductsFetched = {
            exp.fulfill()
        }
        sut.filter(with: "abc")
        waitForExpectations(timeout: 1.0)
    }
    
    func testOpenDetails() {
        sut.openDetails(product: Product())
        XCTAssertEqual(self.mockAppCoordinator.navigateCount, 1)
    }
}
