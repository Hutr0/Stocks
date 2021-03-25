//
//  DetailManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 25.03.2021.
//

import UIKit

class DetailManager {
    
    var stock: Stock!
    
    func configureData(completion: @escaping (DetailModel) -> ()) {
        
        guard let name = stock.name else { return }
        let logo: UIImage!
        
        if stock.logo != nil {
            logo = UIImage(data: stock.logo!)
        } else {
            logo = UIImage(systemName: "exclamationmark.arrow.triangle.2.circlepath")
        }
        
        let model = DetailModel(name: name, logo: logo)
        
        completion(model)
    }
}
