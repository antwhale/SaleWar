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
    @Published var productList = [Product]()
    @Published var isLoading = false
    @Published var showingProductDetailView = false
    
    func fetchGS25Products(){
            print("fetchGS25Products, thread: \(OperationQueue.current == OperationQueue.main)")
            
            let realmManager = RealmManager.shared
            guard let gs25Products = realmManager.getProducts(forStore: StoreType.gs25.rawValue) else {
                DispatchQueue.main.async {
                    print("No GS25 Products")
                    self.productList = []
                }
                return
            }
            print("gs25Products count: \(gs25Products.count)")
            
            let gs25ProductsArray = Array(gs25Products)
            
                self.productList = gs25ProductsArray

    }
    
    func observeGS25Products() {
        print("observeGS25Products")
        
        let realmManager = RealmManager.shared
        realmManager.observeProducts(store: StoreType.gs25) { [weak self] results in
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
        realmManager.invalidateProductNotificationToken(for: .gs25)
    }
}
