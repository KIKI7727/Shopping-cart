//
//  ReceiptView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/29.
//

import SwiftUI

struct ReceiptView: View {
  @EnvironmentObject var viewModel: ShoppingListViewModel
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "checkmark.diamond.fill")
          .resizable()
          .scaledToFit()
          .foregroundColor(.green)
          .frame(maxWidth: 40, maxHeight: 40)
        Text("付款成功")
          .font(.title)
      }
      VStack(alignment: .leading) {
        Spacer()
        Text(viewModel.outputContent)
        Spacer()
      }
      .padding()
      .frame(maxWidth: 350, maxHeight: 500)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(.gray.opacity(0.2))
      )
    }
    .onAppear {
      viewModel.getOutput()
      viewModel.clearCart()
    }
  }

  func ReceiptItemView(item: CartItem) -> some View {
    HStack(spacing: 5) {
      Text("名称: \(item.shoppingList.name), 数量: \(item.count), 价格：\(item.totalPrice(), specifier: "%.2f")")
    }
    .padding(.vertical, 10)
  }
  struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
      ReceiptView()
    }
  }
}


