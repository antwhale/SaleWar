//
//  ContentView.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                if(appViewModel.selectedTab == .gs25) {
                    GS25View(
                        onSelectedTab: { (tab) in appViewModel.selectedTab = tab }
                    )
                } else if(appViewModel.selectedTab == .cu) {
                    CUView(
                        onSelectedTab: { (tab) in appViewModel.selectedTab = tab }
                    )
                } else if(appViewModel.selectedTab == .seven_eleven) {
                    SevenElevenView(
                        onSelectedTab: { (tab) in appViewModel.selectedTab = tab }
                    )
                }
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}

struct SaleWarTabView: View {
    var onSelectedTab: (SaleWarTab) -> Void
    
    var body: some View {
        HStack {
            SaleWarTabItem(
                brand_logo: "gs25_logo",
                onSelectedTab: onSelectedTab
            )
            .layoutPriority(1)

            SaleWarTabItem(
                brand_logo: "cu_logo",
                onSelectedTab: onSelectedTab
            )
            .layoutPriority(1)
            
            SaleWarTabItem(
                brand_logo: "7-eleven_logo",
                onSelectedTab: onSelectedTab
            )
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(.white))
        .cornerRadius(50) // Rounded corners
//        .padding(.vertical)
    }
}

struct SaleWarTabItem: View {
    let brand_logo: String
    var onSelectedTab: (SaleWarTab) -> Void
    var currentTab : SaleWarTab {
        get {
            if(brand_logo == "gs25_logo") {
                return .gs25
            } else if(brand_logo == "cu_logo") {
                return .cu
            } else if(brand_logo == "7-eleven_logo") {
                return .seven_eleven
            } else {
                return .gs25
            }
        }
    }

    var body: some View {
        Button(action: {
            print("Click \(brand_logo) tab")
            onSelectedTab(currentTab)
        }) {
            Image(brand_logo) // Replace with your actual image
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .cornerRadius(15)
        }.frame(maxWidth:.infinity)
    }
}

#Preview {
    ContentView(appViewModel: AppViewModel())
}

//#Preview {
//    SaleWarTabView(
//        onSelectedTab: {(_) in}
//    )
//}
