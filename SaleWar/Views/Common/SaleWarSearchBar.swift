//
//  SaleWarSearchBar.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct SaleWarSearchBar : View {
    @Binding var searchText : String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding(.leading, 10)

            TextField("", text: $searchText, prompt: Text("Search").foregroundColor(.white))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.trailing, 10)
        }
        .background(Color.yellow) 
        .cornerRadius(30) // Rounded corners
        .padding(.horizontal) // Add horizontal padding
    }
}

//#Preview {
//    SaleWarSearchBar()
//}
