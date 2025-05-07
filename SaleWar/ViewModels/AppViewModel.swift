//
//  AppViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import Combine

class AppViewModel: BaseViewModel {
    let cancellableBag = Set<AnyCancellable>()
    
    private let realmManager: RealmManager
    
    @Published var selectedTab : SaleWarTab = .gs25
    @Published var fetchingFlag = false
        
    init() {
        print("AppViewModel init")
        
        realmManager = RealmManager.shared
        
        checkProductVersion()
    }
    
    func checkProductVersion()  {
        print(#fileID, #function, #line, "checkProductVersion")
        
        Task {
            let result = await self.readFileAsync(from: PRODUCT_VERSION_URL)
            switch result {
                case .success(let serverDate):
                print(#fileID, #function, #line, "checkProductVersion, success: \(serverDate)")
                let newDate = getCurrentYYMM()
                print("newDate: \(newDate)")
                let needToUpdate = checkUpdate(currentDate: serverDate, newDate: newDate)
                if(needToUpdate) {
                    
                } else {
                    
                }
                case .failure(let error):
                print(#fileID, #function, #line, "checkProductVersion, failure : \(error.localizedDescription)")

            }
        }
    }
    async func initAllSaleInfo() {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.initGS25SaleInfo() }
            group.addTask { await self.initCUSaleInfo() }
            group.addTask { await self.initSevenElevenInfo() }
        }
    }
    
    func initGS25SaleInfo() async {
        print(#fileID, #function, #line, "initGS25SaleInfo")
    }
    
    func initCUSaleInfo() async {
        print(#fileID, #function, #line, "initCUSaleInfo")
    }
    
    func initSevenElevenInfo() async {
        print(#fileID, #function, #line, "initSevenElevenInfo")
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
        // Check if the input strings are valid.
        guard currentDate.count == 4, newDate.count == 4 else {
            return false // Handle invalid input
        }
        
        // Extract year and month components.
        guard let currentYear = Int(currentDate.prefix(2)),
              let currentMonth = Int(currentDate.suffix(2)),
              let newYear = Int(newDate.prefix(2)),
              let newMonth = Int(newDate.suffix(2)) else {
            return false // Handle invalid numeric values
        }
        
        // Perform the comparison.
        if currentYear < newYear {
            return true
        } else if currentYear > newYear {
            return false
        } else { // Years are equal, compare months.
            if currentMonth < newMonth {
                return true
            } else if currentMonth > newMonth {
                return false
            } else {
                return false // Years and months are equal.
            }
        }
    }
    
    func getCurrentYYMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMM"
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
}
