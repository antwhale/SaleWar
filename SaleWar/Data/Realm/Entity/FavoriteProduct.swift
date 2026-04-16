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
    @Persisted var category: String = ""
    @Persisted var productDescription: String = ""
    
    convenience init(product: Product) {
        self.init()
        
        self.img = product.img
        self.title = product.title
        self.price = product.price
        self.saleFlag = product.saleFlag
        self.store = product.store
        self.category = product.category ?? ""
        self.productDescription = product.description ?? ""
    }
    
    convenience init(productInfo: ProductInfo) {
        self.init()
        
        self.img = productInfo.img
        self.title = productInfo.title
        self.price = productInfo.price
        self.saleFlag = productInfo.saleFlag
        self.store = productInfo.store
        self.category = productInfo.category ?? ""
        self.productDescription = productInfo.productDescription ?? ""
    }
}

struct FavoriteProductInfo {
    var img: String
    var title: String
    var price: String
    var saleFlag: String
    var store: String
    var category: String = ""
    var productDescription : String = ""
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
