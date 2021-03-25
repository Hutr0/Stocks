//
//  DetailManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 25.03.2021.
//

import UIKit

class DetailManager {
    
    var stock: Stock!
    
    func configureDetail(completion: @escaping (DetailModel) -> ()) {
        
        guard let name = stock.name else { return }
        let industry = stock.industry
        var logo: UIImage!
        
        if stock.logo != nil {
            logo = UIImage(data: stock.logo!)
            if logo == nil {
                logo = UIImage(systemName: "exclamationmark.arrow.triangle.2.circlepath")
            }
        } else {
            logo = UIImage(systemName: "exclamationmark.arrow.triangle.2.circlepath")
        }
        
        let model = DetailModel(logo: logo, name: name, industry: industry ?? "unknown")
        
        completion(model)
    }
}
