//
//  ShoppingListViewModel.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/21.
//

import Foundation
import Combine
import CoreData

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

  @Published var itemsEntity: [CartItemEntity] = []

  
  let promotionsUrl = "https://tw-mobile-xian.github.io/pos-api/promotions.json"
  let shoppingListUrl = "https://tw-mobile-xian.github.io/pos-api/items.json"

  let container: NSPersistentContainer

  let shoppingListServer: ListServer

  init(listServer: ListServer = ShoppingListServer()) {

    self.shoppingListServer = listServer

    container = NSPersistentContainer(name: "CartData")
    container.loadPersistentStores { (description, error) in
      if let _ = error {
        print("Load Core Data Error!")
      }
    }

    getCartItemsFromCoreData()
    fetchData()
  }

  func saveContext() {
    do {
      try container.viewContext.save()
    } catch {
      let error = error as NSError
      print(error.localizedDescription)
    }
  }


  func addCartItem(_ item: CartItem) {
      let entity = CartItemEntity(context: container.viewContext, item: item)
    saveContext()
    itemsEntity.append(entity)
  }

  func updateCartItem(_ item: CartItem) {
    if let entity = itemsEntity.first(where: { $0.name == item.shoppingList.name }) {
      entity.count = Int16(item.count)
      saveContext()
    }
  }

  func deleteCartItem(_ item: CartItem) {
    if let entity = itemsEntity.first(where: { $0.name == item.shoppingList.name }) {
      container.viewContext.delete(entity)
      saveContext()
    }
  }

  func clearCart() {
    items.removeAll()
    for item in itemsEntity {
      container.viewContext.delete(item)
      saveContext()
    }
  }


  func getCartItemsFromCoreData() {
    let request = NSFetchRequest<CartItemEntity>(entityName: "CartItemEntity")
    request.sortDescriptors = [NSSortDescriptor(keyPath: \CartItemEntity.timestamp, ascending: true)]

    do {
      itemsEntity = try container.viewContext.fetch(request)

      for item in itemsEntity {
        let shopList = ShoppingList(barcode: item.barcode!, name: item.name!, unit: item.unit!, price: item.price)
        var cartItem = CartItem(shopList, promotion: item.isPromotion!)
        cartItem.count = Int(item.count)
        items.append(cartItem)
      }
    } catch {
      print(error.localizedDescription)
    }
  }


  func getOutput() {
    outputContent = ""
    outputContent.append("***<没钱赚商店>收据***\n")
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
      updateCartItem(items[index])
    } else {
      let cartItem = CartItem(item.shoppingList, promotion: item.isPromotions)
      items.append(cartItem)
      addCartItem(cartItem)
    }
  }
  
  func minusItem(_ item: CartItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      if item.count > 1 {
        items[index].count -= 1
        updateCartItem(items[index])
      } else {
        deleteCartItem(items[index])
        items.remove(at: index)
        calculatePrices()
      }
    }
  }
  
  func increaseItem(_ item: CartItem) {
    if let index = items.firstIndex(where: {$0.shoppingList.name == item.shoppingList.name}) {
      items[index].count += 1
      updateCartItem(items[index])
      calculatePrices()
    }
  }
}

extension CartItemEntity {
    convenience init(context: NSManagedObjectContext, item: CartItem) {
        self.init(context: context)

        self.barcode = item.shoppingList.barcode
        self.name = item.shoppingList.name
        self.price = item.shoppingList.price
        self.unit = item.shoppingList.unit
        self.isPromotion = item.isPromotions
        self.count = Int16(item.count)
        self.timestamp = Date()
    }
  }

