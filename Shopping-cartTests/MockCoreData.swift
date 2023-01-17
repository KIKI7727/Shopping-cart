//
//  MockCoreData.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/13.
//

import Foundation
import CoreData
@testable import Shopping_cart

class MockCoreDataManager: CoreDataProtocol {
  
  var itemsEntity: [CartItemEntity]
  var is_add_Called: Bool = false
  var is_update_Called: Bool = false
  var is_delete_Called: Bool = false
  var is_deleteAll_Called: Bool = false
  var is_fetchAllResult_Called: Bool = false
  
  required init(inMemory: Bool = true) {
    itemsEntity = []
  }
  
  func add(_ item: Shopping_cart.CartItem) {
    is_add_Called = true
  }
  
  func update(_ item: Shopping_cart.CartItem) {
    is_update_Called = true
  }
  
  func delete(_ item: CartItem) {
    is_delete_Called = true
  }
  
  func deleteAll() {
    is_deleteAll_Called = true
  }
  
  func fetchAllResult() -> [Shopping_cart.CartItemEntity]? {
    is_fetchAllResult_Called = true
    return []
  }
}
