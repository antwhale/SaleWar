//
//  AppViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import Combine

class AppViewModel: ObservableObject {
    init() {
        print("AppViewModel init")
        
        
    }
    
    @Published var selectedTab : SaleWarTab = .gs25
}
