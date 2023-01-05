//
//  ShoppingListModelTests.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/3.
//

import XCTest

@testable import Shopping_cart

final class ShoppingListModelTests: XCTestCase {

  func test_TotalPrices() {
    var item = CartItem(ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 2.00), promotion: "买二赠一")
    item.addCount()
    item.addCount()
    let price = item.totalPrice()
    XCTAssertEqual(price, 4.00)
  }


}
