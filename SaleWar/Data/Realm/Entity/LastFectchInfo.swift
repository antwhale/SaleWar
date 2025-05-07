//
//  LastFectchInfo.swift
//  SaleWar
//
//  Created by 부재식 on 5/6/25.
//

import Foundation
import RealmSwift

class LastFectchInfo: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var date: String
}


