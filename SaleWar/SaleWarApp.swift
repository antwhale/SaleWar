//
//  SaleWarApp.swift
//  SaleWar
//
//  Created by 부재식 on 5/4/25.
//

import SwiftUI
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // SDK 초기화
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}

@main
struct SaleWarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            let appViewModel = AppViewModel()
            ContentView(appViewModel: appViewModel)
        }
    }
}
