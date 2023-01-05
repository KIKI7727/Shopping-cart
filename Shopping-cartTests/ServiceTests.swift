//
//  TestService.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/3.
//

import XCTest
import Combine

@testable import Shopping_cart

final class ServiceTest: XCTestCase {

  var service = ShoppingListServer()
  var cancellables = Set<AnyCancellable>()

    
  func test_getDataFromRemote_GetShopList_Success()  {
    service.getDataFromRemote(url: "https://tw-mobile-xian.github.io/pos-api/items.json")
      .sink { completion in
        switch completion {
        default:
          break
        }
      } receiveValue: { (data: [ShoppingList]) in
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 5)

        for i in 0...5 {
          XCTAssertNotEqual(data[i].barcode, "")
          XCTAssertNotEqual(data[i].name, "")
          XCTAssertNotEqual(data[i].unit, "")
          XCTAssertNotEqual(data[i].price, 0.00)
        }
      }
      .store(in: &cancellables)
  }

  func test_getDataFromRemote_GetShopList_Failed() {
    service.getDataFromRemote(url: "https://tw-mobile-xian.github.io/pos-api/items.json11")
      .sink { completion in
        switch completion {
        case .failure(let error):
          XCTAssertEqual((error as! URLError).code, URLError.backgroundSessionRequiresSharedContainer)
        default:
          break
        }
      } receiveValue: { (data: [ShoppingList]) in
        XCTFail("Should not be here.")
      }
          .store(in: &cancellables)
  }

}
