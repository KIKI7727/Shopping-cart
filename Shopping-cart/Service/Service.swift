//
//  Service.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2023/1/3.
//

import Foundation
import Combine

protocol ListServer {
  func getDataFromRemote<T: Decodable>(url: String) -> AnyPublisher <T, Error>
}

class ShoppingListServer: ListServer {
  func getDataFromRemote<T: Decodable>(url: String) -> AnyPublisher <T, Error> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
      .map { $0.data }
      .tryMap {
        try JSONDecoder().decode(T.self, from: $0)
      }
      .compactMap{$0}
      .eraseToAnyPublisher()
  }
}
