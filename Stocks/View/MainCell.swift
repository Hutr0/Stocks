//
//  MainCell.swift
//  Stocks
//
//  Created by Леонид Лукашевич on 12.03.2021.
//

import UIKit

class MainCell: UITableViewCell {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var ticker: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
