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
    @Published var updateFlag = false
        
    init() {
        print("AppViewModel init")
        RealmManager.init()
        checkProductVersion()
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
                case .success(let serverVersion):

                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                print(#fileID, #function, #line, "currentVersion: \(currentVersion), serverVersion: \(serverVersion)")

                let needToUpdate = checkUpdate(currentVersion: currentVersion, serverVersion: serverVersion.trimmingCharacters(in: .newlines))
                print(#fileID, #function, #line, "needToUpdate : \(needToUpdate)")

                if(needToUpdate) {
                    //업데이트 팝업
                    await MainActor.run {
                        updateFlag = true
                        fetchingFlag = false
                    }
                    
                } else {
                    //데이터 최신인지 확인 -> 최신이면 바로 다음화면 / 최신아니면
                    let currentDBVersion = RealmManager.shared.getLastFetchDate()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
//                    let currentYYMM = self.getCurrentYYMM().trimmingCharacters(in: .whitespacesAndNewlines)
                    let currentYYMM = "2605"
                    
                    print("currentDBVersion: \(currentDBVersion) , currentYYMM: \(currentYYMM)")
                    
                    if(currentDBVersion == currentYYMM) {
                        //DB 최신상태
                        await MainActor.run {
                            fetchingFlag = false
                        }
                    } else {
                        //DB 최신상태아니라서 업데이트 필요
                        initAllSaleInfo()
                    }
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
                
            // 1. Resources 폴더에서 JSON 파일 경로 찾기
            let fileName = storeType.jsonFileName
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print(#fileID, #function, #line, "Error: Local JSON file not found: \(fileName).json")
                return
            }
            
            // 2. 파일에서 Data 읽어오기 (비동기 처리 불필요하지만 구조 유지를 위해 그대로 둠)
            let data = try Data(contentsOf: url)
            print("Successfully loaded local JSON: \(fileName).json")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let productJSONs = try decoder.decode([ProductJSON].self, from: data)
//            print("productJSONs: \(productJSONs)")
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
    
    func updateFavoriteProducts() {
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
            realmManager.updateFavoriteProduct(productId: favoriteProduct.id, productTitle: favoriteProduct.title, productStore: favoriteProduct.store, productSaleFlag: favoriteProduct.saleFlag, productImg: favoriteProduct.img, productPrice: favoriteProduct.price, isSale: isSaleProduct)
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
    //currentDate: 서버 세일정보 버전 | newDate: 앱 최근 세일정보 버전
    func checkUpdate(currentVersion: String, serverVersion: String) -> Bool {
        print("checkUpdate, currentVersion: \(currentVersion) serverVersion: \(serverVersion) count: \(currentVersion.count) \(serverVersion.count)")
        // .numeric 옵션을 사용하면 "1.0.10"이 "1.0.2"보다 크다고 올바르게 판단합니다.
            let result = serverVersion.compare(currentVersion, options: .numeric)
            
            // 서버 버전이 현재 버전보다 높으면(OrderedDescending) 업데이트 필요(true)
            return result == .orderedDescending
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
