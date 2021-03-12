//
//  File.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

struct Collection: Decodable {
    
    let start: Int
    let count: Int
    let total: Int
    let description: String
    let quotes: [Quote]
}
