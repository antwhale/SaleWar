//
//  AppViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import Combine
import RealmSwift

class AppViewModel: BaseViewModel {
    var cancellableBag = Set<AnyCancellable>()
//    private var realmManager: RealmManager
    
    @Published var selectedTab : SaleWarTab = .gs25
    @Published var fetchingFlag = true
    @Published var favoriteProducts : [FavoriteProduct] = []
        
    init() {
        print("AppViewModel init")
                
        checkProductVersion()
//        observeFavoriteProducts()
    }
    
    func checkProductVersion() {
        print(#fileID, #function, #line, "checkProductVersion")
        
        Task {
            await MainActor.run {
                print(#fileID, #function, #line, "fetching start")
                fetchingFlag = true
            }
            let result = await self.readFileAsync(from: PRODUCT_VERSION_URL)
            switch result {
                case .success(let serverDate):
                print(#fileID, #function, #line, "checkProductVersion, success: \(serverDate)")
                let newDate = getLastFetchDate()
                print("newDate: \(newDate)")
                print("check date length: \(serverDate.count) vs \(newDate.count)")
                let needToUpdate = checkUpdate(currentDate: serverDate.trimmingCharacters(in: .newlines), newDate: newDate)
                    initAllSaleInfo()
                    
                if(needToUpdate) {
                    initAllSaleInfo()
                } else {
                    print(#fileID, #function, #line, "Don't need to update sale info")
                }
                
                
                case .failure(let error):
                print(#fileID, #function, #line, "checkProductVersion, failure : \(error.localizedDescription)")
                await MainActor.run {
                    print(#fileID, #function, #line, "fetching End")
                    fetchingFlag = false
                }
            }
        }
    }
    
    
    func observeFavoriteProducts() {
        print(#fileID, #function, #line, "observeFavoriteProductList")

        let realmManager = RealmManager.shared
        realmManager.observeFavoriteProducts() { [weak self] favoriteProducts in
            guard let self = self else { return }
            self.favoriteProducts = favoriteProducts
        }
    }
    
    func getFavoriteProducts() -> Results<FavoriteProduct> {
        print(#fileID, #function, #line, "getFavoriteProducts")

        let realmManager = RealmManager.shared
        return realmManager.getFavoriteProducts()
    }
    
    func deleteFavoriteProduct(productTitle: String) async {
        print(#fileID, #function, #line, "deleteFavoriteProduct")
        
        let realmManager = RealmManager.shared
        await realmManager.deleteFavoriteProduct(productTitle)
    }
    
    func initAllSaleInfo() {
        Task {
            await initSaleInfo(for: StoreType.gs25)
            await initSaleInfo(for: StoreType.cu)
            await initSaleInfo(for: StoreType.sevenEleven)
            await updateFavoriteProducts()
            try await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                print(#fileID, #function, #line, "fetching End")
                fetchingFlag = false
//                observeFavoriteProducts()
            }
        }
    }
    
    func initSaleInfo(for storeType: StoreType) async {
        do {
            
            print(#fileID, #function, #line, "initSaleInfo, \(storeType.rawValue)")
                
            guard let url = URL(string: storeType.rawJSONURL) else {
                print(#fileID, #function, #line, "Error: Invalid URL string: \(storeType.rawValue)")
                return
            }
            print("make url object")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            print("connected with \(storeType.rawValue)")
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print(#fileID, #function, #line, "HTTP Error: Invalid status code \(statusCode)")
                return
            }
            
            
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let productJSONs = try decoder.decode([ProductJSON].self, from: data)
            let realmProducts = productJSONs.map {
                Product(jsonProduct: $0, store: storeType.rawValue)
            }
            
            let realmManager = RealmManager.shared
            
            await realmManager.deleteProducts(forStore: storeType.rawValue)
            
            await realmManager.addProducts(products: realmProducts)

            print(#fileID, #function, #line, "RealmDB update complete!")
            
            if(storeType == .sevenEleven) {
                await self.saveSaleInfoUpdateDate(realmManager: realmManager)
            }
            let fetchedProducts = realmManager.getProducts()

            if fetchedProducts != nil {
                print(#fileID, #function, #line, "Products in Realm: \(fetchedProducts!.count)")
            }
            
            
        } catch {
            print(#fileID, #function, #line, "Error decoding product data: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                print("fetchingFlag false")
                self?.fetchingFlag = false
            }
        }
        
            
        
    }
    
    func updateFavoriteProducts() async {
        print(#fileID, #function, #line, "updateFavoriteProducts")
        
        //현재 좋아요 상품들을 db에 조회해서 존재하는지 확인
        //있으면 놔두고 없으면 saleFlag를 빈문자열로 초기화

        let realmManager = RealmManager.shared
        let favoriteProducts = realmManager.getFavoriteProducts()
        let favoriteProductArray = Array(favoriteProducts)
        
        for favoriteProduct in favoriteProductArray {
            let isSaleProduct = realmManager.isSaleProduct(favorite: favoriteProduct)
            print("\(favoriteProduct.title) isSaleProduct: \(isSaleProduct)")
//            await realmManager.updateFavoriteProduct(favorite: favoriteProduct, isSale: isSaleProduct)         
            await realmManager.updateFavoriteProduct(productId: favoriteProduct.id, productTitle: favoriteProduct.title, productStore: favoriteProduct.store, productSaleFlag: favoriteProduct.saleFlag, productImg: favoriteProduct.img, productPrice: favoriteProduct.price, isSale: isSaleProduct)
        }
    }
    
    func saveSaleInfoUpdateDate(realmManager : RealmManager) async {
        let newDate = self.getCurrentYYMM()
        print("saveSaleInfoUpdateDate, newDate: \(newDate)")

        await realmManager.saveLastFetchInfo(newDate: newDate)
    }
    
    func getLastFetchDate() -> String {
        print("getLastFetchDate, thread: \(OperationQueue.current == OperationQueue.main)")
        let realmManager = RealmManager.shared
        return realmManager.getLastFetchDate() ?? ""
    }
   
    func readFileAsync(from urlString: String) async -> Result<String, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        
        do {
            // Use URLSession.shared.data(from: url) for asynchronous data fetching.
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                return .failure(URLError(.badServerResponse, userInfo: ["statusCode" : statusCode]))
            }
            
            //Convert the data to a string. Handle potential encoding issues.
            guard let content = String(data: data, encoding: .utf8) else {
                return .failure(URLError(.cannotDecodeContentData))
            }
            
            return .success(content)
        } catch {
            return .failure(error)
        }
    }

    //true면 상품정보 다시 읽어와야하고 false면 최신 상품정보 저장 중이므로 업데이트 필요없음
    func checkUpdate(currentDate: String, newDate: String) -> Bool {
        print("checkUpdate, currentDate: \(currentDate) newDate: \(newDate) count: \(currentDate.count) \(newDate.count)")
        // Check if the input strings are valid.
        guard currentDate.count == 4, newDate.count == 4 else {
            print("checkUpdate, invalid input so return true")
            return true // Handle invalid input
        }
        
        // Extract year and month components.
        guard let currentYear = Int(currentDate.prefix(2)),
              let currentMonth = Int(currentDate.suffix(2)),
              let newYear = Int(newDate.prefix(2)),
              let newMonth = Int(newDate.suffix(2)) else {
            print("checkUpdate, can not divide YYMM so return true")

            return true // Handle invalid numeric values
        }
        
        // Perform the comparison.
        if currentYear < newYear {
            print("checkUpdate, currentYear < newYear")
            return false
        } else if currentYear > newYear {
            print("checkUpdate, currentYear > newYear")
            return true
        } else { // Years are equal, compare months.
            if currentMonth < newMonth {
                print("checkUpdate, currentMonth < newMonth")
                return false
            } else if currentMonth > newMonth {
                print("checkUpdate, currentMonth > newMonth")
                return true
            } else {
                print("checkUpdate, Years and months are equal")
                return false
            }
        }
    }
    
    func getCurrentYYMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMM"
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    deinit {
        print("AppViewModel deinit")
        
        let realmManager = RealmManager.shared
        realmManager.invalidateFavoriteProductsNotificationToken()
    }
}
