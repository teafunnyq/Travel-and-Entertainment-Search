//
//  TableViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/12/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cosmos

class ReviewsTableViewController: UITableViewController {
    
    struct Review {
        let authorName : String?
        let rating: Double?
        let authorPic : NSURL?
        let timePosted : Double?
        let googleURL : NSURL?
        let text : String?
    }
    
    var reviewJSON = [JSON]()
    var reviews = [Review]()
    
    var yelpJSON = [JSON]()
    var yelpReviews = [Review]()
    
    var copyOfReviews = [Review]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for aReview in reviewJSON{
            var name = ""
            var rating : Double?
            var authorURL = ""
            var time : Double?
            var pic = ""
            var text = ""

            if(aReview["author_name"].exists()){
                name = aReview["author_name"].stringValue
            }
            if(aReview["rating"].exists()){
                rating = aReview["rating"].doubleValue
            }
            if(aReview["author_url"].exists()){
                authorURL = aReview["author_url"].stringValue
            }
            if(aReview["time"].exists()){
                time = aReview["time"].doubleValue
            }
            if(aReview["profile_photo_url"].exists()){
                pic = aReview["profile_photo_url"].stringValue
            }
            if(aReview["text"].exists()){
                text = aReview["text"].stringValue
            }
            
            let review = Review(authorName: name, rating: rating, authorPic: NSURL(string:pic), timePosted: time, googleURL: NSURL(string:authorURL), text: text)
            self.reviews.append(review)
        }
        
        self.copyOfReviews = self.reviews
        
        for aReview in yelpJSON{
            var name = ""
            var rating : Double?
            var authorURL = ""
            var time : String?
            var pic  = ""
            var text = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            var date : Date?
            var unixTime : Double?
            
            if(aReview["user"]["name"].exists()){
                name = aReview["user"]["name"].stringValue
            }
            if(aReview["rating"].exists()){
                rating = aReview["rating"].doubleValue
            }
            if(aReview["url"].exists()){
                authorURL = aReview["url"].stringValue
            }
            if(aReview["time_created"].exists()){
                time = aReview["time_created"].stringValue
                date = dateFormatter.date(from: time!)
                unixTime =  Double((date?.timeIntervalSince1970)!)
            }
            if(aReview["user"]["image_url"].exists()){
                pic = aReview["user"]["image_url"].stringValue
            }
            if(aReview["text"].exists()){
                text = aReview["text"].stringValue
            }
            
            let review = Review(authorName: name, rating: rating, authorPic: NSURL(string:pic), timePosted: unixTime, googleURL: NSURL(string:authorURL), text: text)
            self.yelpReviews.append(review)
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 97
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return copyOfReviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ReviewsTableViewCell"
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReviewsTableViewCell else{
            fatalError("The dequeued cell is not an instance of ReviewsTableViewCell.")
        }
        
        let place = copyOfReviews[indexPath.row]
        cell.authorName.text = place.authorName
        cell.ratings.rating = place.rating!
        
        let authorPic = NSData(contentsOf:place.authorPic as! URL)
        if authorPic != nil {
            cell.authorImg.image = UIImage(data:authorPic! as Data)
        }
        
        cell.reviewText.text = place.text
        
        let date = NSDate(timeIntervalSince1970: place.timePosted!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        cell.timePosted.text = dateString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = copyOfReviews[indexPath.row].googleURL
        UIApplication.shared.openURL(url as! URL)
    }
    
    func sortReviews(whichKind: String, sortBy:String, order: String){
        if whichKind == "Google Reviews"{
            self.copyOfReviews = self.reviews
        }
        else{
            self.copyOfReviews = self.yelpReviews
        }

        if sortBy == "Rating"{
            if order == "Ascending"{
                self.copyOfReviews = self.copyOfReviews.sorted(by: { $0.rating! < $1.rating! })
            }else{
                self.copyOfReviews = self.copyOfReviews.sorted(by: { $0.rating! > $1.rating! })
            }
            
        }
        else if sortBy == "Date"{
            if order == "Ascending"{
                self.copyOfReviews = self.copyOfReviews.sorted(by: { $0.timePosted! < $1.timePosted! })
            }else{
                self.copyOfReviews = self.copyOfReviews.sorted(by: { $0.timePosted! > $1.timePosted! })
            }
        }
        self.tableView.reloadData()
    }
}
