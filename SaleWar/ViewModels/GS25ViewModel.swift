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
    
    var cancellableBag = Set<AnyCancellable>()
    @Published var productList = [Product]()
    @Published var isLoading = false
    @Published var showingProductDetailView = false
    @Published var selectedProduct: Product?
    @Published var searchKeyword: String = ""
    
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
    
    func observeSearchKeyword() {
        print("observeSearchKeyword")
        
        $searchKeyword
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] keyword in
                guard let self = self else { return }
                
                if !keyword.isEmpty {
                    let searchResult = self.performSearch(with: keyword)
                    self.productList = searchResult
                } else {
                    //전체 검색한 결과 보여주기
                    fetchGS25Products()
                }
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String) -> [Product] {
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.gs25.rawValue)
    }
    
//    private func performSearch(with keyword: String) {
//            print("Searching for products with keyword: \(keyword)")
//            // Use the searchProducts(byPartialTitle:) method you created in the Product class
//            let results = Product.searchProducts(byPartialTitle: keyword)
//            
//            // Convert Realm Results to a plain Array for @Published property
//            // This is often done because Realm's Results are live collections
//            // and sometimes SwiftUI views prefer plain arrays for simplicity,
//            // although Realm's Results can also be used directly in SwiftUI.
//            self.searchResults = Array(results)
//        }
    
//    private func setupSearchObservation() {
//            $searchKeyword // Access the Publisher of searchKeyword
//                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // Wait for 0.5 seconds of inactivity
//                .removeDuplicates() // Prevent searching for the same keyword repeatedly
//                .sink { [weak self] keyword in
//                    guard let self = self else { return }
//                    // Perform the search only if the keyword is not empty
//                    if !keyword.isEmpty {
//                        self.performSearch(with: keyword)
//                    } else {
//                        // Optionally clear results if search keyword is empty
//                        self.searchResults = []
//                    }
//                }
//                .store(in: &cancellables) // Store the subscription to keep it active
//        }
    
    func addFavoriteProduct(_ product: Product) {
        print("addFavoriteProduct")
        let realmManager = RealmManager.shared
        realmManager.addFavoriteProduct(favorite: FavoriteProduct(product: product))
    }
    
    func deleteFavoriteProduct(_ product: Product) {
        print("deleteFavoriteProduct")
        let realmManager = RealmManager.shared
        realmManager.deleteFavoriteProduct(favorite: FavoriteProduct(product: product))
    }
    
    func isFavoriteProduct(_ product: Product) -> Bool {
        print("isFavoriteProduct, product name: \(product.title)")
        let realmManager = RealmManager.shared
        return realmManager.isFavoriteProduct(productName: product.title)
    }
    
    deinit {
        let realmManager = RealmManager.shared
        realmManager.invalidateProductNotificationToken(for: .gs25)
        
        cancellableBag.removeAll()
    }
}
