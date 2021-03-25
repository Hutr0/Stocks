//
//  LogoModel.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 20.03.2021.
//

import UIKit

struct CompanyProfileModelFromNetwork: Decodable {
    
    let country: String
    let exchange: String
    let ipo: String
    let marketCapitalization: Float
    let phone: String
    let shareOutstanding: Float
    let weburl: String
    let finnhubIndustry: String
    let logo: String
}

struct CompanyProfileModel {
    
    let country: String
    let exchange: String
    let ipo: String
    let marketCapitalization: Float
    let phone: String
    let shareOutstanding: Float
    let weburl: String
    let finnhubIndustry: String
    let logo: Data
}
