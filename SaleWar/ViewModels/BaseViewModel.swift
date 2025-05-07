//
//  BaseViewModel.swift
//  SaleWar
//
//  Created by 부재식 on 5/6/25.
//

import Foundation
import Combine

protocol BaseViewModel : ObservableObject {
    var cancellableBag: Set<AnyCancellable> { get }
}

extension BaseViewModel {
//    var cancellableBag = Set<AnyCancellable>()

}
