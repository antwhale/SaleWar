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
    
    var cancellableBag = Set<AnyCancellable>()
    @Published var productList = [Product]()
    @Published var isLoading = false
    @Published var showingProductDetailView = false
    @Published var selectedProduct: Product?
    @Published var searchKeyword: String = ""
    @Published var showingFavoriteList = false
    
    func fetchSevenElevenProducts(){
        print("fetchSevenElevenProducts, thread: \(OperationQueue.current == OperationQueue.main)")
        
        let realmManager = RealmManager.shared
        guard let sevenElevenProducts = realmManager.getProducts(forStore: StoreType.sevenEleven.rawValue) else {
            DispatchQueue.main.async {
                print("No SevenEleven Products")
                self.productList = []
            }
            return
        }
        print("sevenEleven Products count: \(sevenElevenProducts.count)")
        
        let sevenElevenProductsArray = Array(sevenElevenProducts)
        
        self.productList = sevenElevenProductsArray
    }
    
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
                    fetchSevenElevenProducts()
                }
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String) -> [Product] {
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.sevenEleven.rawValue)
    }
    
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
        realmManager.invalidateProductNotificationToken(for: .sevenEleven)
    }
}
