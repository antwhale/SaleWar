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
    
    //MARK: 상품관련
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
    
    //MARK: json 파일 업데이트 정보
    func saveLastFetchInfo(newDate: String) {
            do {
                if let existingInfo = getLastFetchInfo() {
                    try realm.write {
                        realm.delete(existingInfo)
                        let newInfo = LastFectchInfo(value: newDate)
                        realm.add(newInfo)
                    }
                } else {
                    try realm.write {
                        let newInfo = LastFectchInfo(value: newDate)
                        realm.add(newInfo)
                    }
                }
            } catch {
                print("Error saving LastFetchInfo: \(error)")
            }
        }
    
    func getLastFetchInfo() -> LastFectchInfo? {
        // Since we only want one, we'll fetch the first one.
        return realm.objects(LastFectchInfo.self).first
    }
    
    
    
    
    
}
