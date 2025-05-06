//
//  SaleWarApp.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import SwiftUI

@main
struct SaleWarApp: App {
    var body: some Scene {
        WindowGroup {
            let appViewModel = AppViewModel()
            ContentView(appViewModel: appViewModel)
        }
    }
}
