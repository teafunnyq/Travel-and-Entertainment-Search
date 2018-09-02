//
//  ViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/9/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import SwiftSpinner

protocol UpdateButtons {
    func updateButton(prevInfo : Bool, nextInfo:Bool)
    func whichView(error : Bool)
}

class ContainerViewController: UIViewController, UpdateButtons {
    
    var keyword = String();
    var category = String();
    var distance = String();
    var location = String();
    var inputLocation = String();
    
    var refChildViewController: SearchResultsTableViewController?
    
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Search Results"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchResultsTableViewController = segue.destination as? SearchResultsTableViewController {
            refChildViewController = segue.destination as? SearchResultsTableViewController
            refChildViewController?.delegate = self
            searchResultsTableViewController.keyword = keyword
            searchResultsTableViewController.category = category
            searchResultsTableViewController.distance = distance
            searchResultsTableViewController.location = location
            searchResultsTableViewController.inputLocation = inputLocation
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    @IBAction func getNextPage(_ sender: UIButton) {
        refChildViewController?.nextSearchPage()
    }
    
    @IBAction func getPrevPage(_ sender: UIButton) {
        refChildViewController?.prevSearchPage()
    }
    
    func updateButton(prevInfo : Bool, nextInfo:Bool){
        if(prevInfo){
            prevButton.isEnabled = true
        }
        else{
            prevButton.isEnabled = false
        }
        
        if(nextInfo){
            nextButton.isEnabled = true
        }
        else{
            nextButton.isEnabled = false
        }
    }
    
    func whichView(error : Bool){
        if(error){
            self.errorView.alpha = 1
            self.tableView.alpha = 0
        }else{
            self.errorView.alpha = 0
            self.tableView.alpha = 1
        }
    }
}
