//
//  MainCellModel.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import Foundation

struct MainModel {
    
    let tiker: String
    let name: String
    var currency: String?
    var cost: Float?
    var change: Float?
    var isFavourite: Bool = false
}
