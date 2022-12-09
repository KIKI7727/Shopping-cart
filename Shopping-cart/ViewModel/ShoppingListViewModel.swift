//
//  ShoppingListViewModel.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/9.
//

import Foundation
import Combine

class ShoppingListViewModel: ObservableObject{
  @Published var listContent: [ShoppingList] = []
  
  var cancellables = Set<AnyCancellable>()
  
  private var subscription: Set<AnyCancellable> = []
  
  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"
  
  init() {
    let shoppingListServer = ShoppingListServer<ShoppingList>(url: shoppingListUrl)
    let promotionsServer = ShoppingListServer<String>(url: promotionsUrl)
    
    shoppingListServer.getDataFromRemote()
      .sink(receiveCompletion: { completion in
        print(completion)
      }, receiveValue: { [weak self] data in
        self?.listContent = data
      })
      .store(in: &subscription)
    
    promotionsServer.getDataFromRemote()
      .sink(receiveCompletion: {_ in
        
      }, receiveValue: {data in
        print(data)
      })
      .store(in: &subscription)
  }
}


