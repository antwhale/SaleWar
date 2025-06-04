//
//  GS25View.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct GS25View: BaseView {
    var onSelectedTab: (SaleWarTab) -> Void
    @ObservedObject var gs25ViewModel : GS25ViewModel
    @FocusState var isSearchBarFocused: Bool

    var body: some View {
        
        ZStack() {
            BaseBackgroundView()

            VStack {
                SaleWarTitleBar()
                
                Spacer(minLength: 16)
                
                Text("GS25의 할인상품을 만나보세요!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.bottom)
                
                SaleWarSearchBar(searchText: $gs25ViewModel.searchKeyword)
                    .focused($isSearchBarFocused)
                    .onAppear {
                        gs25ViewModel.observeSearchKeyword()
                    }
                
                Spacer(minLength: 8)
                
                GeometryReader { geometry in
                    ScrollView() {
                        Spacer(minLength: 8)
                        
                        let itemWidth = (geometry.size.width - 15) / 2
                        
                        let columns: [GridItem] = [GridItem(.fixed(itemWidth)),GridItem(.fixed(itemWidth)) ]
                        
                        //[GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 15, content: {
                            ForEach(gs25ViewModel.productList, id: \.self) { product in
                                ProductGridItem(product: product){
                                    if(isSearchBarFocused) {
                                        isSearchBarFocused = false
                                    } else {
                                        gs25ViewModel.showingProductDetailView = true
                                        gs25ViewModel.selectedProduct = product
                                    }
                                    
                                }
//                                    .frame(width: itemWidth, height: 300)
                            }
                        })
                        .frame(maxHeight: .infinity)
                        .autocorrectionDisabled(true)
                        .onAppear {
                            gs25ViewModel.observeGS25Products()
                        }
                    }
                }
            }
            .padding()
            .onTapGesture {
                isSearchBarFocused = false
            }

            
            
            
            VStack {
                Spacer()
                    .frame(maxWidth: .infinity)
                SaleWarTabView(
                    onSelectedTab: onSelectedTab
                )
            }
            
            if(gs25ViewModel.showingProductDetailView) {
                ProductDetailView(
                    product: $gs25ViewModel.selectedProduct,
                    isFavoriteProduct: gs25ViewModel.isFavoriteProduct(gs25ViewModel.selectedProduct!),
                    onCanceledDetailView: {
                    gs25ViewModel.showingProductDetailView = false
                }, onClickedFavoriteIcon: { product in
                    let isFavorite = gs25ViewModel.isFavoriteProduct(product)
                    if isFavorite {
                        gs25ViewModel.deleteFavoriteProduct(product)
                    } else {
                        gs25ViewModel.addFavoriteProduct(product)
                    }
                })
            }
            
            
                
        }
    }
}

#Preview {
    
    GS25View(
        onSelectedTab: { (_) in },
        gs25ViewModel: GS25ViewModel()
    )
}
