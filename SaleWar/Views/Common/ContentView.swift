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
                        onSelectedTab: { (tab) in if(appViewModel.selectedTab != tab) {appViewModel.selectedTab = tab }},
                        gs25ViewModel: GS25ViewModel(),
                        appViewModel: appViewModel
                    )
                } else if(appViewModel.selectedTab == .cu) {
                    CUView(
                        onSelectedTab: { (tab) in if(appViewModel.selectedTab != tab) {appViewModel.selectedTab = tab} },
                        cuViewModel: CUViewModel(),
                        appViewModel: appViewModel
                    )
                } else if(appViewModel.selectedTab == .seven_eleven) {
                    SevenElevenView(
                        onSelectedTab: { (tab) in if(appViewModel.selectedTab != tab) {appViewModel.selectedTab = tab} },
                        sevenElevenViewModel: SevenElevenViewModel(),
                        appViewModel: appViewModel
                    )
                }
            }
            
            if(appViewModel.fetchingFlag) {
                ProgressView() // Show a progress indicator while loading
                    .frame(width: 180, height: 180)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SaleWarTabView: View {
    var onSelectedTab: (SaleWarTab) -> Void
    
    var body: some View {
        HStack {
            SaleWarTabItem(
                storeType: StoreType.gs25,
                onSelectedTab: onSelectedTab
            )
            .layoutPriority(1)

            SaleWarTabItem(
                storeType: StoreType.cu,
                onSelectedTab: onSelectedTab
            )
            .layoutPriority(1)
            
            SaleWarTabItem(
                storeType: StoreType.sevenEleven,
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
    let storeType: StoreType
    var onSelectedTab: (SaleWarTab) -> Void
    var currentTab : SaleWarTab {
        get {
            if(storeType == StoreType.gs25) {
                return .gs25
            } else if(storeType == StoreType.cu) {
                return .cu
            } else if(storeType == StoreType.sevenEleven) {
                return .seven_eleven
            } else {
                return .gs25
            }
        }
    }

    var body: some View {
        Button(action: {
            print("Click \(storeType.rawValue) tab")
            onSelectedTab(currentTab)
        }) {
            Image(storeType.brandLogo) // Replace with your actual image
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
