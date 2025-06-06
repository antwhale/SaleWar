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
    @Published var fetchingFlag = false
    @Published var favoriteProducts : [FavoriteProduct] = []
        
    init() {
        print("AppViewModel init")
                
        checkProductVersion()
        observeFavoriteProducts()
    }
    
    func checkProductVersion() {
        print(#fileID, #function, #line, "checkProductVersion")
        
        Task {
            fetchingFlag = true
            let result = await self.readFileAsync(from: PRODUCT_VERSION_URL)
            switch result {
                case .success(let serverDate):
                print(#fileID, #function, #line, "checkProductVersion, success: \(serverDate)")
                let newDate = await getLastFetchDate()
                print("newDate: \(newDate)")
                print("check date length: \(serverDate.count) vs \(newDate.count)")
                let needToUpdate = checkUpdate(currentDate: serverDate.trimmingCharacters(in: .newlines), newDate: newDate)
//                initAllSaleInfo()
                if(needToUpdate) {
                    initAllSaleInfo()
                } else {
                    print(#fileID, #function, #line, "Don't need to update sale info")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.fetchingFlag = false
                }
                case .failure(let error):
                print(#fileID, #function, #line, "checkProductVersion, failure : \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.fetchingFlag = false
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
    
    func deleteFavoriteProduct(product: FavoriteProduct) {
        print(#fileID, #function, #line, "deleteFavoriteProduct")
        
        let realmManager = RealmManager.shared
        realmManager.deleteFavoriteProduct(favorite: product)
    }
    
    func initAllSaleInfo() {
        initSaleInfo(for: StoreType.gs25)
        initSaleInfo(for: StoreType.cu)
        initSaleInfo(for: StoreType.sevenEleven)
        
    }
    
    func initSaleInfo(for storeType: StoreType) {
        DispatchQueue.global(qos: .background).async {
            print(#fileID, #function, #line, "initSaleInfo, \(storeType.rawValue)")
            
            guard let url = URL(string: storeType.rawJSONURL) else {
                print(#fileID, #function, #line, "Error: Invalid URL string: \(storeType.rawValue)")
                return
            }
            print("make url object")
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                print("connecting...")
                if let error = error {
                    print(#fileID, #function, #line, "Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    print(#fileID, #function, #line, "HTTP Error: Invalid status code \(statusCode)")
                    return
                }
                
                guard let data = data else {
                    print(#fileID, #function, #line, "Error: No data received from URL.")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let productJSONs = try decoder.decode([ProductJSON].self, from: data)
                    let realmProducts = productJSONs.map {
                        Product(jsonProduct: $0, store: storeType.rawValue)
                    }
                    
                    DispatchQueue.main.async {
                        let realmManager = RealmManager.shared
                        realmManager.deleteProducts(forStore: storeType.rawValue)
                        realmManager.addProducts(products: realmProducts)

                        print(#fileID, #function, #line, "RealmDB update complete!")
                        
                        if(storeType == .sevenEleven) {
                            self.saveSaleInfoUpdateDate(realmManager: realmManager)
                        }

                        if let fetchedProducts = realmManager.getProducts() {
                            print(#fileID, #function, #line, "Products in Realm: \(fetchedProducts.count)")
                        }
                    }
                    
                } catch {
                    print(#fileID, #function, #line, "Error decoding product data: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }
    }
    
    func saveSaleInfoUpdateDate(realmManager : RealmManager) {
        let newDate = self.getCurrentYYMM()
        print("saveSaleInfoUpdateDate, newDate: \(newDate)")

        realmManager.saveLastFetchInfo(newDate: newDate)
    }
    
    func getLastFetchDate() async -> String {
        print("getLastFetchDate, thread: \(OperationQueue.current == OperationQueue.main)")
        let realmManager = RealmManager.shared
        let lastFetchInfo = realmManager.getLastFetchInfo()
        guard let lastFetchDate = lastFetchInfo?.date else {
            return ""
        }
        return lastFetchDate
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
