//
//  GS25ViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import Combine

class GS25ViewModel: ObservableObject {
    init() {
        print("GS25ViewModel init")
    }
    
    @Published var productList = [String]()
}
