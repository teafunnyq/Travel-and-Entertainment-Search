//
//  TableViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/16/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import EasyToast

class FavoritesTableViewController: UITableViewController {
    
    var delegate : SwitchFavView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
        if let placeID = defaults.array(forKey: "placeID") {
            if(placeID.count == 0){
                self.delegate?.updateView(noView: true)
            }else{
                self.delegate?.updateView(noView: false)
            }
        }
        
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numFavs = Int()
        let defaults = UserDefaults.standard
        if let placeID = defaults.array(forKey: "placeID") {
            numFavs = placeID.count
        }
        
        return numFavs
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoritesTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoritesTableViewCell else{
            fatalError("The dequeued cell is not an instance of FavoritesTableViewCell.")
        }
        
        let defaults = UserDefaults.standard
        
        if var names = defaults.array(forKey: "placeNames") {
            cell.placeName.text = names[indexPath.row] as! String
        }
        
        if var address = defaults.array(forKey: "placeAddresses") {
            cell.placeAddress.text = address[indexPath.row] as! String
        }
        
        if var category = defaults.array(forKey: "placeCategory") {
            var cellCategory = category[indexPath.row] as! String
            let categoryData = NSData(contentsOf:NSURL(string:cellCategory) as! URL)
            if categoryData != nil {
                cell.categoryImg.image = UIImage(data:categoryData! as Data)
            }
        }
        
        if var placeID = defaults.array(forKey: "placeID") {
            cell.placeID.text = placeID[indexPath.row] as! String
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FavoritesTableViewCell
        
        if editingStyle == .delete {
            // Delete the row from the data source
            let defaults = UserDefaults.standard
            
            var placeID = defaults.array(forKey: "placeID") as! [String]
            placeID.remove(at: indexPath.row)
            defaults.set(placeID, forKey: "placeID")
            
            var names = defaults.array(forKey: "placeNames") as! [String]
            names.remove(at: indexPath.row)
            defaults.set(names, forKey: "placeNames")
            
            var address = defaults.array(forKey: "placeAddresses") as! [String]
            address.remove(at: indexPath.row)
            defaults.set(address, forKey: "placeAddresses")
            
            var category = defaults.array(forKey: "placeCategory") as! [String]
            category.remove(at: indexPath.row)
            defaults.set(category, forKey: "placeCategory")
            
            let placeName = cell.placeName.text as! String
            self.view.showToast("\(placeName) was removed from favorites", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            tableView.deleteRows(at: [indexPath], with: .fade)

            if let placeID = defaults.array(forKey: "placeID") {
                if(placeID.count == 0){
                    self.delegate?.updateView(noView: true)
                }else{
                    self.delegate?.updateView(noView: false)
                }
            }
            
            self.tableView.reloadData()
        }   
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabViewController = segue.destination as? TabViewController {
            let selectedPlaceCell = sender as? FavoritesTableViewCell
            tabViewController.placeID = (selectedPlaceCell?.placeID.text)!
        }
    }

}
