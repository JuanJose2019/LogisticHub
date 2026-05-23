//
//  Item.swift
//  LogisticHub
//
//  Created by Juan on 22/5/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
