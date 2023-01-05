//
//  ShoppingViewModelTests.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/3.
//

import XCTest
import Combine
@testable import Shopping_cart

final class ShoppingViewModelTests: XCTestCase {

  var model: ShoppingListViewModel?
  var serviceList = MockService()
  var cancellables = Set<AnyCancellable>()

  override func setUp() {
    model = .init(listServer: serviceList)
  }


  func test_addItemtoCart_Success() {
    XCTAssertEqual(model!.items.count, 0)

    let list = ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 1.00)
    let item = shoppingItem(shoppingList: list, isPromotions: "name1")
    model!.addToCart(item)

    XCTAssertEqual(model!.items.count, 1)

    let item1 = model!.items[0]
    XCTAssertEqual(item1.shoppingList.name, "name1")
    
  }

  func test_fetchData_Success() {

    let promise = expectation(description: "fetch data")

    model!.fetchData()

    model!.$ListContents
      .sink {
        if $0.count == 2 {
          promise.fulfill()
        }
      }
      .store(in: &cancellables)

    wait(for: [promise], timeout: 1)
    XCTAssertEqual(model!.promotiosList, ["ITEM00000", "ITEM00001"])
    XCTAssertEqual(model!.ListContents[0].isPromotions, "买二赠一")
  }
}
