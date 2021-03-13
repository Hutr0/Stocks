//
//  DataManger.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 14.03.2021.
//

import UIKit
import CoreData

class DataManager {
    
    static func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func save(context: NSManagedObjectContext, withCompletion completion: () -> ()) {
        do {
            try context.save()
            completion()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
