//
//  BaseBackgroundView.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import Foundation
import SwiftUI

struct BaseBackgroundView: View {
    var body: some View {
        let lightGray = Color(red: 232/255, green: 232/255, blue: 232/255)
        
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: geometry.size.height * (3/5))

                Rectangle()
                    .fill(Color.yellow)
                    .frame(height: geometry.size.height * (2/5))
            }
        }
    }
}
