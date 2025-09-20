//
//  Item.swift
//  Moch
//
//  Created by Ruben Gago(personal) on 20/9/25.
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
