//
//  Product.swift
//  SaleWar
//
//  Created by 부재식 on 5/6/25.
//

import Foundation
import RealmSwift

class Product: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var img: String
    @Persisted var title: String
    @Persisted var price: String
    @Persisted var saleFlag: String
    
    func toString() -> String {
        return "Product(img: \(img), title: \(title), price: \(price), saleFlag: \(saleFlag))"
    }
}


