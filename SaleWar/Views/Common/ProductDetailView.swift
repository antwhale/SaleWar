//
//  ProductDetailView.swift
//  SaleWar
//
//  Created by 2beone on 5/27/25.
//

import Foundation
import SwiftUI

struct ProductDetailView: View {
    @Binding var product: Product?
    @State var isFavoriteProduct: Bool = false
    var onCanceledDetailView: () -> Void
    var onClickedFavoriteIcon: (Product) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: .topTrailing) {
                    HStack {
                        AsyncImage(url: URL(string: product?.img ?? "")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Show a progress indicator while loading
                                    .frame(width: 100, height: 100)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 150) // Adjust size as needed
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo") // Placeholder if image fails to load
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .onTapGesture { }
                        
                        Spacer()
                            .frame(width: 16)
                        
                        VStack(alignment: .leading) {
                            Text(product?.title ?? "")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(2) // Limit to 2 lines, truncate if longer
                                .multilineTextAlignment(.leading)
                                .onTapGesture { }
                            
                            Spacer()
                                .frame(height: 8)
                            
                            Text(product?.price ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .onTapGesture { }
                            
                            Spacer()
                                .frame(height: 8)
                            
                            Text(product?.saleFlag ?? "")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(saleFlagBackgroundColor(for: product?.saleFlag ?? ""))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                                .onTapGesture { }
                            
                            Spacer()
                                .frame(height: 8)
                            
                            Image(systemName: "heart.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(isFavoriteProduct ? .pink : .gray)
                                .padding(.bottom, 4)
                                .onTapGesture {
                                    isFavoriteProduct.toggle()
                                    onClickedFavoriteIcon(product!)
                                }
                        }
                        .onTapGesture { }
                    }
                    .frame(maxWidth: geometry.size.width - 48, maxHeight: geometry.size.height * 0.33 - 32)
                    .onTapGesture { }
                    
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20, alignment: .trailing)
                        .foregroundColor(.black)
                        .padding(.bottom, 4)
                        .onTapGesture {
                            onCanceledDetailView()
                        }
                }
                .frame(width: geometry.size.width - 16, height: geometry.size.height * 0.33)
                .background(Color.white)
                .cornerRadius(10)
                .onTapGesture { }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black.opacity(0.45))
            .onTapGesture {
                onCanceledDetailView()
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
            return .gray
        }
    }
}

//#Preview {
//    ProductDetailView(product: Binding<nil>)
//}
