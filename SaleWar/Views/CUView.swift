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
    @ObservedObject var cuViewModel : CUViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BaseBackgroundView()
            
            VStack {
                SaleWarTitleBar()
                
                Spacer(minLength: 16)
                
                Text("CU의 할인상품을 만나보세요!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.bottom)
                
                SaleWarSearchBar()
                
                GeometryReader { geometry in
                    ScrollView() {
                        Spacer(minLength: 8)
                        
                        let itemWidth = (geometry.size.width - 15) / 2
                        
                        let columns: [GridItem] = [GridItem(.fixed(itemWidth)),GridItem(.fixed(itemWidth)) ]
                        
                        //[GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 15, content: {
                            ForEach(cuViewModel.productList, id: \.self) { product in
                                ProductGridItem(product: product){
                                    
                                }
//                                    .frame(width: itemWidth, height: 300)
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
            
            SaleWarTabView(
                onSelectedTab: onSelectedTab
            )
        }
    }
}



#Preview {
    CUView(
        onSelectedTab: {(_) in},
        cuViewModel: CUViewModel()
    )
}
