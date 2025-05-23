//
//  vo.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation

enum SaleWarTab {
    case gs25
    case cu
    case seven_eleven
}

enum StoreType: String, CaseIterable {
    case gs25 = "GS25"
    case cu = "CU"
    case sevenEleven = "SevenEleven"
    
    var rawJSONURL : String {
        switch self {
        case .gs25: return "https://raw.githubusercontent.com/antwhale/SaleWar/main/GS25_Product.json"
        case .cu: return "https://raw.githubusercontent.com/antwhale/SaleWar/main/CU_Product.json"
        case .sevenEleven: return "https://raw.githubusercontent.com/antwhale/SaleWar/main/SevenEleven_Product.json"
        }
    }
}

struct ProductJSON: Decodable {
    let img: String
    let title: String
    let price: String // JSON has "4,000원", so it's a String
    let saleFlag: String
}

//struct Product: Identifiable, Codable { // Conform to Identifiable and Codable
//    let id = UUID() // Add an ID for Identifiable conformance, needed for Lists, etc.
//    var img: String // Use var if you need to modify the properties
//    var title: String
//    var price: String
//    var saleFlag: String
//
//    // Swift automatically generates an initializer, so you don't need to define it manually.
//    //  init(img: String, title: String, price: String, saleFlag: String) {
//    //      self.img = img
//    //      self.title = title
//    //      self.price = price
//    //      self.saleFlag = saleFlag
//    //  }
//
//     //  Added a computed property for a better description
//    var toString: String {
//           return "Product(img: \(img), title: \(title), price: \(price), saleFlag: \(saleFlag))"
//    }
//}


