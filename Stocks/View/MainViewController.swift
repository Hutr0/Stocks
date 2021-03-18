//
//  MainViewController.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    let manager = MainManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showFavouriteButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = false
        
        manager.startLoadingStocks(tableView: tableView)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.stocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainCell
    
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        cell = manager.getConfiguredCell(indexPath: indexPath, cell: cell)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
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
                manager.stashStocks = nil
                showFavouriteButton.image = UIImage(systemName: "heart")
            }
        }
        
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.text != ""  {
            let filteredStocks = manager.stocks.filter { (stock) -> Bool in

                guard let text = searchController.searchBar.text,
                      let tiker = stock.tiker,
                      let name = stock.name else { return false }

                if tiker.contains(text) || name.contains(text) {
                    return true
                }

                return false
            }
            
            manager.stocks = filteredStocks
        } else {
            if let stash = manager.stashStocks {
                manager.stocks = stash
                manager.stashStocks = nil
            } else {
                manager.stashStocks = manager.stocks
            }
        }
        
        tableView.reloadData()
    }
}
