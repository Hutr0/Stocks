//
//  CompanyProfile.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

struct CompanyProfile: Decodable {
    
    let country: String?
    let currency: String?
    let exchange: String?
    let ipo: String?
    let marketCapitalization: Float?
    let name: String?
    let phone: String?
    let shareOutstanding: Float?
    let ticker: String?
    let weburl: String?
    let logo: String?
    let finnhubIndustry: String?
}
