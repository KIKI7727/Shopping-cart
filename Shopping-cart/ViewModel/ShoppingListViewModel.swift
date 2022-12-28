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
  @Published var items: [CartItem] = []
  @Published var totalPrices: Float = 0.0
  @Published var savePrices: Float = 0.0
  @Published var originPrices: Float = 0.0

  private var subscription: Set<AnyCancellable> = []
  
  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"
  
  init() {
    $items
      .receive(on: DispatchQueue.main)
      .sink {
        self.totalPrices = 0
        self.savePrices = 0
        for item in $0 {
          self.totalPrices += item.totalPrice()
          self.savePrices += item.savePrice()
        }
        self.originPrices = self.totalPrices + self.savePrices
      }
      .store(in: &subscription)
  }
  
  func fetchData() {
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
      self.listContent.forEach({
        if data.contains($0.barcode){
          self.ListContents.append(shoppingItem(shoppingList: $0, isPromotions: "买二赠一"))
        } else {
          self.ListContents.append(shoppingItem(shoppingList: $0, isPromotions: "暂无活动"))
        }
      })
      print(self.ListContents)
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
  
  func addToCart(_ item: shoppingItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      items[index].count += 1
    } else {
      items.append(CartItem(item.shoppingList, promotion: item.isPromotions))
    }
  }
  
  func minusItem(_ item: CartItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      if item.count > 1 {
        items[index].count -= 1
      } else {
        items.remove(at: index)
      }
    }
  }
  
  func increaseItem(_ item: CartItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      items[index].count += 1
    }
  }
}
