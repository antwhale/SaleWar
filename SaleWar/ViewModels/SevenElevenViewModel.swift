//
//  SevenElevenViewModel.swift
//  SaleWar
//
//  Created by 2beone on 5/26/25.
//

import Foundation
import Combine
import RealmSwift

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
    
    @Published var selectedCategory: String = ""
    @Published var categories: [String] = []
    
    func fetchSevenElevenProducts(category: String) {
        print("fetchSevenElevenProducts, category: \(category)")
        
        let realmManager = RealmManager.shared
        let store = StoreType.sevenEleven.rawValue
        
        // 1. 조건에 따른 데이터 조회
        var results: Results<Product>?
        if category.isEmpty || category == "전체" {
            results = realmManager.getProducts(forStore: store)
        } else {
            results = realmManager.getProducts(forStore: store, category: category)
        }
        
        guard let sevenElevenProducts = results else {
            print("No SevenEleven Products")
            self.productList = []
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
        
        categories = realmManager.getCategories(store: StoreType.sevenEleven)
        categories.insert("전체", at: 0)
    }
    
    func observeSearchKeyword() {
        print("SevenElevenViewModel observeSearchKeyword")
        
        // 1. 두 퍼블리셔를 결합합니다.
        Publishers.CombineLatest($searchKeyword, $selectedCategory)
            // 2. 검색어 입력 시에만 너무 자주 호출되지 않도록 디바운스 적용
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates { prev, curr in
                // 검색어와 카테고리가 둘 다 이전과 같을 때만 중복으로 간주
                return prev.0 == curr.0 && prev.1 == curr.1
            }
            .dropFirst()
            .sink { [weak self] (keyword, category) in
                guard let self = self else { return }
                print("이벤트 발생 - Keyword: \(keyword), Category: \(category)")

                if !keyword.isEmpty {
                    //키워드 존재
                    print(#fileID, #function, #line, "keyword : \(keyword), category: \(selectedCategory)")

                    let searchResult = self.performSearch(with: keyword, category: selectedCategory)
                    self.productList = searchResult
                } else {
                    print(#fileID, #function, #line, "keyword is empty, category: \(selectedCategory)")

                    //전체 검색한 결과 보여주기
                    self.fetchSevenElevenProducts(category: selectedCategory)
                }
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String, category: String) -> [Product] {
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.sevenEleven.rawValue, category: category)
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
