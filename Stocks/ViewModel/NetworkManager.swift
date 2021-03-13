//
//  NetworkManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class NetworkManager {
    
    func getStocksName(completion: @escaping ([[String]]) -> ()) {
        
        guard let url = URL(string: "https://mboum.com/api/v1/co/collections/?list=most_actives&start=0") else { return }
        
        let headers = [
            "X-Mboum-Secret": "demo"
        ]
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(Collection.self, from: data)
                
                var names = [[String]]()
                
                for quote in collection.quotes {
                    names.append([quote.symbol, quote.shortName])
                }
                
                completion(names)
            } catch let error {
                print("Decoder error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func getStocksOpenCost(tiker: String, number: Int, completion: @escaping ([Float], _ number: Int) -> ()) {
        
        
        guard let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(tiker)") else { return }
        
        let headers = [
            "X-Finnhub-Token" : "c14c7ff48v6t8t43brk0"
        ]
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let cost = try decoder.decode(StockQuote.self, from: data)
                
                let current = cost.c
                let open = cost.o
                
                let percent = (current - open) - 1
                
                completion([current, percent], number)
            } catch let error {
                print("Decoder error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
