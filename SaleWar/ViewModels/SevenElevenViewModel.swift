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
    
    func fetchSevenElevenProducts() {
        Task {
            print("fetchSevenElevenProducts, thread: \(OperationQueue.current == OperationQueue.main)")
            
            let realmManager = RealmManager.shared
            guard let sevenElevenProducts = await realmManager.getProducts(forStore: StoreType.sevenEleven.rawValue) else {
                await MainActor.run {
                    print("No SevenEleven Products")
                    self.productList = []
                }
                return
            }
            print("sevenEleven Products count: \(sevenElevenProducts.count)")
            
            let sevenElevenProductsArray = Array(sevenElevenProducts)
            
            await MainActor.run {
                self.productList = sevenElevenProductsArray

            }
        }
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
        print("SevenElevenViewModel observeSearchKeyword")
        
        $searchKeyword
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] keyword in
                guard let self = self else { return }
                
                Task {
                    if !keyword.isEmpty {
                        let searchResult = await self.performSearch(with: keyword)
                        self.productList = searchResult
                    } else {
                        //전체 검색한 결과 보여주기
                        self.fetchSevenElevenProducts()
                    }
                }
                
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String) async -> [Product] {
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return await realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.sevenEleven.rawValue)
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
        realmManager.invalidateProductNotificationToken(for: .sevenEleven)
    }
}
