//
//  ProductDetailsViewModelTests.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 06.02.20.
//  Copyright © 2020 Maksym Kershengolts. All rights reserved.
//

import XCTest
@testable import MDT

class ProductDetailsViewModelTests: XCTestCase {
    var mockAppCoordinator: MockAppCoordinator!
    lazy var mockProductsRepository: MockProductsRepository = {
        return mockAppCoordinator.repositories.productsRepository as! MockProductsRepository
    }()
    var sut: ProductDetailsViewModel!
    
    override func setUp() {
        mockAppCoordinator = MockAppCoordinator()
        sut = ProductDetailsViewModel(withCoordinator: mockAppCoordinator, product: Product())
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func testSetNote() {
        sut.set(note: "abc")
        XCTAssertEqual(self.mockProductsRepository.setNoteCount, 1)
    }
}
