//
//  ShoppingList.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/7.
//

import Foundation

struct ShoppingList: Codable {
  let barcode: String
  let name: String
  let unit: String
  let price: Double
}
