//
//  CUView.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct CUView: BaseView {
    var onSelectedTab: (SaleWarTab) -> Void
    @StateObject var cuViewModel : CUViewModel
    @ObservedObject var appViewModel: AppViewModel
    @FocusState var isSearchBarFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BaseBackgroundView()
            
            VStack {
                SaleWarTitleBar() {
                    cuViewModel.showingFavoriteList = true
                }
                
                Spacer(minLength: 16)
                
                Text("CU의 할인상품을 만나보세요!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.bottom)
                
                SaleWarSearchBar(searchText: $cuViewModel.searchKeyword)
                    .focused($isSearchBarFocused)
                    .onAppear {
                        cuViewModel.observeSearchKeyword()
                    }
                
                GeometryReader { geometry in
                    ScrollView() {
                        Spacer(minLength: 8)
                        
                        let itemWidth = (geometry.size.width - 15) / 2
                        
                        let columns: [GridItem] = [GridItem(.fixed(itemWidth)),GridItem(.fixed(itemWidth)) ]
                        
                        //[GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 15, content: {
                            ForEach(cuViewModel.productList, id: \.self) { product in
                                ProductGridItem(product: product){
                                    if isSearchBarFocused {
                                        isSearchBarFocused = false
                                    } else {
                                        cuViewModel.showingProductDetailView = true
                                        cuViewModel.selectedProduct = product
                                    }
                                    
                                }
                            }
                        })
                        .frame(maxHeight: .infinity)
                        .onAppear {
                            cuViewModel.observeCUProducts()
                        }
                    }
                }
            }
            .padding()
            .onTapGesture {
                isSearchBarFocused = false
            }
            .sheet(isPresented: $cuViewModel.showingFavoriteList) {
//                FavoriteProductList(favoriteProductList: appViewModel.getFavoriteProducts()) { favoriteProduct in
//                    appViewModel.deleteFavoriteProduct(product: favoriteProduct)
//                }
            }
            
            VStack {
                Spacer()
                    .frame(maxWidth: .infinity)
                SaleWarTabView(
                    onSelectedTab: onSelectedTab
                )
            }
            
            if(cuViewModel.showingProductDetailView) {
                ProductDetailView(
                    product: $cuViewModel.selectedProduct,
                    isFavoriteProduct: cuViewModel.isFavoriteProduct(cuViewModel.selectedProduct!),
                    onCanceledDetailView: {
                        cuViewModel.showingProductDetailView = false
                }, onClickedFavoriteIcon: { product in
                    let isFavorite = cuViewModel.isFavoriteProduct(product)
                    if isFavorite {
                        cuViewModel.deleteFavoriteProduct(product)
                    } else {
                        cuViewModel.addFavoriteProduct(product)
                    }
                })
            }
        }
    }
}



#Preview {
    CUView(
        onSelectedTab: {(_) in},
        cuViewModel: CUViewModel(),
        appViewModel: AppViewModel()
    )
}

