//
//  ServiceTests.swift
//  Shopping-cartTests
//
//  Created by cai dongyu on 2023/1/3.
//

import XCTest
import Combine

@testable import Shopping_cart

final class ServiceTests: XCTestCase {

  var service: ShoppingListServer!
  var cancellables = Set<AnyCancellable>()
  private var urlsessionStub: URLSessionStub!

  override func setUp() {
    urlsessionStub = URLSessionStub()
    service = ShoppingListServer(session: urlsessionStub)
  }

  func test_GIVEN_validURL_WHEN_getDataFromRemote_THEN_receiveListInfo() {
    var actualData: [ShoppingList] = []

    service.getDataFromRemote(url: "https://tw-mobile-xian.github.io/pos-api/items.json")
      .sink(receiveCompletion: { completion in
      }, receiveValue: { data in
        actualData = data
      })
      .store(in: &cancellables)

        let responseJson = """
    [
      {
        "barcode": "ITEM000000",
        "name": "可口可乐",
        "unit": "瓶",
        "price": 3.00
      },
      {
        "barcode": "ITEM000001",
        "name": "雪碧",
        "unit": "瓶",
        "price": 3.00
      }
    ]
    """

    let expectedData = [
      ShoppingList(barcode: "ITEM000000", name: "可口可乐", unit: "瓶", price: 3.00),
      ShoppingList(barcode: "ITEM000001", name: "雪碧", unit: "瓶", price: 3.00)]


    let dataTest = Data(responseJson.utf8)
    urlsessionStub.publisher.send((dataTest, URLResponse()))
    urlsessionStub.publisher.send(completion: .finished)

    XCTAssertEqual(actualData, expectedData)
  }

  func test_GIVEN_errorResponse_WHEN_getDataFromRemote_THEN_error() {
    var actualError: Error?

    service.getDataFromRemote(url: "https://tw-mobile-xian.github.io/pos-api/items.json")
      .sink(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
          actualError = error
          break
        default:
          break
        }
      }, receiveValue: { (_ : [ShoppingList]) in
      })
      .store(in: &cancellables)


    urlsessionStub.publisher.send(completion: .failure(URLError(.badServerResponse)))

    let _ = URLError(.badServerResponse)
    XCTAssertEqual(actualError as! URLError, URLError(.badServerResponse))

  }
}

private final class URLSessionStub: URLSessionType {
  let publisher = PassthroughSubject<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>()

  func publisher(for url: URL) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
    publisher.eraseToAnyPublisher()
  }
}
