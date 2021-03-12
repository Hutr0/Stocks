//
//  MainViewController.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class MainViewController: UITableViewController {
    
    let mainManager = MainManager()
    
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
        cell.cost.text = String(stock.cost ?? -1)
        cell.change.text = String(stock.change ?? -1)

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
