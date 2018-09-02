//
//  TableViewCell.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/16/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
    @IBOutlet weak var placeID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
