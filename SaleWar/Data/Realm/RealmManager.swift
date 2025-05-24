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
    
//    lazy var realm: Realm = {
//        do {
//            print("Realm init, thread: \(OperationQueue.current == OperationQueue.main)")
//            let realm = try Realm()
//            return realm
//
//        } catch  {
//            fatalError("Failed to initialize Realm: \(error)")
//        }
//    }()
    
    //MARK: 상품관련
    func addProduct(product: Product) {
        do {
            let realm = try Realm()
            realm.writeAsync {
                realm.add(product, update: .all)
            }
        } catch {
            print("Error add product: \(error)")
        }
    }
    
    func addProducts(products: [Product]) {
        do {
            let realm = try Realm()
            realm.writeAsync {
                realm.add(products, update: .all)
                print("Added/Updated \(products.count) products in bulk.")
            }
        } catch {
            print("Error adding products in bulk: \(error)")
        }
    }
    
    func getProducts() -> Results<Product>? {
        do {
            let realm = try Realm()
            return realm.objects(Product.self)
        } catch {
            print("Error occurs when getProducts")
            return nil
        }
    }
    
    func getProducts(forStore store: String) -> Results<Product>? {
        do {
            let realm = try Realm()
            return realm.objects(Product.self).filter("store == %@", store)
        } catch {
            print("Error occurs when getProducts")
            return nil;
        }
    }
    
    func deleteProduct(product: Product) {
        do {
            let realm = try Realm()
            realm.writeAsync {
                if let productToDelete = realm.object(ofType: Product.self, forPrimaryKey: product.id) {
                    realm.delete(productToDelete)
                }
            }
        } catch {
            print("Error deleting product: \(error)")  // Handle errors
        }
    }
    
    func deleteProducts(forStore store: String) {
        do {
            let realm = try Realm()
            realm.writeAsync {
                let productsToDelete = realm.objects(Product.self).filter("store == %@", store)
                realm.delete(productsToDelete)
                print("Deleted all products for store: \(store)")
            }
        } catch {
            print("Error deleting products for store \(store): \(error)")
        }
    }
    
    func deleteAllProduct() {
        do {
            let realm = try Realm()
            realm.writeAsync {
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
//            if let existingInfo = getLastFetchInfo() {
            let realm = try Realm()
            realm.writeAsync {
                if let existingInfo = self.getLastFetchInfo() {
                    realm.delete(existingInfo)
                    let newInfo = LastFectchInfo(value: newDate)
                    realm.add(newInfo)
                } else {
                    let newInfo = LastFectchInfo(value: newDate)
                    realm.add(newInfo)
                }
                
            }
//            } else {
//                try realm.write {
//                    let newInfo = LastFectchInfo(value: newDate)
//                    realm.add(newInfo)
//                }
//            }
        } catch {
            print("Error saving LastFetchInfo: \(error)")
        }
    }
    
    func getLastFetchInfo() -> LastFectchInfo? {
        print("getLastFetchInfo, thread: \(OperationQueue.current == OperationQueue.main)")
        do {
            let realm = try Realm()
            // Since we only want one, we'll fetch the first one.
            return realm.objects(LastFectchInfo.self).first
        } catch {
            print("Error occurs when getLastFetchInfo")
            return nil
        }
        
    }
    
    
    
    
    
    
    
}
