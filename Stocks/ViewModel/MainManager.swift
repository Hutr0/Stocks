//
//  MainManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

class MainManager {
    
    let networkManager = NetworkManager()
    
    func loadStockNames(completion: @escaping ([[String]]) -> ()) {
        
        networkManager.getMostWachedStocks() { (returnedQuotes) in
            completion(returnedQuotes)
        }
    }
    
//    func getName(quote: String, completion: @escaping (String) -> ()) {
//
//        networkManager.getNames(quote: quote) { (name) in
//            completion(name)
//        }
//    }
}
