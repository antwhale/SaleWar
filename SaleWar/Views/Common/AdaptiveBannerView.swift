//
//  AdaptiveBannerView.swift
//  SaleWar
//
//  Created by 부재식 on 4/19/26.
//

import SwiftUI
import GoogleMobileAds

struct AdaptiveBannerView: UIViewControllerRepresentable {
    let adUnitID: String

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = BannerView()

        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        bannerView.delegate = context.coordinator
        
        // 1. 오토레이아웃을 쓰기 위해 false 설정
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bannerView)
        
        // 2. 제약 조건 추가: 부모 뷰의 가로 중앙에 맞춤
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let bannerView = uiViewController.view.subviews.first as? BannerView else { return }
        
        // 1. 현재 화면의 너비를 측정 (Safe Area 제외)
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let windowWidth = uiViewController.view.frame.inset(by: uiViewController.view.safeAreaInsets).width 
        
        if windowWidth > 0 {
            // 2. 적응형 사이즈 요청
            bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: windowWidth)
            bannerView.load(Request())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("광고 로드 성공")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("광고 로드 실패: \(error.localizedDescription)")
        }
    }
}
