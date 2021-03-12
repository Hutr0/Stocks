//
//  File.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

struct Trending: Decodable {
    
    let count: Int
    let quotes: [String]
    let jobTimestamp: Int
    let startInterval: Int
}
