//
//  ViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/16/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit

protocol SwitchFavView{
    func updateView(noView: Bool)
}

class SearchContainerViewController: UIViewController, SwitchFavView {

    @IBOutlet weak var searchOrFav: UISegmentedControl!
    @IBOutlet weak var searchForm: UIView!
    @IBOutlet weak var noFavs: UIView!
    @IBOutlet weak var favTable: UIView!
    
    var refChildViewController: FavoritesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var anyFavs = false
        let mode = searchOrFav.titleForSegment(at: searchOrFav.selectedSegmentIndex)
        let defaults = UserDefaults.standard
        if let placeID = defaults.array(forKey: "placeID") {
            if placeID.count > 0 {
                anyFavs = true
            }
        }
        
        if mode == "FAVORITES" {
            searchForm.alpha = 0
            if anyFavs{
                favTable.alpha = 1
                noFavs.alpha = 0
            }else{
                favTable.alpha = 0
                noFavs.alpha = 1
            }
        }else{
            favTable.alpha = 0
            noFavs.alpha = 0
            searchForm.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        var anyFavs = false
        let mode = searchOrFav.titleForSegment(at: searchOrFav.selectedSegmentIndex)
        let defaults = UserDefaults.standard
        if let placeID = defaults.array(forKey: "placeID") {
            if placeID.count > 0 {
                anyFavs = true
            }
        }
        
        if mode == "FAVORITES"{
            searchForm.alpha = 0
            if anyFavs{
                favTable.alpha = 1
                noFavs.alpha = 0
            }else{
                favTable.alpha = 0
                noFavs.alpha = 1
            }
        }else{
            favTable.alpha = 0
            noFavs.alpha = 0
            searchForm.alpha = 1
        }
    }
    
    func updateView(noView: Bool){
        let mode = searchOrFav.titleForSegment(at: searchOrFav.selectedSegmentIndex)
        
        if(mode == "SEARCH"){
            favTable.alpha = 0
            noFavs.alpha = 0
            searchForm.alpha = 1
            return
        }
        
        searchForm.alpha = 0
        if(noView){
            favTable.alpha = 0
            noFavs.alpha = 1
        }else{
            favTable.alpha = 1
            noFavs.alpha = 0
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let favoritesTableViewController = segue.destination as? FavoritesTableViewController {
            refChildViewController = segue.destination as? FavoritesTableViewController
            refChildViewController?.delegate = self
        }
    }
}
