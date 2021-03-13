//
//  History.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

struct StockQuote: Decodable {
    
    let c: Float        // current
    let h: Float        // high
    let l: Float        // low
    let o: Float        // open
    let pc: Float       // previous close
    let t: Int          // time
}
