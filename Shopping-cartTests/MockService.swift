//
//  MockService.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/3.
//

import Foundation
import Combine

@testable import Shopping_cart

class MockService: ListServer {
  
  var fetchResult: Bool = true
  
  func getDataFromRemote<T>(url: String) -> AnyPublisher<T, Error> where T : Decodable {
    
    let data = [
      ShoppingList(barcode: "ITEM00000", name: "name1", unit: "uuit1", price: 1.00),
      ShoppingList(barcode: "ITEM00001", name: "name2", unit: "uuit2", price: 2.00)
    ]
    
    let promotions = ["ITEM00000", "ITEM00001"]
    
    if fetchResult {
      
      if T.self == [ShoppingList].self {
        return Just(data as! T)
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
      } else {
        return Just(promotions as! T)
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
      }
    } else {
      return Fail(error: URLError(.badServerResponse) as Error)
        .eraseToAnyPublisher()
    }
    
  }
}
