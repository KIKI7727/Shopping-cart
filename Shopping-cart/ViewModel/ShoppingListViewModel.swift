//
//  ShoppingListViewModel.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/21.
//

import Foundation
import Combine

class ShoppingListViewModel: ObservableObject{
  @Published var listContent: [ShoppingList] = []

  private var subscription: Set<AnyCancellable> = []

  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"

  init() {
    let shoppingListServer = ShoppingListServer()

    let shoppingdata: AnyPublisher<[ShoppingList], Error> = shoppingListServer.getDataFromRemote(url: shoppingListUrl)
    shoppingdata.sink(receiveCompletion: { completion in
      print(completion)
    }, receiveValue: { [weak self] data in
      self?.listContent = data
    })
    .store(in: &subscription)

    let data: AnyPublisher<[String], Error> = shoppingListServer.getDataFromRemote(url: promotionsUrl)
    data.sink(receiveCompletion: { completion in
      print(completion)
    }, receiveValue: { data in
      print(data)
    })
    .store(in: &subscription)
  }
}

struct ShoppingListServer {
  func getDataFromRemote<T: Decodable>(url:String) -> AnyPublisher <T, Error> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
      .map { $0.data }
      .tryMap {
        try JSONDecoder().decode(T.self, from: $0)
      }
      .compactMap{$0}
      .eraseToAnyPublisher()
  }
}
