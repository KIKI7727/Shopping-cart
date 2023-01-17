//
//  CoreDataManager.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2023/1/13.
//

import Foundation
import CoreData

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

protocol CoreDataProtocol {
  init(inMemory: Bool)
  var itemsEntity: [CartItemEntity] { get set }
  func add(_ item: CartItem)
  func update(_ item: CartItem)
  func delete(_ item: CartItem)
  func deleteAll()
  func fetchAllResult() -> [CartItemEntity]?
}

class CoreDataManager: CoreDataProtocol {

  let container: NSPersistentContainer
  var itemsEntity: [CartItemEntity]

  var viewContext: NSManagedObjectContext {
    return container.viewContext
  }

  required init(inMemory: Bool = false) {
    itemsEntity = []
    container = NSPersistentContainer(name: "CartData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }

  private func saveContext() {
    do {
      try container.viewContext.save()
    } catch {
      let error = error as NSError
      print(error.localizedDescription)
    }
  }

  func add(_ item: CartItem) {
    let entity = CartItemEntity(context: container.viewContext, item: item)
    saveContext()
    itemsEntity.append(entity)
  }

  func update(_ item: CartItem) {
    if let entity = itemsEntity.first(where: { $0.name == item.shoppingList.name }) {
      entity.count = Int16(item.count)
      saveContext()
    }
  }

  func delete(_ item: CartItem) {
    if let entity = itemsEntity.first(where: { $0.name == item.shoppingList.name }) {
      viewContext.delete(entity)
      saveContext()
    }
  }

  func deleteAll() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CartItemEntity")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      try viewContext.execute(deleteRequest)
    } catch let error as NSError {
      debugPrint(error)
    }
  }

  func fetchAllResult() -> [CartItemEntity]? {
    let request = NSFetchRequest<CartItemEntity>(entityName: "CartItemEntity")
    request.sortDescriptors = [NSSortDescriptor(keyPath: \CartItemEntity.timestamp, ascending: true)]
    do {
      let data = try viewContext.fetch(request)
      return data
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}
