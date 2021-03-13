//
//  MainManager.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 13.03.2021.
//

import UIKit
import CoreData

class MainManager {
    
    var context: NSManagedObjectContext!
    
    var stocks = [Stock]()
    
    func loadStocks(tableView: UITableView) {
        
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        // let sortDescriptor = NSSortDescriptor(key: "title", ascending: false) // Сортировка
        // fetchRequest.sortDescriptors = [sortDescriptor] // Присваевыем нашему запросу сортировку
        
        do {
            let fetchedStokes = try self.context.fetch(fetchRequest)
            
            if fetchedStokes != [] {
                getNotNilStocks(fetchedStokes: fetchedStokes, tableView: tableView)
                var i = 0
                for stock in self.stocks {
                    guard let tiker = stock.tiker else { return }
                    updateStocksCost(tableView: tableView, tiker: tiker, number: i)
                    i += 1
                }
            } else {
                getNilStocks(tableView: tableView)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func favouriteAction(_ indexPath: IndexPath) -> UIContextualAction {
        
        let stock = stocks[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            
            stock.isFavourite.toggle()
            self.stocks[indexPath.row] = stock
            
            DataManager.save(context: self.context)
            
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
    
    // MARK: - Private methods
    
    private func updateStocksCost(tableView: UITableView, tiker: String, number: Int) {
        let net = NetworkManager()
        
        net.getStocksOpenCost(tiker: tiker, number: number) { (cost, j) in
            
            let stock = self.stocks[j]
            
            stock.cost = cost[0]
            stock.change = cost[1]
            stock.isCostSet = true
            
            DataManager.save(context: self.context)
            
            DispatchQueue.main.async {
                tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
            }
        }
    }
    
    private func getNotNilStocks(fetchedStokes: [Stock], tableView: UITableView) {
        let net = NetworkManager()
        guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: self.context) else { return }
        
        self.stocks = fetchedStokes
        
        net.getStocksName { (items) in
            
            var overlap = false
            
            for item in items {
                for stock in self.stocks {
                    if item[0] == stock.tiker {
                        overlap = true
                        break
                    }
                }
                
                if overlap == false {
                    
                    let stockObject = Stock(entity: entity, insertInto: self.context)
                    
                    stockObject.tiker = item[0]
                    stockObject.name = item[1]
                    stockObject.currency = item[2]
                    stockObject.isCostSet = false
                    
                    DataManager.save(context: self.context) {
                        self.stocks.append(stockObject)
                    }
                    
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                    
                    net.getStocksOpenCost(tiker: item[0], number: 0) { (cost, j) in
                        
                        let stock = self.stocks[j]
                        
                        stock.cost = cost[0]
                        stock.change = cost[1]
                        stock.isCostSet = true
                        
                        DataManager.save(context: self.context)
                        
                        DispatchQueue.main.async {
                            tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
                        }
                    }
                }
                overlap = false
            }
        }
    }
    
    private func getNilStocks(tableView: UITableView) {
        let net = NetworkManager()
        guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: self.context) else { return }
        
        net.getStocksName { (items) in
            for item in items {
                let stockObject = Stock(entity: entity, insertInto: self.context)
                
                stockObject.tiker = item[0]
                stockObject.name = item[1]
                stockObject.currency = item[2]
                stockObject.isCostSet = false
                
                DataManager.save(context: self.context) {
                    self.stocks.append(stockObject)
                }
            }
            
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            
            var i = -1
            
            for item in items {
                net.getStocksOpenCost(tiker: item[0], number: i) { (cost, j) in
                    
                    let stock = self.stocks[j]
                    
                    stock.cost = cost[0]
                    stock.change = cost[1]
                    stock.isCostSet = true
                    
                    DataManager.save(context: self.context)
                    
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
                    }
                }
                i += 1
            }
        }
    }
}
