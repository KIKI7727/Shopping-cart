//
//  ShoppingListServer.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/9.
//

import Foundation
import Combine

struct ShoppingListServer <T> where T: Decodable {
  let url: String
  func getDataFromRemote() -> AnyPublisher <Array<T>, Error> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
      .map { $0.data }
      .tryMap {
        try JSONDecoder().decode(Array<T>.self, from: $0)
      }
      .compactMap{$0}
      .eraseToAnyPublisher()
  }
}
