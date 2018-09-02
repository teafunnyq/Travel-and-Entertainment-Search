//
//  TableViewCell.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/12/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import Cosmos

class ReviewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorImg: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var reviewText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
