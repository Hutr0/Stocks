//
//  NetworkManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class NetworkManager {
    
    func getStocksName(completion: @escaping ([[String]]) -> ()) {
        
        guard let url = URL(string: "https://mboum.com/api/v1/co/collections/?list=most_actives&start=0") else { print("URL Error in getStockName()"); return }
        
        let headers = [
            "X-Mboum-Secret": "demo"
        ]
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { print("Data Error in getStockName()"); return }
            
            do {
                let collection = try Collection.decode(from: data)
                
                var quotes = [[String]]()
                
                for quote in collection!.quotes {
                    quotes.append([quote.symbol, quote.shortName, quote.currency])
                }
                
                completion(quotes)
            } catch let error {
                print("Decoder error in getStockName(): \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func getStocksOpenCost(tiker: String, currentNumber: Int, completion: @escaping ([Float?], _ currentNumber: Int) -> ()) {
        
        guard let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(tiker)") else { print("URL Error in getStocksOpenCost()"); return }
        
        let headers = [
            "X-Finnhub-Token" : "c16k5t748v6ppg7etbig"
        ]
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                completion([nil], -1)
                return
            }
            
            guard let data = data else { print("URL Error in getStocksOpenCost()"); return }
            
            do {
                let decoder = JSONDecoder()
                let cost = try decoder.decode(StockQuote.self, from: data)
                
                let open = cost.o
                let current = cost.c
                
                completion([open, current], currentNumber)
            } catch let error {
                print("Decoder error in getStocksOpenCost(): \(error.localizedDescription)")
            }
        }.resume()
    }
}
