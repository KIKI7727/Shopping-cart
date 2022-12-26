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
  @Published var promotiosList: [String] = []
  @Published var ListContents: [shoppingItem] = []

  private var subscription: Set<AnyCancellable> = []

  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"

  init() {
    let shoppingListServer = ShoppingListServer()

    shoppingListServer.getDataFromRemote(url: shoppingListUrl)
      .sink(receiveCompletion: { completion in
      print(completion)
    }, receiveValue: { [weak self] data in
      self?.listContent = data
    })
    .store(in: &subscription)

    shoppingListServer.getDataFromRemote(url: promotionsUrl)
    .sink(receiveCompletion: { completion in
      print(completion)
    }, receiveValue: { data in
      self.promotiosList = data
      self.listContent.forEach({
        if self.promotiosList.contains($0.barcode){
          self.ListContents.append(shoppingItem(shoppingList: $0, isPromotions: "买二赠一"))
        } else {
          self.ListContents.append(shoppingItem(shoppingList: $0, isPromotions: "暂无活动"))
        }
      })
    })
    .store(in: &subscription)
  }

  struct ShoppingListServer {
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

  struct shoppingItem {
    let shoppingList: ShoppingList
    let isPromotions: String
  }
}
