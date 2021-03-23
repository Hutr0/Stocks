//
//  NetworkManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class NetworkManager {
    
    static func getStocksName(completion: @escaping ([[String]]) -> ()) {
        
        guard let url = URL(string: "https://mboum.com/api/v1/co/collections/?list=most_actives&start=0") else { print("URL Error in getStockName()"); return }
        let headers = ["X-Mboum-Secret": "demo"]
        
        createSession(url: url, headers: headers){ (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { print("Data Error in getStockName()"); return }
            
            do {
                let collection = try Collection.decode(from: data)
                
                var quotes = [[String]]()
                
                guard collection != nil else { print("Error: Name collection == nil"); return }
                
                for quote in collection!.quotes {
                    quotes.append([quote.symbol, quote.shortName, quote.currency])
                }
                
                completion(quotes)
            } catch let error {
                print("Decoder error in getStockName(): \(error.localizedDescription)")
            }
        }
    }
    
    static func getStockOpenCost(tiker: String, currentNumber: Int, completion: @escaping ([Float], _ currentNumber: Int) -> ()) {
        
        guard let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(tiker)") else { print("URL Error in getStocksOpenCost()"); return }
        let headers = ["X-Finnhub-Token" : "c1bgv9n48v6rcdqa0kn0"]
        
        createSession(url: url, headers: headers) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                completion([], -1)
                return
            }
            
            guard let data = data else { print("Data Error in getStocksOpenCost()"); return }
            
            do {
                let cost = try StockQuote.decode(from: data)
                
                guard cost != nil else { print("Error: Cost == nil"); return }
                
                let open = cost!.o
                let current = cost!.c
                
                completion([open, current], currentNumber)
            } catch let error {
                print("Decoder error in getStocksOpenCost(): \(error.localizedDescription)")
                completion([], -1)
            }
        }
    }
    
    static func getStockCandles(tiker: String, from: Int, to: Int, completion: @escaping (StockCandles) -> ()) {
        
        guard let url = URL(string: "https://finnhub.io/api/v1/stock/candle?symbol=\(tiker)&resolution=M&from=\(from)&to=\(to)") else { print("URL Error in getStockCandles()"); return }
        let headers = ["X-Finnhub-Token" : "c1bgv9n48v6rcdqa0kn0"]
        
        createSession(url: url, headers: headers) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { print("Data Error in getStockCandles()"); return }
            
            do {
                let candles = try StockCandles.decode(from: data)
                
                guard candles != nil else { print("Error: Candles == nil"); return }
                
                completion(candles!)
            } catch let error as NSError {
                print("Decoder error in getStockCandles(): \(error.localizedDescription)")
            }
        }
    }
    
    static func getStockCompanyProfile(tiker: String, currentNumber: Int, completion: @escaping (Data?, _ currentNumber: Int) -> ()) {
        
        guard let url = URL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(tiker)") else { print("URL Error in getStockCompanyProfile()"); return }
        let headers = ["X-Finnhub-Token" : "c1bgv9n48v6rcdqa0kn0"]
        
        createSession(url: url, headers: headers) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, -1)
                return
            }
            
            guard let data = data else { print("Data Error in getStockCompanyProfile()"); return }
            
            do {
                let companyProfile = try CompanyProfileModel.decode(from: data)
                
                guard companyProfile != nil else { print("Error: Company profile == nil"); return }
                
                self.downloadLogo(stringUrl: companyProfile!.logo) { (imageData) in
                    
                    completion(imageData, currentNumber)
                }
            } catch let error {
                print("Decoder error in getStockCompanyProfile(): \(error.localizedDescription)")
                completion(nil, -1)
            }
        }
    }
    
    static private func downloadLogo(stringUrl: String, completion: @escaping (Data) -> ()) {
        
        guard let url = URL(string: stringUrl) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Logo downloading error")
                return
            }
            
            guard let imageData = data else { return }
            
            completion(imageData)
        }.resume()
    }
    
    static private func createSession(url: URL, headers: [String : String], completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            completion(data, response, error)
        }.resume()
    }
}
