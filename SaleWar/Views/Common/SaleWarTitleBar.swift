//
//  TitleBar.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct SaleWarTitleBar : View {
    let onClickFavoriteMenu: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "line.horizontal.3")
                .font(.title2)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("세일 전쟁")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            
            Spacer()
            
            Button {
                print("click favorite icon")
                onClickFavoriteMenu()
            } label : {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30)
            .background(Color.orange)
            .clipShape(Circle())
        }
    }
}
