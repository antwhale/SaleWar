//
//  GS25ViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import Combine
import RealmSwift

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
    
    @Published var selectedCategory: String = ""
    @Published var categories: [String] = []
        
    func fetchGS25Products(category: String) {
        print("fetchGS25Products, category: \(category)")
        
        let realmManager = RealmManager.shared
        let store = StoreType.gs25.rawValue
        
        // 1. 조건에 따른 데이터 조회
        var results: Results<Product>?
        if category.isEmpty || category == "전체" {
            results = realmManager.getProducts(forStore: store)
        } else {
            results = realmManager.getProducts(forStore: store, category: category)
        }
        
        // 2. 결과 처리 (Guard 문으로 통합)
        guard let gs25Products = results else {
            print("No GS25 Products")
            self.productList = []
            return
        }
        
        print("gs25Products count: \(gs25Products.count)")
        
        // 3. UI 업데이트 (Array 변환 및 할당)
        self.productList = Array(gs25Products)
    }
    
    func observeGS25Products() {
        print("observeGS25Products")
        
        let realmManager = RealmManager.shared
        realmManager.observeProducts(store: StoreType.gs25) { [weak self] results in
            guard let isProductsEmpty = self?.productList.isEmpty else { return }
//            print("resluts: \(results)")
//            print("observeGS25Products thread: \(OperationQueue.current == OperationQueue.main)")
            if isProductsEmpty {
                self?.productList = results
            } else {
                self?.productList.removeAll()
                self?.productList = results
            }
        }
        
        categories = realmManager.getCategories(store: StoreType.gs25)
        categories.insert("전체", at: 0)
    }
    
    func observeSearchKeyword() {
        print("GS25ViewModel observeSearchKeyword")
        
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
                    // 키워드가 있을 때는 검색 로직 실행 (카테고리 포함)
                    let searchResult = self.performSearch(with: keyword, category: category)
                    self.productList = searchResult
                } else {
                    // 키워드가 없을 때는 카테고리별 전체 상품 조회
                    self.fetchGS25Products(category: category)
                }
            }
            .store(in: &cancellableBag)
    }
    
    func performSearch(with keyword: String, category: String) -> [Product] {
        
        print("GS25ViewModel performSearch(with:) \(keyword), category: \(category)")
        
        let realmManager = RealmManager.shared
        return realmManager.searchProducts(byPartialTitle: keyword, for: StoreType.gs25.rawValue, category: category)
    }
    
    func addFavoriteProduct(_ product: Product) {
        Task {
            print("addFavoriteProduct")
            let realmManager = RealmManager.shared
//            await realmManager.addFavoriteProduct(favorite: FavoriteProduct(product: product))
            await realmManager.addFavoriteProduct(productInfo: ProductInfo(product: product))
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
        print(#fileID, #function, #line, "deinit")

        let realmManager = RealmManager.shared
        realmManager.invalidateProductNotificationToken(for: .gs25)
        
        cancellableBag.removeAll()
    }
}
