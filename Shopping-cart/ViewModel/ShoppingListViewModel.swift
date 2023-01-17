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
  @Published var items: [CartItem] = [] {
    didSet {
      self.calculatePrices()
    }
  }
  @Published var totalPrices: Float = 0.0
  @Published var savePrices: Float = 0.0
  @Published var originPrices: Float = 0.0
  @Published var isPayReady = true
  @Published var outputContent = ""
  private var subscription: Set<AnyCancellable> = []

  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"

  let shoppingListServer: ListServer
  var coredataManager: CoreDataProtocol

  init(listServer: ListServer = ShoppingListServer(), coredataManager: CoreDataProtocol = CoreDataManager()) {
    self.shoppingListServer = listServer
    self.coredataManager = coredataManager
    getCartItemsFromCoreData()
    fetchData()
  }

  func addToCart(_ item: shoppingItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      items[index].count += 1
      coredataManager.update(items[index])
    } else {
      let cartItem = CartItem(item.shoppingList, promotion: item.isPromotions)
      items.append(cartItem)
      coredataManager.add(cartItem)
    }
  }

  func minusItem(_ item: CartItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      if item.count > 1 {
        items[index].count -= 1
        coredataManager.update(items[index])
      } else {
        coredataManager.delete(items[index])
        items.remove(at: index)
      }
    }
  }

  func increaseItem(_ item: CartItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      items[index].count += 1
      coredataManager.update(items[index])
    }
  }

  func clearCart() {
    items.removeAll()
    coredataManager.deleteAll()
  }

  func getCartItemsFromCoreData() {
    if let result = coredataManager.fetchAllResult() {
      coredataManager.itemsEntity = result

      for item in coredataManager.itemsEntity {
        let shopList = ShoppingList(barcode: item.barcode!, name: item.name!, unit: item.unit!, price: item.price)
        var cartItem = CartItem(shopList, promotion: item.isPromotion!)
        cartItem.count = Int(item.count)
        items.append(cartItem)
      }
    } else {
      print(" Error when fetch coredata result.")
    }
  }

  func getOutput() {
    outputContent = ""
    outputContent.append("***收据***\n")
    for item in items {
      outputContent += item.outputContent()
    }
    outputContent.append("----------------------\n")
    outputContent.append("总计：" + String.localizedStringWithFormat("%.2f", totalPrices) + "(元)\n")
    outputContent.append("节省：" + String.localizedStringWithFormat("%.2f", savePrices) + "(元)\n")
    outputContent.append("**********************")
  }

  func calculatePrices() {
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
    shoppingdata
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
      print(completion)
    }, receiveValue: { [weak self] data in
      self?.listContent = data
    })
    .store(in: &subscription)

    let data: AnyPublisher<[String], Error> = shoppingListServer.getDataFromRemote(url: promotionsUrl)
    data
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
      print(completion)
    }, receiveValue: { [weak self] data in
      self?.promotiosList = data
    })
    .store(in: &subscription)

    $promotiosList
      .receive(on: DispatchQueue.main)
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

}


