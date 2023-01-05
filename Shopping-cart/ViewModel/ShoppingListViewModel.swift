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
  @Published var isPayReady = true
  @Published var outputContent = ""
  private var subscription: Set<AnyCancellable> = []
  
  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"

  let shoppingListServer: ListServer

  init(listServer: ListServer = ShoppingListServer()) {

    self.shoppingListServer = listServer

    fetchData()
  }


  func getOutput() {
      outputContent.append("***<没钱赚商店>收据***\n")
      for item in items {
        outputContent += item.outputContent()
      }
    outputContent.append("----------------------\n")
    outputContent.append("总计：" + String.localizedStringWithFormat("%.2f", totalPrices) + "(元)\n")
    outputContent.append("节省：" + String.localizedStringWithFormat("%.2f", savePrices) + "(元)\n")
    outputContent.append("**********************")
  }

  func calcPrices() {
    self.totalPrices = 0
    self.savePrices = 0
    for item in self.items {
      self.totalPrices += item.totalPrice()
      self.savePrices += item.savePrice()
    }
    self.originPrices = self.totalPrices + self.savePrices

    self.isPayReady = self.items.isEmpty
  }
  
  func fetchData() {
    
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
    }, receiveValue: { [weak self] data in
      self?.promotiosList = data
    })
    .store(in: &subscription)

    $promotiosList
      .sink { value in
        self.ListContents.removeAll()
        self.listContent.forEach({
          if value.contains($0.barcode){
            self.ListContents.append(shoppingItem(shoppingList: $0, isPromotions: "买二赠一"))
          } else {
            self.ListContents.append(shoppingItem(shoppingList: $0, isPromotions: "暂无活动"))
          }
        })
        print(self.ListContents.count)
      }
      .store(in: &subscription)
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
