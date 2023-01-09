//
//  ShoppingListCartItemTests.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/3.
//

import XCTest

@testable import Shopping_cart

final class ShoppingListCartItemTests: XCTestCase {

  func test_GIVEN_CartItem_WHEN_addCount_THEN_getTotalPrices() {
    var item = CartItem(ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 2.00), promotion: "买二赠一")
    item.addCount()
    item.addCount()
    let price = item.totalPrice()
    XCTAssertEqual(price, 4.00)
  }

  func test_GIVEN_CartItem_WHEN_addCount_THEN_getSavePrices() {
    var item = CartItem(ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 2.00), promotion: "买二赠一")
    item.addCount()
    item.addCount()
    item.addCount()
    let price = item.savePrice()
    XCTAssertEqual(price, 2.00)
  }


  func test_GIVEN_CartItemInfo_WHEN_outputContent_THEN_getContent() {
    var item = CartItem(ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 2.00), promotion: "买二赠一")
    item.addCount()
    let result = item.outputContent()
    XCTAssertEqual(result, "名称：name1，数量：2uuit1,小计：4.0(元)\n")
  }
}
