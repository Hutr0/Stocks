//
//  DetailManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 23.03.2021.
//

import Foundation

class DetailManager {
    
    var stock: Stock!
    
    func getStockCandlesForTheYear() {
        
        guard let stock = stock, let tiker = stock.tiker else { print("Error: Stock == nil"); return }
        
        let currentDate = Date()
        let oneYearAgo = currentDate - 60*60*24*365
        
        NetworkManager.getStockCandles(tiker: tiker, from: Int(oneYearAgo.timeIntervalSince1970), to: Int(currentDate.timeIntervalSince1970)) { (candles) in
            print(candles)
        }
    }
}
