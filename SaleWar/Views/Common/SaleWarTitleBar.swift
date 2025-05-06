//
//  TitleBar.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct SaleWarTitleBar : View {

    var body: some View {
        HStack {
            Image(systemName: "line.horizontal.3")
                .font(.title2)
                .foregroundColor(.black)
            
            Spacer()
            
            Text("세일 전쟁")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            
            Spacer()
            
            Circle()
                .fill(Color.orange)
                .frame(width: 30, height: 30)
        }
    }
}
