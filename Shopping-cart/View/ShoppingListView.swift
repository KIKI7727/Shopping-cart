//
//  ContentView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/5.
//

import Foundation
import SwiftUI

struct ShoppingListView: View {
  @EnvironmentObject var viewModel: ShoppingListViewModel
  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        List(viewModel.ListContents, id:\.shoppingList){ shoppingInfo in
          ShoppingListItemView(content: shoppingInfo.shoppingList, isPromotions: shoppingInfo.isPromotions)
            .environmentObject(viewModel)
            .listRowSeparator(.hidden)
        }.listStyle(.plain)
      }.navigationBarTitle("商品列表", displayMode: .inline)
        .onAppear {
          viewModel.fetchData()
        }
    }
  }

  struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
      ShoppingListView()
    }
  }
}
