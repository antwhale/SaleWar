//
//  CUViewModel.swift
//  SaleWar
//
//  Created by 2beone on 5/26/25.
//

import Foundation
import Combine

class CUViewModel : BaseViewModel {
    
    init() {
        print("CUViewModel init")
        
    }
    
    let cancellableBag = Set<AnyCancellable>()
    @Published var productList = [Product]()
    
    func observeCUProducts() {
        print("observeCUProducts")
        
        let realmManager = RealmManager.shared
        realmManager.observeProducts(store: StoreType.cu) { [weak self] results in
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
        realmManager.invalidateProductNotificationToken(for: .cu)
    }
}
