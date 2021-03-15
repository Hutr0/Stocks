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
    var isNilStocks: Bool = false
    
    func startLoadingStocks(tableView: UITableView) {
        
        WebSocketManager.shared.connectToWebSocket()
        
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        // let sortDescriptor = NSSortDescriptor(key: "title", ascending: false) // Сортировка
        // fetchRequest.sortDescriptors = [sortDescriptor] // Присваевыем нашему запросу сортировку
        
        do {
            let fetchedStokes = try self.context.fetch(fetchRequest)
            
            isNilStocks = fetchedStokes == [] ? true : false
            
            if !isNilStocks {
                self.stocks = fetchedStokes
                getNotNilStocks(tableView: tableView)
            } else {
                getNilStocks(tableView: tableView)
            }
            
            setTimerForStocksUpdating(tableView: tableView)
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
    
    func getConfiguredCell(indexPath: IndexPath, cell: MainCell) -> MainCell {
        
        if !self.isNilStocks {
            let stock = self.stocks[indexPath.row]
            
            cell.ticker.text = stock.tiker
            cell.name.text = stock.name
            
            guard stock.isOpenCostSet else {
                
                cell.currency.text = ""
                cell.cost.text = ""
                cell.change.text = ""
                
                return cell
            }
            
            if String(stock.change).hasPrefix("-") {
                cell.change.textColor = .red
            } else {
                cell.change.textColor = .systemGreen
            }
            
            switch stock.currency {
            case "USD":
                cell.currency.text = "$"
            default:
                cell.currency.text = "?"
            }
            
            cell.cost.text = String(format: "%.2f", stock.cost)
            cell.change.text = String(format: "%.2f", stock.change) + "%"
            
            return cell
        } else {
            cell.ticker.text = ""
            cell.name.text = ""
            cell.currency.text = ""
            cell.cost.text = ""
            cell.change.text = ""
            
            return cell
        }
    }
    
    // MARK: - Load Data
    
    private func setTimerForStocksUpdating(tableView: UITableView) {
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            WebSocketManager.shared.receiveData { (dataArray) in
                
                guard let dataArray = dataArray else { return }
                
                var sequence: [IndexPath] = []
                var i = 0
                for stock in self.stocks {
                    for data in dataArray {
                        if stock.tiker == data.s {
                            if stock.isOpenCostSet == true {
                                let percent = data.p - stock.openCost
                                if stock.change != percent && stock.cost != data.p {
                                    stock.change = percent
                                    stock.cost = data.p
                                    sequence.append(IndexPath(row: i, section: 0))
                                }
                            }
                        }
                    }
                    i += 1
                }
                
                if sequence != [] {                
                    DispatchQueue.main.async {
                        tableView.reloadRows(at:sequence, with: .automatic)
                    }
                }
            }
        }
    }
    
    private func getNotNilStocks(tableView: UITableView) {
        let net = NetworkManager()
        guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: self.context) else { return }
        
        net.getStocksName { (items) in
            
            var overlap = false
            
            var i = 0
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
                    stockObject.isOpenCostSet = false
                    
                    self.stocks.append(stockObject)
                    
//                    DataManager.save(context: self.context)
                    
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                    
                    net.getStocksOpenCost(tiker: item[0], currentNumber: i) { (cost, j) in
                        
                        let stock = self.stocks[j]
                        
                        stock.openCost = cost!
                        stock.cost = cost!
                        stock.isOpenCostSet = true
                        
//                        DataManager.save(context: self.context)
                        
                        DispatchQueue.main.async {
                            tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
                        }
                    }
                }
                
                i += 1
                
                WebSocketManager.shared.subscribe(symbol: item[0])
                
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
                stockObject.isOpenCostSet = false
                
                self.stocks.append(stockObject)
                
//                DataManager.save(context: self.context)
            }
            
            self.isNilStocks = false
            
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            
            var i = 0
            for item in items {
                
                WebSocketManager.shared.subscribe(symbol: item[0])
                
                net.getStocksOpenCost(tiker: item[0], currentNumber: i) { (cost, j) in
                    
                    // Проверка на ошибку вывода информации с запроса
                    if j == -1 {
                        i -= 1
                        return
                    }
                    
                    let stock = self.stocks[j]
                    
                    stock.openCost = cost!
                    stock.cost = cost!
                    stock.isOpenCostSet = true
                    
//                    DataManager.save(context: self.context)
                    
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
                    }
                }
                i += 1
            }
        }
    }
}

extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self? {
        do {
            let newData = try decoder.decode(Self.self, from: data)
            return newData
        } catch {
            print("Decodable model error:", error.localizedDescription)
            return nil
        }
    }
    static func decodeArray(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> [Self] {
        do {
            let newData = try decoder.decode([Self].self, from: data)
            return newData
        } catch {
            print("Decodable model error:", error.localizedDescription)
            return []
        }
    }
}
