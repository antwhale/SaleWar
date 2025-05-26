//
//  SevenElevenViewModel.swift
//  SaleWar
//
//  Created by 2beone on 5/26/25.
//

import Foundation
import Combine

class SevenElevenViewModel : BaseViewModel {
    init() {
        print("SevenElevenViewModel init")
    }
    
    let cancellableBag = Set<AnyCancellable>()
    @Published var productList = [Product]()
    
    func observeSevenElevenProducts() {
        print("observeSevenElevenProducts")
        
        let realmManager = RealmManager.shared
        realmManager.observeProducts(store: StoreType.sevenEleven) { [weak self] results in
            guard let isProductsEmpty = self?.productList.isEmpty else { return }
            
            if isProductsEmpty {
                self?.productList = results
            } else {
                self?.productList.removeAll()
                self?.productList = results
            }
        }
    }
    
    deinit {
        let realmManager = RealmManager.shared
        realmManager.invalidateProductNotificationToken(for: .sevenEleven)
    }
}
