//
//  BaseView.swift
//  SaleWar
//
//  Created by 부재식 on 5/5/25.
//

import Foundation
import SwiftUI

protocol BaseView : View {
    var onSelectedTab: (SaleWarTab) -> Void { get set }
}
