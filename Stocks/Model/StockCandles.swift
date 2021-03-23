//
//  StockCandles.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 23.03.2021.
//

import Foundation

struct StockCandles: Decodable {
    
    let c: [Float]   // List of close prices
    let h: [Float]   // List of high prices
    let l: [Float]   // List of low prices
    let o: [Float]   // List of open prices
    let s: String    // Status of the response. This field can either be "ok" or "no_data"
    let t: [Int]     // List of timestamp
    let v: [Int]     // List of volume data
}
