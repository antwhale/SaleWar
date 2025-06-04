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
    var gs25NotificationToken: NotificationToken?
    var cuNotificationToken: NotificationToken?
    var sevenElevenNotificationToken: NotificationToken?
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
    
//    static func searchProducts(byPartialTitle partialTitle: String) -> Results<Product> {
//            guard let realm = try? Realm() else {
//                print("Error: Could not initialize Realm.")
//                // You might want to return an empty Results<Product> or handle this differently
//                return Realm().objects(Product.self).filter("FALSE") // Returns an empty Results
//            }
//
//            // Query Realm for Products where the title contains the partialTitle (case-insensitive)
//            return realm.objects(Product.self).filter("title CONTAINS[c] %@", partialTitle)
//        }
    
    func searchProducts(byPartialTitle partialTitle: String, for store: String) -> [Product] {
        do {
            let realm = try Realm()
            let result = realm.objects(Product.self)
                .filter("title CONTAINS[c] %@", partialTitle)
                .filter("store == %@", store)   
            return Array(result)
        } catch {
            print("Error searchProducts: \(error)")
            return []
        }
    }
    
    func observeProducts(store: StoreType, onUpdateProducts: @escaping ([Product]) -> Void) {
        let realm = try! Realm()
        let results = realm.objects(Product.self).filter("store == %@", store.rawValue)
        
        gs25NotificationToken = results.observe { change in
            switch change {
            case .initial:
                print("observeProducts, initial")
                onUpdateProducts(Array(results))
            case .update(_, let deletions, let insertions, let modifications):
                print("observeProducts, update")
                onUpdateProducts(Array(results))
            case .error(let error):
                print("observeProducts, \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: 좋아요 상품관련
    func addFavoriteProduct(favorite product: FavoriteProduct) {
        do {
            let realm = try Realm()
            realm.writeAsync {
                realm.add(product, update: .modified)
            }
        } catch {
            print("Error adding favorite product: \(error)")
        }
    }
    
    func deleteFavoriteProduct(favorite product: FavoriteProduct) {
        do {
            let realm = try Realm()
            realm.writeAsync {
                if self.isFavoriteProduct(productName: product.title) {
                    let productsToDelete = realm.objects(FavoriteProduct.self).filter("title == %@", product.title)
                    realm.delete(productsToDelete)
                    print("Finished deleteFavoriteProduct")
                }
            }
        } catch {
            print("Error deleting favorite product: \(error)")
        }
    }
    
    func isFavoriteProduct(productName: String) -> Bool {
        do {
            let realm = try Realm()
            let favoriteProduct = realm.objects(FavoriteProduct.self).filter("title == %@", productName).first
            return favoriteProduct != nil
        } catch {
            print("Error fetching favorite products: \(error)")
            return false
        }
    }
    
    func invalidateProductNotificationToken(for store: StoreType) {
        print("invalidateGS25NotificationToken")
        
        if(store == .gs25) {
            gs25NotificationToken?.invalidate()
        } else if (store == .cu) {
            cuNotificationToken?.invalidate()
        } else if(store == .sevenEleven) {
            sevenElevenNotificationToken?.invalidate()
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
