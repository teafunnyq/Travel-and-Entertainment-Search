//
//  FirstViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/7/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import Cosmos

class InfoViewController: UIViewController {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UITextView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var googlePage: UITextView!
    
    @IBOutlet weak var noRating: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

