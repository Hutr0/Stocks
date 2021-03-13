//
//  MainManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 13.03.2021.
//

import UIKit
import CoreData

class MainManager {
    
    var context: NSManagedObjectContext?
    
    var stocks = [MainModel]()
    
    func favouriteAction(_ indexPath: IndexPath) -> UIContextualAction {
        
        var stock = stocks[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            
            stock.isFavourite.toggle()
            
            self.stocks[indexPath.row] = stock
            completion(true)
        }
    
        if stock.isFavourite {
            action.backgroundColor = .red
            action.image = UIImage(systemName: "heart.fill")
        } else {
            action.backgroundColor = .systemGray2
            action.image = UIImage(systemName: "heart")
        }
        
        return action
    }
}
