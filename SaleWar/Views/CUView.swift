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
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15, content: {
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                })
                .frame(maxHeight: .infinity)
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
        onSelectedTab: {(_) in}
    )
}
