//
//  DetailViewController.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 19.03.2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    let manager = DetailManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = manager.stock.tiker
        
        manager.getStockCandlesForTheYear()
    }
    
    // Stock Candles
}
