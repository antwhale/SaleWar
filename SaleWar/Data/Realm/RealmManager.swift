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
    var favoriteProductsToken : NotificationToken?
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
    func addProduct(product: Product) async {
        do {
            let realm = try await Realm()
            
            try await realm.asyncWrite {
                realm.add(product, update: .all)
            }
        } catch {
            print("Error add product: \(error)")
        }
    }
    
    func addProducts(products: [Product]) async {
        do {
            let realm = try await Realm()
            
            try await realm.asyncWrite {
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
            return nil
        }
    }
    
    func deleteProduct(product: Product) async {
        do {
            let realm = try await Realm()
            try await realm.asyncWrite {
                if let productToDelete = realm.object(ofType: Product.self, forPrimaryKey: product.id) {
                    realm.delete(productToDelete)
                }
            }
        } catch {
            print("Error deleting product: \(error)")
        }
    }
    
    func deleteProducts(forStore store: String) async {
        do {
            let realm = try await Realm()
            try await realm.asyncWrite {
                let productsToDelete = realm.objects(Product.self).filter("store == %@", store)
                realm.delete(productsToDelete)
                print("Deleted all products for store: \(store)")
            }
        } catch {
            print("Error deleting products for store \(store): \(error)")
        }
    }
    
    func deleteAllProduct() async {
        do {
            let realm = try await Realm()
            try await realm.asyncWrite {
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
    
    func searchProducts(byPartialTitle partialTitle: String, for store: String) async ->  [Product] {
        do {
            let realm = try await Realm()
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
//                onUpdateProducts(Array(results))
            case .error(let error):
                print("observeProducts, \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: 좋아요 상품관련
    func addFavoriteProduct(favorite product: FavoriteProduct) async {
//        do {
//            let realm = try await Realm()
//            try await realm.asyncWrite {
//                realm.add(product, update: .modified)
//            }
//        } catch {
//            print("Error adding favorite product: \(error)")
//        }
        Task {
            print("RealmManager, addFavoriteProduct")
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(product, update: .modified)
                    print("Successfully added \(product.title) to favorites. mainThread = \(Thread.isMainThread)")
                }
            } catch {
                print("Error adding favorite product: \(error)")
            }
            
        }
    }
    
    func clickFavoriteIcon(productInfo: ProductInfo) async {
        print(#fileID, #function, #line, "clickFavoriteIcon")
        
        let isFavorite = isFavoriteProduct(productName: productInfo.title)
        if isFavorite {
            await deleteFavoriteProduct(productInfo: productInfo)
        } else {
            await addFavoriteProduct(productInfo: productInfo)
        }

    }
    
    func addFavoriteProduct(productInfo: ProductInfo) async {
//        Task {
            print("RealmManager, addFavoriteProduct")
            do {
                let realm = try await Realm()
                try await realm.asyncWrite {
                    realm.add(FavoriteProduct(productInfo: productInfo), update: .modified)
                    print("Successfully added \(productInfo.title) to favorites. mainThread = \(Thread.isMainThread)")
                }
            } catch {
                print(#fileID, #function, #line, "Error adding product: \(error)")
            }
            
//        }
    }
    
    func deleteFavoriteProduct(productInfo: ProductInfo) async {
        do {
            let realm = try await Realm()
            try await realm.asyncWrite {
                let productToDelete = realm.objects(FavoriteProduct.self).filter("title == %@", productInfo.title)
                if !productToDelete.isInvalidated {
                    realm.delete(productToDelete)
                    print(#fileID, #function, #line, "Finished to delete FavoriteProduct")
                }
            }
        } catch {
            print(#fileID, #function, #line, "Error delete product: \(error)")
        }
        
    }
    
    
    
    func deleteFavoriteProduct(_ productTitle: String) async {
        do {
            let realm = try await Realm()
            let isFavoriteProduct = await isFavoriteProduct(productName: productTitle)
            
            if isFavoriteProduct {
                try await realm.asyncWrite {
                    let productToDelete = realm.objects(FavoriteProduct.self).filter("title == %@", productTitle)
                    if !productToDelete.isInvalidated {
                        realm.delete(productToDelete)
                        print("Finished deleteFavoriteProduct")
                    }
                }
            }
        } catch {
            print("Error deleting favorite product: \(error)")
        }
    }
    
//    func isFavoriteProduct(productName: String) async -> Bool {
//        do {
//            print(#fileID, #function, #line, "isFavoriteProduct")
//            let realm = try await Realm()
//            let favoriteProduct = realm.objects(FavoriteProduct.self).filter("title == %@", productName).first
//            return favoriteProduct != nil
//        } catch {
//            print("Error fetching favorite products: \(error)")
//            return false
//        }
//    }
    
    func isFavoriteProduct(productName: String) -> Bool {
        do {
            print(#fileID, #function, #line, "isFavoriteProduct")
            let realm = try Realm()
            let favoriteProduct = realm.objects(FavoriteProduct.self).filter("title == %@", productName).first
            return favoriteProduct != nil
        } catch {
            print("Error fetching favorite products: \(error)")
            return false
        }
    }
    
    func isSaleProduct(favorite product: FavoriteProduct) -> Bool {
        do {
            print(#fileID, #function, #line, "isSaleProduct")

            let realm = try Realm()
            let resultProduct = realm.objects(Product.self)
                .filter("title == %@", product.title)
                .filter("store == %@", product.store)
                .first
            return resultProduct != nil
        } catch {
            print("Error during isSaleProduct: \(error)")
            return false
        }
    }
    
    func updateFavoriteProducts() async {
        do {
            print(#fileID, #function, #line, "updateFavoriteProducts")

            let realm = try await Realm()
            let favoriteProductsToUpdate = Array(realm.objects(FavoriteProduct.self))

            try await realm.asyncWrite {
                let allProducts = realm.objects(Product.self)
                var productTitlesMap: [String: Product] = [:]
                for product in allProducts {
                    productTitlesMap[product.title] = product
                }
                
                
            }
//            let resultProduct = realm.objects(Product.self)
//                .filter("title == %@", product.title)
//                .filter("store == %@", product.store)
//                .first
//            return resultProduct != nil
        } catch {
            print("Error during updateFavoriteProducts: \(error)")
        }
    }
    
    func getFavoriteProducts() -> Results<FavoriteProduct> {
        print(#fileID, #function, #line, "getFavoriteProducts")
        let realm = try! Realm()
        return realm.objects(FavoriteProduct.self)
    }
    
    func observeFavoriteProducts(onUpdateFavoriteProducts: @escaping ([FavoriteProduct]) -> Void) {
        let realm = try! Realm()
        let results = realm.objects(FavoriteProduct.self)
        
        favoriteProductsToken = results.observe() { change in
            switch change {
            case .initial :
                onUpdateFavoriteProducts(Array(results))
            case .update(_, let deletions, let insertions, let modifications):
                print(#fileID, #function, #line, "onUpdate FavoriteProducts")
            case .error(let error):
                print("observeFavoriteProducts, \(error.localizedDescription)")
            }
        }
    }
    
    func updateFavoriteProduct(productId: ObjectId, productTitle: String, productStore: String, productSaleFlag: String, productImg: String, productPrice: String, isSale: Bool) async {
        do {
            let realm = try await Realm()
            try await realm.asyncWrite {
                if let productToUpdate = realm.object(ofType: FavoriteProduct.self, forPrimaryKey: productId) {
                    print(#fileID, #function, #line, "Found productToUpdate")
                    
                    if isSale {
                        print(#fileID, #function, #line, "Update Favorite Product")
                        let resultProduct = realm.objects(Product.self)
                            .filter("title == %@", productTitle)
                            .filter("store == %@", productStore)
                            .first
                        productToUpdate.saleFlag = resultProduct?.saleFlag ?? productSaleFlag
                        productToUpdate.img = resultProduct?.img ?? productImg
                        productToUpdate.price = resultProduct?.price ?? productPrice
                    } else {
                        print(#fileID, #function, #line, "This is not Sale product: \(productTitle)")
                        productToUpdate.saleFlag = ""
                    }
                }
            }
        } catch {
            print("updateFavoriteProduct: \(error)")
        }
    }
    
    func updateFavoriteProduct(product: FavoriteProduct, isSale flag: Bool) async {
        do {
            let realm = try await Realm()
            try await realm.asyncWrite {
                if let productToUpdate = realm.object(ofType: FavoriteProduct.self, forPrimaryKey: product.id) {
                    print(#fileID, #function, #line, "Found productToUpdate")
                    
                    if flag {
                        print(#fileID, #function, #line, "Update Favorite Product")
                        let resultProduct = realm.objects(Product.self)
                            .filter("title == %@", product.title)
                            .filter("store == %@", product.store)
                            .first
                        productToUpdate.saleFlag = resultProduct?.saleFlag ?? product.saleFlag
                        productToUpdate.img = resultProduct?.img ?? product.img
                        productToUpdate.price = resultProduct?.price ?? product.price
                    } else {
                        print(#fileID, #function, #line, "This is not Sale product: \(product.title)")
                        productToUpdate.saleFlag = ""
                    }
                }
            }
        } catch {
            print("updateFavoriteProduct: \(error)")
        }
    }
    
    func invalidateProductNotificationToken(for store: StoreType) {
        print("invalidateProductNotificationToken \(store.rawValue)")
        
        if(store == .gs25) {
            gs25NotificationToken?.invalidate()
        } else if (store == .cu) {
            cuNotificationToken?.invalidate()
        } else if(store == .sevenEleven) {
            sevenElevenNotificationToken?.invalidate()
        }
    }
    
    func invalidateFavoriteProductsNotificationToken() {
        print("invalidateFavoriteProductsNotificationToken")
        favoriteProductsToken?.invalidate()
    }
    
    //MARK: json 파일 업데이트 정보
    func saveLastFetchInfo(newDate: String) async {
            print("Attempting to save LastFetchInfo with date: \(newDate)")
            do {
                let realm = try await Realm() // Get a Realm instance on the current Task's actor

                // All Realm modifications must be done within a write transaction
                try await realm.asyncWrite {
                    // Create a new LastFectchInfo object with the newDate.
                    let newFetchInfo = LastFectchInfo(value: newDate)

                    // Use 'add' with an update policy.
                    // .all or .modified will ensure that if an object with this primary key
                    // already exists, it will be updated (or effectively replaced/merged).
                    // Since 'date' is both the value and the primary key, this effectively
                    // means we're saying "the single record is now represented by this new date string."
                    realm.add(newFetchInfo, update: .all)
                    print("Successfully saved/updated LastFetchInfo with date: \(newDate)")
                }
            } catch {
                print("Error saving LastFetchInfo with date \(newDate): \(error.localizedDescription)")
                // Re-throw the error for the caller to handle
            }
        }
    
    func getLastFetchDate() -> String? {
        print(#fileID, #function, #line, "getLastFetchDate")
        do {
            let realm = try Realm()
            
            print(#fileID, #function, #line, "getLastFetchDate")
            if let result = realm.objects(LastFectchInfo.self).first {
                return result.date
            } else {
                return nil
            }
        } catch {
            print("Error occurs when getLastFetchDate")
            return nil
        }
    }
    
    
    
    
    
    
    
}
