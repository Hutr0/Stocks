//
//  MainViewController.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class MainViewController: UITableViewController {
    
    var stocks = [MainCellModel]()

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainCell
        
        let stock = stocks[indexPath.row]
        
        cell.ticker.text = stock.tiker
        cell.name.text = stock.name
        
        guard let cost = stock.cost, let change = stock.change else {
            
            cell.currency.text = ""
            cell.cost.text = ""
            cell.change.text = ""
            
            return cell
        }
        
        if String(change).hasPrefix("-") {
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
        
        cell.cost.text = "\(cost)%"
        cell.change.text = "\(change)%"

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
