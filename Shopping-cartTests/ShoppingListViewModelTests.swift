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
  
  var model: ShoppingListViewModel!
  var serviceList = MockService()
  var coredataManager = MockCoreDataManager()
  var cancellables = Set<AnyCancellable>()
  
  override func setUp() {
    model = .init(listServer: serviceList, coredataManager: coredataManager)
    coredataManager.deleteAll()
    // Test if coredata function been called
    XCTAssertTrue(coredataManager.is_deleteAll_Called)
  }
  
  
  func test_GIVEN_items_WHEN_addItemtoCart_THEN_Success() {
    XCTAssertEqual(model!.items.count, 0)
    
    let list = ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 1.00)
    let item = shoppingItem(shoppingList: list, isPromotions: "name1")
    model.addToCart(item)
    
    XCTAssertEqual(model!.items.count, 1)
    // Test if coredata function been called
    XCTAssertTrue(coredataManager.is_add_Called)
    
    let item1 = model!.items[0]
    XCTAssertEqual(item1.shoppingList.name, "name1")
    
  }
  
  func  test_GIVEN_items_WHEN_minusItem_THEN_Success() {
    model.clearCart()
    let list = ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 1.00)
    let item1 = shoppingItem(shoppingList: list, isPromotions: "name1")
    model.addToCart(item1)
    model.addToCart(item1)
    model.addToCart(item1)
    
    XCTAssertEqual(model!.items[0].count, 3)
    // Test if coredata function been called
    XCTAssertTrue(coredataManager.is_add_Called)
    
    
    var item2 = CartItem(list, promotion: "name1")
    item2.count = 3
    model.minusItem(item2)
    
    XCTAssertEqual(model!.items[0].count, 2)
    // Test if coredata function been called
    XCTAssertTrue(coredataManager.is_update_Called)
    
  }
  
  func test_GIVEN_items_WHEN_increaseItem_THEN_Success() {
    model.clearCart()
    let list = ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 1.00)
    let item1 = shoppingItem(shoppingList: list, isPromotions: "name1")
    model.addToCart(item1)
    model.addToCart(item1)
    model.addToCart(item1)
    
    XCTAssertEqual(model!.items[0].count, 3)
    // Test if coredata function been called
    XCTAssertTrue(coredataManager.is_add_Called)
    
    var item2 = CartItem(list, promotion: "name1")
    item2.count = 3
    model.increaseItem(item2)
    
    XCTAssertEqual(model!.items[0].count, 4)
    // Test if coredata function been called
    XCTAssertTrue(coredataManager.is_update_Called)
  }
  
  
  func test_GIVEN_items_WHEN_calculatePrices_THEN_returnPrices() {
    var items = [
      CartItem(ShoppingList(barcode: "00", name: "1", unit: "u", price: 1.00), promotion: "买二赠一"),
      CartItem(ShoppingList(barcode: "01", name: "2", unit: "u", price: 2.00), promotion: "买二赠一"),
      CartItem(ShoppingList(barcode: "02", name: "3", unit: "u", price: 3.00), promotion: "none"),
    ]
    items[0].count = 2
    items[1].count = 3
    items[2].count = 2
    model.items = items
    
    model.calculatePrices()
    
    XCTAssertEqual(model!.totalPrices, 12.00)
    XCTAssertEqual(model!.savePrices, 2.00)
    XCTAssertEqual(model!.originPrices, 14.00)
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
