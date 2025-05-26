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
                
                SaleWarSearchBar()
                
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
                                    gs25ViewModel.showingProductDetailView = true
                                }
//                                    .frame(width: itemWidth, height: 300)
                            }
                        })
                        .frame(maxHeight: .infinity)
                        .onAppear {
//                            gs25ViewModel.fetchGS25Products()
                            gs25ViewModel.observeGS25Products()
                        }
                    }
                }
            }
            .padding()
            .alert(isPresented: $gs25ViewModel.showingProductDetailView) {
                Alert(
                    title: Text("Test Alert"),
                    message: Text("No product details available."),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            VStack {
                Spacer()
                    .frame(maxWidth: .infinity)
                SaleWarTabView(
                    onSelectedTab: onSelectedTab
                )
                
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
