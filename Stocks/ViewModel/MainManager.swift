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
    
    var stocks: [Stock]!
    var stashForFavouriteStocks: [Stock]?
    var stashForSearchStocks: [Stock]?
    var isNilStocks: Bool = false
    var isFavourite = false
    var isSearch = false
    
    func startLoadingStocks(tableView: UITableView) {
        
        WebSocketManager.shared.connectToWebSocket()
        
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        
        do {
            let fetchedStokes = try self.context.fetch(fetchRequest)
            
            isNilStocks = fetchedStokes == [] ? true : false
            
            if !isNilStocks {
                self.stocks = fetchedStokes
                getNotNilStocks(tableView: tableView)
            } else {
                self.stocks = [Stock]()
                getNilStocks(tableView: tableView)
            }
            
            loadStocksLogo(tableView: tableView)
            setTimerForStocksUpdating(tableView: tableView)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Favourite
    
    func favouriteAction(_ tableView: UITableView, _ indexPath: IndexPath, isFavourite: Bool) -> UIContextualAction {
        
        let stock = stocks[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            
            stock.isFavourite.toggle()
            self.stocks[indexPath.row] = stock
            
            CoreDataManager.save(context: self.context)
            
            if isFavourite {
                if self.isSearch {
                    let tiker = stock.tiker
                    var i = 0
                    for stock in self.stashForSearchStocks! {
                        if tiker == stock.tiker {
                            self.stashForSearchStocks!.remove(at: i)
                        }
                        i += 1
                    }
                }
                self.stocks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
            }
            
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
    
    func showFavouite(completion: @escaping (UIImage?) -> ()) {
        isFavourite.toggle()
        
        var image: UIImage?
        if isFavourite {
            var favouriteStocks = [Stock]()
            for stock in stocks {
                if stock.isFavourite {
                    favouriteStocks.append(stock)
                }
            }
            stashForFavouriteStocks = stocks
            stocks = favouriteStocks
            image = UIImage(systemName: "heart.fill")
        } else {
            if let stash = stashForFavouriteStocks {
                stocks = stash
                stashForFavouriteStocks = nil
                image = UIImage(systemName: "heart")
            }
        }
        
        completion(image)
    }
    
    //MARK: - Search
    
    func updateSearchResults(_ searchController: UISearchController) {
        guard let text = searchController.searchBar.text, let stash = stashForSearchStocks else { return }
        
        if text != "" {
            isSearch = true
            
            let filteredStocks = stash.filter { (stock) -> Bool in
                guard let tiker = stock.tiker, let name = stock.name else { print("Error: stock tiker or name not found"); return false }
                
                if tiker.lowercased().contains(text.lowercased()) || name.lowercased().contains(text.lowercased()) {
                    return true
                }
                
                return false
            }
            
            stocks = filteredStocks
        } else {
            isSearch = false
            stocks = stash
        }
    }
    
    func searchBarTextDidEndEditing(completion: @escaping () -> ()) {
        if !isSearch {
            guard let stash = stashForSearchStocks else { print("Error: stash was not found"); return }
            
            stocks = stash
            stashForSearchStocks = nil
            
            completion()
        }
    }
    
    //MARK: - Configuring a cell
    
    func getConfiguredCell(indexPath: IndexPath, cell: MainCell) -> MainCell {
        
        if !self.isNilStocks {
            let stock = self.stocks[indexPath.row]
            
            cell.ticker.text = stock.tiker
            cell.name.text = stock.name
            
            if stock.logo != nil {
                let logo = UIImage(data: stock.logo!)
                cell.logo.image = logo
                cell.logo.layer.cornerRadius = 8
            } else {
                cell.logo.image = UIImage(systemName: "exclamationmark.arrow.triangle.2.circlepath")
            }
            
            guard stock.isOpenCostSet else {
                
                cell.currency.text = ""
                cell.cost.text = ""
                cell.change.text = ""
                
                return cell
            }
            
            cell.activityIndicator.stopAnimating()
            
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
            
            if String(format: "%.2f", stock.cost).hasSuffix("0") {
                if String(format: "%.1f", stock.cost).hasSuffix("0") {
                    cell.cost.text = String(format: "%.0f", stock.cost)
                } else {
                    cell.cost.text = String(format: "%.1f", stock.cost)
                }
            } else {
                cell.cost.text = String(format: "%.2f", stock.cost)
            }
            
            if String(format: "%.2f", stock.change).hasSuffix("0") {
                if String(format: "%.1f", stock.change).hasSuffix("0") {
                    cell.change.text = String(format: "%.0f", stock.change) + "%"
                } else {
                    cell.change.text = String(format: "%.1f", stock.change) + "%"
                }
            } else {
                cell.change.text = String(format: "%.2f", stock.change) + "%"
            }
            
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
    
    //MARK: - Loading stocks logo
    // Изображения грузятся так долго из-за ограничения бесплатной версии finhub :(
    
    private func loadStocksLogo(tableView: UITableView) {
        var i = 0
        var isAllOpenCostSet = true
        
        for stock in stocks {
            if stock.isOpenCostSet == false {
                isAllOpenCostSet = false
            }
        }
        
        if isAllOpenCostSet == true {
            for stock in stocks {
                guard stock.logo == nil else { continue }
                
                NetworkManager.getStockCompanyProfile(tiker: stock.tiker!, currentNumber: i) { [weak self] (imageData, j) in
                    
                    // Проверка на ошибку вывода информации с запроса
                    if j == -1 {
                        i -= 1
                        return
                    }
                    
                    stock.logo = imageData
                    
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [IndexPath(row: j, section: 0)], with: .automatic)
                    }
                    
                    CoreDataManager.save(context: self!.context)
                }
                i += 1
            }
        }
    }
    
    //MARK: - Timer
    
    private func setTimerForStocksUpdating(tableView: UITableView) {
        
        var tikers: [String] = []
        var dataForUpdate: [WebSocket] = []
        var isAllLogoLoaded = true
        
        for stock in stocks {
            guard let tiker = stock.tiker else { print("Error: tiker not found"); return }
            tikers.append(tiker)
        }
        
        // Timer для WebSocket
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            WebSocketManager.shared.receiveData { (dataArray) in
                guard let dataArray = dataArray else { return }
                
                var isContained = false
                
                for data in dataArray {
                    for tiker in tikers {
                        if data.s == tiker {
                            for u in dataForUpdate {
                                if data.s == u.s {
                                    isContained = true
                                }
                            }
                        }
                    }
                    
                    if !isContained {
                        dataForUpdate.append(data)
                    }
                }
            }
        }
        
        // Timer для подгрузки данных
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            
            var sequence = [IndexPath]()
            
            var i = 0
            for stock in self.stocks {
                for data in dataForUpdate {
                    if stock.tiker == data.s {
                        if stock.isOpenCostSet == true {
                            if String(format: "%.2f", stock.cost) != String(format: "%.2f", data.p) {
                                let percent = data.p - stock.openCost
                                stock.change = percent
                                stock.cost = data.p
                                sequence.append(IndexPath(row: i, section: 0))
                            }
                        }
                    }
                }
                
                if stock.isOpenCostSet == false {
                    guard let tiker = stock.tiker else { print("Error: tiker = nil"); return }
                    
                    NetworkManager.getStockOpenCost(tiker: tiker, currentNumber: i) { (cost, j) in
                        
                        // Проверка на ошибку вывода информации с запроса
                        if j == -1 {
                            i -= 1
                            return
                        }
                        
                        self.setStockCost(stock: stock, open: cost[0], current: cost[1])
                        
                        sequence.append(IndexPath(item: j, section: 0))
                    }
                }
                
                if stock.logo == nil {
                    isAllLogoLoaded = false
                }
                
                i += 1
            }
            
            if !isAllLogoLoaded {
                self.loadStocksLogo(tableView: tableView)
                isAllLogoLoaded = true
            }
            
            if sequence != [] {
                DispatchQueue.main.async {
                    tableView.reloadRows(at:sequence, with: .automatic)
                }
            }
            
            dataForUpdate = []
        }
    }
    
    //MARK: - Loading data
    
    private func getNotNilStocks(tableView: UITableView) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: self.context) else { return }
        
        NetworkManager.getStocksName { (items) in
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
                    self.setStockName(entity: entity, tiker: item[0], name: item[1], currency: item[2])
                    
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                
                WebSocketManager.shared.subscribe(symbol: item[0])
                
                overlap = false
                i += 1
            }
        }
        
        var i = 0
        for stock in stocks {
            guard let tiker = stock.tiker else { print("Error: tiker = nil"); return }
            
            NetworkManager.getStockOpenCost(tiker: tiker, currentNumber: i) { (cost, j) in
                
                // Проверка на ошибку вывода информации с запроса
                if j == -1 {
                    stock.isOpenCostSet = false
                    i -= 1
                    return
                }
                
                self.setStockCost(stock: stock, open: cost[0], current: cost[1])
                
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
                }
            }
            i += 1
        }
        
        CoreDataManager.save(context: self.context)
    }
    
    private func getNilStocks(tableView: UITableView) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: self.context) else { return }
        
        NetworkManager.getStocksName { (items) in
            for item in items {
                self.setStockName(entity: entity, tiker: item[0], name: item[1], currency: item[2])
            }
            
            self.isNilStocks = false
            
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            
            var i = 0
            for item in items {
                
                WebSocketManager.shared.subscribe(symbol: item[0])
                
                NetworkManager.getStockOpenCost(tiker: item[0], currentNumber: i) { (cost, j) in
                    
                    // Проверка на ошибку вывода информации с запроса
                    if j == -1 {
                        i -= 1
                        return
                    }
                    
                    let stock = self.stocks[j]
                    
                    self.setStockCost(stock: stock, open: cost[0], current: cost[1])
                    
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [IndexPath(item: j, section: 0)], with: .automatic)
                    }
                }
                i += 1
            }
        }
        
        CoreDataManager.save(context: self.context)
    }
    
    private func setStockName(entity: NSEntityDescription, tiker: String, name: String, currency: String) {
        let stockObject = Stock(entity: entity, insertInto: self.context)
        
        stockObject.tiker = tiker
        stockObject.name = name
        stockObject.currency = currency
        stockObject.isOpenCostSet = false
        
        self.stocks.append(stockObject)
    }
    
    private func setStockCost(stock: Stock, open: Float, current: Float) {
        let open = open
        let current = current
        let percent = current - open
        
        stock.openCost = open
        stock.cost = current
        stock.change = percent
        stock.isOpenCostSet = true
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
