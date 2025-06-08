//
//  FavoriteProductList.swift
//  SaleWar
//
//  Created by 부재식 on 6/6/25.
//

import Foundation
import SwiftUI
import RealmSwift

struct FavoriteProductList: View {
    var favoriteProductList: Results<FavoriteProduct>
    var onDeleteFavoriteProduct: (FavoriteProduct) -> Void
    
    var body: some View {
        List {
            Section(header: Text("좋아요 목록")) {
                ForEach(favoriteProductList, id: \.self) { product in
                    FavoriteProductItem(product: product)
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        print("\(index) favorite product will be deleted")
                        let productToDelete = favoriteProductList[index]
                        onDeleteFavoriteProduct(productToDelete)
                    }
                })
            }
        }
    }
}

struct FavoriteProductItem: View {
    var product: FavoriteProduct

    var body: some View {
        ZStack {
            HStack {
                VStack {
                    AsyncImage(url: URL(string: product.img)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Show a progress indicator while loading
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80) // Adjust size as needed
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo") // Placeholder if image fails to load
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(product.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    Text(product.price)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .onTapGesture { }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    HStack {
                        Text(product.saleFlag == "" ? "행사 상품이 아닙니다" : product.saleFlag)
                            .lineLimit(1)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(saleFlagBackgroundColor(for: product.saleFlag))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            .onTapGesture { }
                        
                        Spacer()
                        
                        Image(StoreType.getBrandLogo(from: product.store)) // Replace with your actual image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                    }
                    
                    
                    Spacer()
                        .frame(height: 8)
                }
            }
        }
    }
    
    func saleFlagBackgroundColor(for flag: String) -> Color {
        switch flag {
        case "1+1":
            return .blue
        case "2+1":
            return .green
        default:
            return .red
        }
    }
}
