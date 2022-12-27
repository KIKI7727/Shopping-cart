//
//  ContentView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/5.
//

import Foundation
import SwiftUI

struct ShoppingListView: View {
  @StateObject private var viewModel: ShoppingListViewModel = .init()

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        List(viewModel.ListContents, id:\.shoppingList){ shoppingInfo in
          ShoppingListItemView(content: shoppingInfo.shoppingList, isPromotions: shoppingInfo.isPromotions)
            .listRowSeparator(.hidden)
        }.listStyle(.plain)
      }.navigationBarTitle("商品列表", displayMode: .inline)
    }
  }

  struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
      ShoppingListView()
    }
  }
}
