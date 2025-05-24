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
    
    func fetchGS25Products(){
//        DispatchQueue.global(qos: .background).async {
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
            
//            DispatchQueue.main.async {
                self.productList = gs25ProductsArray
//            }
//        }
    }
}
