//
//  HomeView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/26.
//

import SwiftUI

#if !TESTING
struct HomeView: View {
  @StateObject private var viewModel: ShoppingListViewModel = .init()
  
  @State private var selectionTab: HomeTab = .shoppinglist
  
  var body: some View {
    TabView(selection: $selectionTab){
      ShoppingListView()
        .environmentObject(viewModel)
        .tabItem {
          Label("商品列表", systemImage: "list.bullet")
        }
        .tag(HomeTab.shoppinglist)
      ShoppingCartView()
        .environmentObject(viewModel)
        .tabItem {
          Label("购物车", systemImage: "cart")
        }
        .tag(HomeTab.shoppingcart)
    }
  }
}
enum HomeTab {
  case shoppinglist
  case shoppingcart
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
#endif
