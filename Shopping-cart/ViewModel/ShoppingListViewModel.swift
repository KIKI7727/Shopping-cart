//
//  ShoppingListViewModel.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/7.
//

import Foundation
import Combine

class ShoppingListViewModel: ObservableObject{
  @Published var listContent: [ShoppingList] = []

  var cancellables = Set<AnyCancellable>()

  private var subscription: Set<AnyCancellable> = []

  init() {
    self.getShoppingList()
      .sink(receiveCompletion: { completion in
        print(completion)
      }, receiveValue: { [weak self] data in
        self?.listContent = data
      })
      .store(in: &subscription)
  }
  func getShoppingList() -> AnyPublisher <Array<ShoppingList>, Error> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: "https://tw-mobile-xian.github.io/pos-api/items.json")!)
      .map { $0.data }
      .tryMap {
        try JSONDecoder().decode([ShoppingList].self, from: $0)
      }
      .compactMap{$0}
      .eraseToAnyPublisher()
  }
}

