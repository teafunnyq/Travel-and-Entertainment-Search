//
//  ViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/12/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReviewContainerViewController: UIViewController {
    
    var reviewArray = [JSON]()
    var yelpReviews = [JSON]()
    
    var refChildViewController: ReviewsTableViewController?
    
    @IBOutlet weak var reviewTable: UIView!
    @IBOutlet weak var noReviews: UIView!
    
    @IBOutlet weak var googleOrYelp: UISegmentedControl!
    @IBOutlet weak var sortByCategory: UISegmentedControl!
    @IBOutlet weak var orderCategory: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(reviewArray.count == 0){
            noReviews.alpha = 1
            reviewTable.alpha = 0
        }
        else{
            noReviews.alpha = 0
            reviewTable.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func switchReviews(_ sender: UISegmentedControl) {
        let mode = googleOrYelp.titleForSegment(at: googleOrYelp.selectedSegmentIndex)
        let sortedBy = sortByCategory.titleForSegment(at: sortByCategory.selectedSegmentIndex)
        let orderedBy = orderCategory.titleForSegment(at: orderCategory.selectedSegmentIndex)
        
        if((mode == "Google Reviews" && reviewArray.count == 0) || (mode == "Yelp Reviews" && yelpReviews.count == 0)){
            noReviews.alpha = 1
            reviewTable.alpha = 0
        }
        else{
            noReviews.alpha = 0
            reviewTable.alpha = 1
            refChildViewController?.sortReviews(whichKind: mode!, sortBy: sortedBy!, order: orderedBy!)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let reviewTableViewController = segue.destination as? ReviewsTableViewController {
            refChildViewController = segue.destination as? ReviewsTableViewController
            reviewTableViewController.reviewJSON = self.reviewArray
            reviewTableViewController.yelpJSON = self.yelpReviews
        }
    }

}
