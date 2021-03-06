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
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        if NetworkManager.isConnectedToNetwork() {
            manager.startLoadingStocks(tableView: tableView)
        } else {
            let alert = UIAlertController(title: "Network connection error", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favourite = manager.favouriteAction(tableView, indexPath, isFavourite: manager.isFavourite)
        
        return UISwipeActionsConfiguration(actions: [favourite])
    }
    
    @IBAction func showFavourite(_ sender: UIBarButtonItem) {
        
        manager.showFavouite() { [weak self] (image) in
            guard let self = self, let image = image else { return }

            self.showFavouriteButton.image = image
            self.tableView.reloadData()
        }
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        manager.updateSearchResults(searchController)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        manager.isSearch = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !manager.isSearch {
            manager.stashForSearchStocks = manager.stocks
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        manager.searchBarTextDidEndEditing { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}
