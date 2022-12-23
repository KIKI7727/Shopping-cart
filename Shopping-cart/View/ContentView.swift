//
//  ContentView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/5.
//

import Foundation
import SwiftUI

struct ContentView: View {
  @State private var viewModel: ShoppingListViewModel = .init()

  var body: some View {
    VStack {
      List(viewModel.listContent, id: \.barcode){shoppingInfo in
        Text(shoppingInfo.name)
        Text(shoppingInfo.barcode)
        Text(String(shoppingInfo.price))
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
