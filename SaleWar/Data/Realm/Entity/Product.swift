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
    @Persisted var store: String
    
    convenience init(jsonProduct: ProductJSON, store: String) {
            self.init() // Call the superclass initializer
            // Realm automatically assigns an ObjectId if not provided for primary key
            self.img = jsonProduct.img
            self.title = jsonProduct.title
            self.price = jsonProduct.price
            self.saleFlag = jsonProduct.saleFlag
            self.store = store
        }
    
    func toString() -> String {
        return "Product(img: \(img), title: \(title), price: \(price), saleFlag: \(saleFlag)), store: \(store)"
    }
}



