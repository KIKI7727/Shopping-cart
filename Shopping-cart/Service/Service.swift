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
  
  private var session: URLSessionType
  
  init(session: URLSessionType = URLSession.shared) {
    self.session = session
  }
  func getDataFromRemote<T: Decodable>(url: String) -> AnyPublisher <T, Error> {
    return session.publisher(for: URL(string: url)!)
      .map { $0.data }
      .tryMap {
        try JSONDecoder().decode(T.self, from: $0)
      }
      .compactMap{$0}
      .eraseToAnyPublisher()
  }
}

protocol URLSessionType {
  func publisher(for url: URL) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>
}

extension URLSession: URLSessionType {
  func publisher(for url: URL) -> AnyPublisher<DataTaskPublisher.Output, DataTaskPublisher.Failure> {
    return dataTaskPublisher(for: url).eraseToAnyPublisher()
    
  }
  
}
