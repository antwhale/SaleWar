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
    @Published var showingFavoriteList = false
    
    @MainActor
    func fetchGS25Products(){
            print("fetchGS25Products, thread: \(OperationQueue.current == OperationQueue.main)")
            
            let realmManager = RealmManager.shared
            guard let gs25Products = realmManager.getProducts(forStore: StoreType.gs25.rawValue) else {
                print("No GS25 Products")
                self.productList = []
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
            
            print("observeGS25Products thread: \(OperationQueue.current == OperationQueue.main)")
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
            .dropFirst()
            .sink { [weak self] keyword in
                guard let self = self else { return }
                
                Task {
                    if !keyword.isEmpty {
                        print(#fileID, #function, #line, "keyword : \(keyword)")

                        let searchResult = await self.performSearch(with: keyword)
                        await MainActor.run{
                            self.productList = searchResult
                        }
                    } else {
                        print(#fileID, #function, #line, "keyword is empty")

                        //전체 검색한 결과 보여주기
                        await self.fetchGS25Products()
                    }
                }
                
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String) async -> [Product] {
        
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return await realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.gs25.rawValue)
    }
    
    func addFavoriteProduct(_ product: Product) {
        Task {
            print("addFavoriteProduct")
            let realmManager = RealmManager.shared
//            await realmManager.addFavoriteProduct(favorite: FavoriteProduct(product: product))
            await realmManager.addFavoriteProduct(productInfo: ProductInfo(product: product))
        }
    }
    
    func deleteFavoriteProduct(_ product: Product) {
        Task {
            print("deleteFavoriteProduct")
            let realmManager = RealmManager.shared
            await realmManager.deleteFavoriteProduct(favorite: FavoriteProduct(product: product))
        }
      
    }
    
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
        print(#fileID, #function, #line, "deinit")

        let realmManager = RealmManager.shared
        realmManager.invalidateProductNotificationToken(for: .gs25)
        
        cancellableBag.removeAll()
    }
}
