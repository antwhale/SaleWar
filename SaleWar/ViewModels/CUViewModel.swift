//
//  CUViewModel.swift
//  SaleWar
//
//  Created by 2beone on 5/26/25.
//

import Foundation
import Combine
import RealmSwift

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
    
    @Published var selectedCategory: String = ""
    @Published var categories: [String] = []
    
    func fetchCUProducts(category: String) {
        print("fetchCUProducts, category: \(category)")
        
        let realmManager = RealmManager.shared
        let store = StoreType.cu.rawValue
        
        // 1. 조건에 따른 데이터 조회
        var results: Results<Product>?
        if category.isEmpty || category == "전체" {
            results = realmManager.getProducts(forStore: store)
        } else {
            results = realmManager.getProducts(forStore: store, category: category)
        }
        
        // 2. 결과 처리 (Guard 문으로 통합)
        guard let cuProducts = results else {
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
            guard let isProductsEmpty = self?.productList.isEmpty else {
                print("observeCUProducts, isProductsEmpty is nil")
                return
            }
            
            print("observeCUProducts, isProductsEmpty: \(isProductsEmpty)")
            
            if isProductsEmpty {
                self?.productList = results
            } else {
                self?.productList.removeAll()
                self?.productList = results
            }
        }
        
        categories = realmManager.getCategories(store: StoreType.cu)
        categories.insert("전체", at: 0)
    }
    
    func observeSearchKeyword() {
        print("CUViewModel observeSearchKeyword")
        
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
                    print(#fileID, #function, #line, "keyword : \(keyword), category: \(selectedCategory)")
                    
                    let searchResult = self.performSearch(with: keyword, category: selectedCategory)
                    self.productList = searchResult
                } else {
                    print(#fileID, #function, #line, "keyword is empty, category: \(selectedCategory)")

                    //전체 검색한 결과 보여주기
                    self.fetchCUProducts(category: selectedCategory)
                }
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String, category: String) -> [Product] {
        print("performSearch(with:) \(keyword)")
        
        let realmManager = RealmManager.shared
        return realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.cu.rawValue, category: category)
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
