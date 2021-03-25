//
//  DetailViewController.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 19.03.2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    let manager = DetailManager()
    
    @IBOutlet weak var stockName: UILabel!
    @IBOutlet weak var stockLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.configureData { [weak self] (model) in
            
            guard let self = self else { return }
            
            self.stockName.text = model.name
            self.stockLogo.image = model.logo
        }
    }
}
