//
//  MainViewController.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    let manager = MainManager()
    
    @IBOutlet weak var showFavouriteButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        manager.startLoadingStocks(tableView: tableView)
        
//        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
//        do {
//            manager.stocks = try manager.context.fetch(fetchRequest)
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
        
//        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
//
//        do {
//            let object = try manager.context.fetch(fetchRequest)
//            for o in object {
//
//                manager.context.delete(o)
//            }
//            try manager.context.save()
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.stocks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainCell
    
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        cell = manager.getConfiguredCell(indexPath: indexPath, cell: cell)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favourite = manager.favouriteAction(tableView, indexPath, isFavourite: manager.isFavourite)
        
        return UISwipeActionsConfiguration(actions: [favourite])
    }
    
    @IBAction func showFavouriteStocks(_ sender: UIBarButtonItem) {
        
        manager.isFavourite.toggle()
        
        if manager.isFavourite {
            var favouriteStocks = [Stock]()
            for stock in manager.stocks {
                if stock.isFavourite {
                    favouriteStocks.append(stock)
                }
            }
            manager.stashStocks = manager.stocks
            manager.stocks = favouriteStocks
            showFavouriteButton.image = UIImage(systemName: "heart.fill")
        } else {
            if let stash = manager.stashStocks {
                manager.stocks = stash
                showFavouriteButton.image = UIImage(systemName: "heart")
            }
        }
        
        tableView.reloadData()
    }
}
