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
    
    var cancellableBag = Set<AnyCancellable>()
    @Published var productList = [Product]()
    @Published var isLoading = false
    @Published var showingProductDetailView = false
    @Published var selectedProduct: Product?
    @Published var searchKeyword: String = ""
    @Published var showingFavoriteList = false
    
    func fetchCUProducts() {
        print("fetchCUProducts, thread: \(OperationQueue.current == OperationQueue.main)")
        
        let realmManager = RealmManager.shared
        guard let cuProducts = realmManager.getProducts(forStore: StoreType.cu.rawValue) else {
            print("No CU Products")
            self.productList = []
            return
        }
        print("cuProducts count: \(cuProducts.count)")
            
        let cuProductsArray = Array(cuProducts)
        self.productList = cuProductsArray
    }
    
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
    
    func observeSearchKeyword() {
        print("CUViewModel observeSearchKeyword")
        
        $searchKeyword
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] keyword in
                guard let self = self else { return }
                
                if !keyword.isEmpty {
                    let searchResult = self.performSearch(with: keyword)
                    self.productList = searchResult
                } else {
                    //전체 검색한 결과 보여주기
                    self.fetchCUProducts()
                }
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String) -> [Product] {
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.cu.rawValue)
    }
    
    func addFavoriteProduct(_ product: Product) {
        Task {
            print("addFavoriteProduct")
            let realmManager = RealmManager.shared
            await realmManager.addFavoriteProduct(favorite: FavoriteProduct(product: product))
        }
    }
    
//    func deleteFavoriteProduct(_ product: Product) {
//        Task {
//            print("deleteFavoriteProduct")
//            let realmManager = RealmManager.shared
//            await realmManager.deleteFavoriteProduct(favorite: FavoriteProduct(product: product))
//        }
//    }
    
    func clickFavoriteIcon(_ product: Product) {
        print(#fileID, #function, #line, "clickFavoriteIcon : \(product.title), isMainThread: \(Thread.isMainThread)")
        let productInfo = ProductInfo(product: product)

        Task {
            let realmManager = RealmManager.shared
            await realmManager.clickFavoriteIcon(productInfo: productInfo)
        }
    }
    
    func isFavoriteProduct(_ product: Product) -> Bool {
        print("isFavoriteProduct, product name: \(product.title)")
        let realmManager = RealmManager.shared
        return realmManager.isFavoriteProduct(productName: product.title)
    }
    
    deinit {
        let realmManager = RealmManager.shared
        realmManager.invalidateProductNotificationToken(for: .cu)
        cancellableBag.removeAll()
    }
}
