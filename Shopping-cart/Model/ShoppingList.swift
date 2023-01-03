//
//  ShoppingList.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/21.
//

import Foundation

struct ShoppingList: Codable, Hashable{
  let barcode: String
  let name: String
  let unit: String
  let price: Double
}

struct shoppingItem {
  let shoppingList: ShoppingList
  let isPromotions: String
}

struct CartItem {
  let shoppingList: ShoppingList
  let isPromotions: String
  var count: Int
  
  init(_ shoppingList: ShoppingList, promotion: String) {
    self.count = 1
    self.isPromotions = promotion
    self.shoppingList = shoppingList
  }
  
  mutating func addCount() {
    self.count += 1
  }
  
  func totalPrice()-> Float {
    if isPromotions == "买二赠一" {
      return count > 2 ? Float((count / 3) * 2 + count % 3) * Float(self.shoppingList.price)
      : Float(count) * Float(self.shoppingList.price)
    }
    return Float(count) * Float(self.shoppingList.price)
  }
  
  func savePrice()-> Float {
    if isPromotions == "买二赠一" {
      return Float(count > 2 ? Double(count / 3) * self.shoppingList.price : 0.0)
    }
    return 0.0
  }
}
