//
//  WebSocketModel.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 15.03.2021.
//

import Foundation

struct WebSocketModel: Decodable {
    
    let data: [WebSocket]
    let type: String
}

struct WebSocket: Decodable {
    
    let s: String   // Symbol
    let p: Float    // Last price
    let t: Int      // UNIX milliseconds timestamp
    let v: Int      // Volume
    let c: [String] // List of trade conditions
}
