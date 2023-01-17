//
//  ShoppingListItemView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/26.
//

import SwiftUI

struct ShoppingListItemView: View {
  @EnvironmentObject var viewModel: ShoppingListViewModel
  @State private var showingAlert = false

  var content: ShoppingList
  var isPromotions: String
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("\(content.name)")
          .font(.system(size: 18, weight: .bold, design:  .rounded))
        Spacer()
        Button(action: {
          showingAlert = true
          viewModel.addToCart(shoppingItem(shoppingList: content, isPromotions: isPromotions))
        }, label: {
          Image(systemName: "plus.circle")
        })
        .alert("\(content.name)已加入购物车", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
        .buttonStyle(BorderlessButtonStyle())
      }
      Text("条形码：\(content.barcode)")
      Text("价格：\(String(content.price))")
      HStack {
        Text("单位：\(content.unit)")
        Spacer()
        Text("促销：\(isPromotions)")
      }
    }
    .padding(20)
    .background(.gray.opacity(0.2))
    .cornerRadius(15)
    .shadow(color: Color(UIColor.black.withAlphaComponent(0.06)), radius: 15, x: 0, y: 3)
  }
}


struct ShoppingListItemView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingListItemView(content: ShoppingList(barcode: "单位", name: "单位", unit: "单位", price: 1.0), isPromotions: "单位")
  }
}

