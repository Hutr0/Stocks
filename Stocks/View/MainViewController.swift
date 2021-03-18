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
    var isSearchButtonClicked = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showFavouriteButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
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
            manager.stashForFavouriteStocks = manager.stocks
            manager.stocks = favouriteStocks
            showFavouriteButton.image = UIImage(systemName: "heart.fill")
        } else {
            if let stash = manager.stashForFavouriteStocks {
                manager.stocks = stash
                manager.stashForFavouriteStocks = nil
                showFavouriteButton.image = UIImage(systemName: "heart")
            }
        }
        
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, let stash = manager.stashForSearchStocks else { return }
        
        if text != "" {
            let filteredStocks = stash.filter { (stock) -> Bool in
                guard let tiker = stock.tiker, let name = stock.name else { print("Error: stock tiker or name not found"); return false }
                
                if tiker.lowercased().contains(text.lowercased()) || name.lowercased().contains(text.lowercased()) {
                    return true
                }
                
                return false
            }
            
            manager.stocks = filteredStocks
        } else {
            manager.stocks = stash
        }

        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearchButtonClicked = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchButtonClicked = false
//        manager.isSearchBarActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !isSearchButtonClicked {
            manager.stashForSearchStocks = manager.stocks
        }
//        manager.isSearchBarActive = true
        isSearchButtonClicked = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !isSearchButtonClicked {
            guard let stash = manager.stashForSearchStocks else { print("Error: stash was not found"); return }
            
            manager.stocks = stash
            manager.stashForSearchStocks = nil
//            manager.isSearchçBarActive = false
            
            tableView.reloadData()
        }
    }
}
