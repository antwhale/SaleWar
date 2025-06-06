//
//  ProductGridItem.swift
//  SaleWar
//
//  Created by 부재식 on 5/24/25.
//

import Foundation
import SwiftUI

struct ProductGridItem: View {
    var product: Product
    var onProductClicked: () -> Void

    var body: some View {
        
        VStack(spacing: 8) {
            // Load image from URL
            AsyncImage(url: URL(string: product.img)) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Show a progress indicator while loading
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100) // Adjust size as needed
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
            
            Text(product.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2) // Limit to 2 lines, truncate if longer
                .multilineTextAlignment(.center)
            
            Text(product.price)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(product.saleFlag)
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(saleFlagBackgroundColor(for: product.saleFlag))
                .foregroundColor(.white)
                .cornerRadius(5)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .onTapGesture {
            onProductClicked()
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
