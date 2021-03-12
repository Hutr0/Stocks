//
//  NetworkManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class NetworkManager {
    
    func getMostWachedStocks(completion: @escaping ([String]) -> ()) {
        
        guard let url = URL(string: "https://mboum.com/api/v1/tr/trending") else { return }
        
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
                let trending = try decoder.decode([Trending].self, from: data)
                
                completion(trending.first!.quotes)
            } catch let error {
                print("Decoder error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func getNames(quote: String, completion: @escaping (String) -> ()) {
        
        guard let url = URL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(quote)") else { return }
        
        let headers = [
            "X-Finnhub-Token": "c14c7ff48v6t8t43brk0"
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
                let profile = try decoder.decode(CompanyProfile.self, from: data)
                
                guard let name = profile.name else { return }
                
                completion(name)
            } catch let error {
                print("Decoder error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
