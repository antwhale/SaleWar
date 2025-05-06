//
//  RealmManager.swift
//  SaleWar
//
//  Created by 부재식 on 5/6/25.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    lazy var realm: Realm = {
        do {
            let realm = try Realm()
            return realm

        } catch  {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }()
    
    func addProduct(product: Product) {
        do {
            try realm.write {
                realm.add(product, update: .all)
            }
        } catch {
            print("Error add product: \(error)")
        }
    }
    
    func getProducts() -> Results<Product>? {
        return realm.objects(Product.self)
    }
    
    func deleteProduct(product: Product) {
        do {
            try realm.write {
                if let productToDelete = realm.object(ofType: Product.self, forPrimaryKey: product.id) {
                    realm.delete(productToDelete)
                }
            }
        } catch {
            print("Error deleting product: \(error)")  // Handle errors
        }
    }
    
    func deleteAllProduct(product: Product) {
        do {
            try realm.write {
                let allProducts = realm.objects(Product.self)
                realm.delete(allProducts)
            }
        } catch {
            print("Error deleting all products: \(error)")
        }
    }
}
