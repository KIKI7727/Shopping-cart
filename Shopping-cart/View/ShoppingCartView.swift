//
//  ShoppingCartView.swift
//  Shopping-cart
//
//  Created by cai dongyu on 2022/12/27.
//

import SwiftUI

struct ShoppingCartView: View {
  @EnvironmentObject var viewModel: ShoppingListViewModel

  var body: some View {
    NavigationView {
      VStack(spacing: 10) {
        ScrollView(showsIndicators: false) {
          VStack(spacing: 0) {
            ForEach(viewModel.items, id: \.shoppingList) { item in
              ItemView(item: item)
            }
            Spacer()
          }
        }
        HStack {
          Text("商品价格")
          Spacer()
          Text("¥ \(viewModel.originPrices, specifier: "%.2f")")
        }
        HStack {
          Text("优惠")
          Spacer()
          Text("¥ \(viewModel.savePrices, specifier: "%.2f")")
        }
        HStack {
          Text("合计")
          Spacer()
          Text("¥ \(viewModel.totalPrices, specifier: "%.2f")")
        }

        Button {

        } label: {
          Text("立即付款")
            .font(.system(size: 20, weight: .bold, design:  .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background (
              RoundedRectangle(cornerRadius: 12)
                .fill(.green)
                .frame(width: UIScreen.main.bounds.width - 50)

            )
        }
        .padding(.top, 10)
      }
      .frame(width: UIScreen.main.bounds.width - 50)
      .navigationBarTitle("购物车", displayMode: .inline)
    }
  }

  func ItemView(item: CartItem) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("条形码：\(item.shoppingList.barcode)")
      Text("名称：\(item.shoppingList.name)")
      HStack {
        Text("价格：\(item.shoppingList.price, specifier: "%.2f")")
        Spacer()
        HStack {
          Text("数量:")
          Image(systemName: "minus.square")
            .onTapGesture {
              viewModel.minusItem(item)
            }
          Text("\(item.count)")
          Image(systemName: "plus.square")
            .onTapGesture {
              viewModel.increaseItem(item)
            }

        }
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.gray.opacity(0.2))
    )
    .padding(.vertical, 5)
  }

}


struct ShoppingCartView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCartView()
  }
}
