//
//  SearchResultsViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/8/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON
import EasyToast

class SearchResultsTableViewController: UITableViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    struct Place {
        let name : String
        let address: String
        let categoryURL : NSURL
        let placeID : String
    }
    
    var keyword = String();
    var category = String();
    var distance = String();
    var location = String();
    var inputLocation = String();
    var places = [Place]();
    var tokens = [String]();
    var tablePlaces = [[Place]]();
    var currentPage = 1;
    var delegate : UpdateButtons?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Searching...")
        
        var searchQuery = "key=\(keyword)&category=\(category)&distance=\(distance)&location=\(location)&inputLocation=\(inputLocation)"
        searchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = "http://entertainmentsearch-env.us-east-2.elasticbeanstalk.com/index.php?\(searchQuery)"
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                
                let placeArray = json!["results"].arrayValue;
                
                if(placeArray.count == 0){
                    self.delegate?.whichView(error: true)
                }
                
                for aPlace in placeArray {
                    let name = aPlace["name"].stringValue
                    let categoryURL = aPlace["icon"].stringValue
                    let address = aPlace["vicinity"].stringValue
                    let placeID = aPlace["place_id"].stringValue
                    
                    let place = Place(name: name, address:address, categoryURL: NSURL(string:categoryURL)!,placeID:placeID)
                    self.places.append(place)
                }
                
                if (json!["next_page_token"].exists()){
                    self.tokens.append(json!["next_page_token"].stringValue)
                    self.delegate?.updateButton(prevInfo: false,nextInfo: true)
                }
                else{
                    self.delegate?.updateButton(prevInfo: false,nextInfo: false)
                }
                
                self.tablePlaces.append(self.places);
                
                self.tableView.reloadData()
                SwiftSpinner.hide()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tablePlaces.count >= currentPage{
            return tablePlaces[currentPage-1].count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultsTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchResultsTableViewCell else{
            fatalError("The dequeued cell is not an instance of SearchResultsTableViewCell.")
        }
        
        let place = tablePlaces[currentPage-1][indexPath.row]
        cell.placeName.text = place.name
        cell.placeAddress.text = place.address
        
        let categoryData = NSData(contentsOf:place.categoryURL as URL)
        if categoryData != nil {
            cell.categoryImg.image = UIImage(data:categoryData! as Data)
        }
        
        let defaults = UserDefaults.standard
        var heartURL : URL?
        
        if var placeID = defaults.array(forKey: "placeID") {
            let placeID2 = defaults.array(forKey: "placeID") as! [String]
            if placeID2.contains(where:{$0 == place.placeID}){
                heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
                let favoritesData = NSData(contentsOf:heartURL!)
                if favoritesData != nil {
                    cell.favImg.setImage(UIImage(data:favoritesData! as Data), for: .normal)
                    cell.favImg.removeTarget(self, action: #selector(addToFav), for: .touchUpInside)
                    cell.favImg.addTarget(self, action: #selector(removeFav), for: .touchUpInside)
                    cell.favImg.tintColor = UIColor.red
                }
            }
            else{
                heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
                let favoritesData = NSData(contentsOf:heartURL!)
                if favoritesData != nil {
                    cell.favImg.setImage(UIImage(data:favoritesData! as Data), for: .normal)
                    cell.favImg.removeTarget(self, action: #selector(removeFav), for: .touchUpInside)
                    cell.favImg.addTarget(self, action: #selector(addToFav), for: .touchUpInside)
                    cell.favImg.tintColor = UIColor.gray
                }
            }
        } else {
            heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
            let favoritesData = NSData(contentsOf:heartURL!)
            if favoritesData != nil {
                cell.favImg.setImage(UIImage(data:favoritesData! as Data), for: .normal)
                cell.favImg.removeTarget(self, action: #selector(removeFav), for: .touchUpInside)
                cell.favImg.addTarget(self, action: #selector(addToFav), for: .touchUpInside)
                cell.favImg.tintColor = UIColor.gray
            }
        }
        
        cell.placeID.text = place.placeID
        
        return cell
    }
    
    func nextSearchPage() {
        places.removeAll();
        if tablePlaces.count == currentPage{
            SwiftSpinner.show("Loading next page...")
            let nextToken = tokens[currentPage - 1]
            let url = "http://entertainmentsearch-env.us-east-2.elasticbeanstalk.com/index.php?nextToken=\(nextToken)"
            Alamofire.request(url).responseSwiftyJSON { response in
                let json = response.result.value
                let isSuccess = response.result.isSuccess
                
                if (isSuccess && (json != nil)) {
                    
                    let placeArray = json!["results"].arrayValue
                    
                    for aPlace in placeArray {
                        let name = aPlace["name"].stringValue
                        let categoryURL = aPlace["icon"].stringValue
                        let address = aPlace["vicinity"].stringValue
                        let placeID = aPlace["place_id"].stringValue
                        
                        let place = Place(name: name, address:address, categoryURL: NSURL(string:categoryURL)!,placeID:placeID)
                        
                        self.places.append(place)
                    }
                    
                    if (json!["next_page_token"].exists()){
                        self.tokens.append(json!["next_page_token"].stringValue)
                        self.delegate?.updateButton(prevInfo: true,nextInfo: true)
                    }
                    else{
                        self.delegate?.updateButton(prevInfo: true,nextInfo: false)
                    }
                    
                    self.tablePlaces.append(self.places)
                    
                    self.currentPage = self.currentPage + 1;
                    
                    self.tableView.reloadData()
                    SwiftSpinner.hide()
                }
            }
        }
        else{
            self.currentPage = self.currentPage + 1;
            self.delegate?.updateButton(prevInfo: true, nextInfo: true)
            self.tableView.reloadData()
        }
    }
    
    func prevSearchPage() {
        self.currentPage = self.currentPage - 1;
        
        if(self.currentPage == 1){
            self.delegate?.updateButton(prevInfo: false,nextInfo: true)
        }
        else{
            self.delegate?.updateButton(prevInfo: true,nextInfo: true)
        }
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabViewController = segue.destination as? TabViewController {
            let selectedPlaceCell = sender as? SearchResultsTableViewCell
            tabViewController.placeID = (selectedPlaceCell?.placeID.text)!
        }
    }
    
    @objc func addToFav(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to:tableView)
        let indexPath = tableView.indexPathForRow(at:buttonPosition)
        
        let defaults = UserDefaults.standard
        
        if var names = defaults.array(forKey: "placeNames") {
            names.append(tablePlaces[currentPage-1][(indexPath?.row)!].name)
            defaults.set(names, forKey: "placeNames")
            
        } else {
            let namesArr = [tablePlaces[currentPage-1][(indexPath?.row)!].name]
            defaults.set(namesArr, forKey: "placeNames")
        }
        
        if var address = defaults.array(forKey: "placeAddresses") {
            address.append(tablePlaces[currentPage-1][(indexPath?.row)!].address)
            defaults.set(address, forKey: "placeAddresses")
        } else {
            let addressArr = [tablePlaces[currentPage-1][(indexPath?.row)!].address]
            defaults.set(addressArr, forKey: "placeAddresses")
        }
        
        if var category = defaults.array(forKey: "placeCategory") {
            category.append(tablePlaces[currentPage-1][(indexPath?.row)!].categoryURL.absoluteString)
            defaults.set(category, forKey: "placeCategory")
        } else {
            let categoryArr = [tablePlaces[currentPage-1][(indexPath?.row)!].categoryURL.absoluteString]
            defaults.set(categoryArr, forKey: "placeCategory")
        }
        
        if var placeID = defaults.array(forKey: "placeID") {
            placeID.append(tablePlaces[currentPage-1][(indexPath?.row)!].placeID)
            defaults.set(placeID, forKey: "placeID")
        } else {
            let idArr = [tablePlaces[currentPage-1][(indexPath?.row)!].placeID]
            defaults.set(idArr, forKey: "placeID")
        }
        
        let heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
        let favoritesData = NSData(contentsOf:heartURL!)
        if favoritesData != nil {
            let cell = tableView.cellForRow(at: indexPath!) as! SearchResultsTableViewCell
            cell.favImg.setImage(UIImage(data:favoritesData! as Data), for: .normal)
            cell.favImg.removeTarget(self, action: #selector(addToFav), for: .touchUpInside)
            cell.favImg.addTarget(self, action: #selector(removeFav), for: .touchUpInside)
            cell.favImg.tintColor = UIColor.red
        }
        
        var name = tablePlaces[currentPage-1][(indexPath?.row)!].name as! String
        self.view.showToast("\(name) was added to favorites", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
    }
    
    @objc func removeFav(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to:tableView)
        let indexPath = tableView.indexPathForRow(at:buttonPosition)
        
        let defaults = UserDefaults.standard
        
        var placeID = defaults.array(forKey: "placeID") as! [String]
        let placeIDIndex = placeID.index(of: tablePlaces[currentPage-1][(indexPath?.row)!].placeID)
        placeID.remove(at: placeIDIndex!)
        
        defaults.set(placeID, forKey: "placeID")
        
        var names = defaults.array(forKey: "placeNames") as! [String]
        names.remove(at: placeIDIndex!)
        defaults.set(names, forKey: "placeNames")
        
        var address = defaults.array(forKey: "placeAddresses") as! [String]
        address.remove(at: placeIDIndex!)
        defaults.set(address, forKey: "placeAddresses")
        
        var category = defaults.array(forKey: "placeCategory") as! [String]
        category.remove(at: placeIDIndex!)
        defaults.set(category, forKey: "placeCategory")
        
        let heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
        let favoritesData = NSData(contentsOf:heartURL!)
        if favoritesData != nil {
            let cell = tableView.cellForRow(at: indexPath!) as! SearchResultsTableViewCell
            cell.favImg.setImage(UIImage(data:favoritesData! as Data), for: .normal)
            cell.favImg.removeTarget(self, action: #selector(removeFav), for: .touchUpInside)
            cell.favImg.addTarget(self, action: #selector(addToFav), for: .touchUpInside)
            cell.favImg.tintColor = UIColor.gray
        }
        
        var name = tablePlaces[currentPage-1][(indexPath?.row)!].name as! String
        self.view.showToast("\(name) was removed from favorites", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
    }
    
}
