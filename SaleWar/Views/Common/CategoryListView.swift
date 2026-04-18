//
//  CategoryListView.swift
//  SaleWar
//
//  Created by 부재식 on 4/17/26.
//

import SwiftUI

struct CategoryListView: View {
    let categories: [String]
    let selectedCategory: String
    let onCategorySelected: (String) -> Void // @escaping (String) -> Void
    
    // 색상 정의 (Compose의 unselectedCategoryBG 등과 대응)
    let unselectedCategoryBG = Color(white: 0.9)
    let unselectedCategoryTextColor = Color.gray

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: category == selectedCategory,
                        onClick: { onCategorySelected(category) }
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct CategoryChip: View {
    let category: String
    let isSelected: Bool
    let onClick: () -> Void
    
    let unselectedCategoryBG = Color(white: 0.9)
    let unselectedCategoryTextColor = Color.gray

    var body: some View {
        Text(category)
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            // 선택 상태에 따른 색상 변경 및 애니메이션
            .foregroundColor(isSelected ? .black : unselectedCategoryTextColor)
            .background(isSelected ? Color.white : unselectedCategoryBG)
            .clipShape(Capsule()) // Compose의 CircleShape와 동일한 효과
            // 그림자 효과 (Compose의 tonalElevation 대응)
            .shadow(color: isSelected ? .black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
            .onTapGesture {
                onClick()
            }
            // 상태 변화 애니메이션 적용
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
