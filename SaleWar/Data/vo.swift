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
    
    var brandLogo : String {
        switch self {
        case .gs25: return "gs25_logo"
        case .cu: return "cu_logo"
        case .sevenEleven: return "7-eleven_logo"
        }
    }
    
    static func getBrandLogo(from store: String) -> String {
        switch store {
        case StoreType.gs25.rawValue: return StoreType.gs25.brandLogo
        case StoreType.cu.rawValue: return StoreType.cu.brandLogo
        case StoreType.sevenEleven.rawValue: return StoreType.sevenEleven.brandLogo
        default: return StoreType.gs25.brandLogo
        }
    }
}

struct ProductJSON: Decodable {
    let img: String
    let title: String
    let price: String // JSON has "4,000원", so it's a String
    let saleFlag: String
}

