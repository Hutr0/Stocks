//
//  DataManger.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 14.03.2021.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
