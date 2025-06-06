//
//  SevenElevenView.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct SevenElevenView: BaseView {
    var onSelectedTab: (SaleWarTab) -> Void
    @StateObject var sevenElevenViewModel : SevenElevenViewModel
    @FocusState var isSearchBarFocused: Bool

    
    var body: some View {
        ZStack(alignment: .bottom) {
            BaseBackgroundView()
            
            VStack {
                SaleWarTitleBar() {
                    sevenElevenViewModel.showingFavoriteList = true
                }
                
                Spacer(minLength: 16)
                
                Text("세븐일레븐의 할인상품을 만나보세요!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.bottom)
                
                SaleWarSearchBar(searchText: $sevenElevenViewModel.searchKeyword)
                    .focused($isSearchBarFocused)
                    .onAppear {
                        sevenElevenViewModel.observeSearchKeyword()
                    }
                
                GeometryReader { geometry in
                    ScrollView() {
                        Spacer(minLength: 8)
                        
                        let itemWidth = (geometry.size.width - 15) / 2
                        
                        let columns: [GridItem] = [GridItem(.fixed(itemWidth)),GridItem(.fixed(itemWidth)) ]
                        
                        LazyVGrid(columns: columns, spacing: 15, content: {
                            ForEach(sevenElevenViewModel.productList, id: \.self) { product in
                                ProductGridItem(product: product){
                                    if isSearchBarFocused {
                                        isSearchBarFocused = false
                                    } else {
                                        sevenElevenViewModel.showingProductDetailView = true
                                        sevenElevenViewModel.selectedProduct = product
                                    }
                                }
                            }
                        })
                        .frame(maxHeight: .infinity)
                        .onAppear {
//                            gs25ViewModel.fetchGS25Products()
                            sevenElevenViewModel.observeSevenElevenProducts()
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
            
            if(sevenElevenViewModel.showingProductDetailView) {
                ProductDetailView(
                    product: $sevenElevenViewModel.selectedProduct,
                    isFavoriteProduct: sevenElevenViewModel.isFavoriteProduct(sevenElevenViewModel.selectedProduct!),
                    onCanceledDetailView: {
                        sevenElevenViewModel.showingProductDetailView = false
                }, onClickedFavoriteIcon: { product in
                    let isFavorite = sevenElevenViewModel.isFavoriteProduct(product)
                    if isFavorite {
                        sevenElevenViewModel.deleteFavoriteProduct(product)
                    } else {
                        sevenElevenViewModel.addFavoriteProduct(product)
                    }
                })
            }
        }
    }
}

#Preview {
    SevenElevenView(
        onSelectedTab: {(_) in},
        sevenElevenViewModel: SevenElevenViewModel()
    )
}
