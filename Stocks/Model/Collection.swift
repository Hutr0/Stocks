//
//  File.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

struct Collection: Decodable {
    
    let quotes: [CollectionQuote]
}

struct CollectionQuote: Decodable {
    
    let currency: String
    let shortName: String
    let symbol: String
}
