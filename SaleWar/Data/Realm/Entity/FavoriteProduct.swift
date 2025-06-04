//
//  FavoriteProduct.swift
//  SaleWar
//
//  Created by 2beone on 5/27/25.
//

import Foundation
import RealmSwift

class FavoriteProduct: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var img: String
    @Persisted var title: String
    @Persisted var price: String
    @Persisted var saleFlag: String
    @Persisted var store: String
    
    convenience init(product: Product) {
        self.init()
        
        self.img = product.img
        self.title = product.title
        self.price = product.price
        self.saleFlag = product.saleFlag
        self.store = product.store
    }
}

//class Product: Object, ObjectKeyIdentifiable {
//    @Persisted(primaryKey: true) var id: ObjectId
//    @Persisted var img: String
//    @Persisted var title: String
//    @Persisted var price: String
//    @Persisted var saleFlag: String
//    @Persisted var store: String
//    
//    convenience init(jsonProduct: ProductJSON, store: String) {
//            self.init() // Call the superclass initializer
//            // Realm automatically assigns an ObjectId if not provided for primary key
//            self.img = jsonProduct.img
//            self.title = jsonProduct.title
//            self.price = jsonProduct.price
//            self.saleFlag = jsonProduct.saleFlag
//            self.store = store
//        }
//    
//    func toString() -> String {
//        return "Product(img: \(img), title: \(title), price: \(price), saleFlag: \(saleFlag)), store: \(store)"
//    }
//}
