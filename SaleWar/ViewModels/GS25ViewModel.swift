//
//  GS25ViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import Combine

class GS25ViewModel: BaseViewModel {
    init() {
        print("GS25ViewModel init")
    }
    
    let cancellableBag = Set<AnyCancellable>()

    @Published var productList = [String]()
}
