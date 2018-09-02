//
//  ViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/10/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import AlamofireSwiftyJSON
import Alamofire
import SwiftSpinner
import GooglePlaces
import GoogleMaps
import SwiftyJSON
import EasyToast

class TabViewController: UITabBarController {
    
    var placeID = String();
    
    var addressJSON = String()
    var phoneJSON = String()
    var ratingJSON = 10.0
    var websiteJSON = String()
    var googlePageJSON = String()
    var priceJSON = Int()
    var placeLat = Double()
    var placeLng = Double()
    var name = String()
    var vicinity = String()
    
    var categoryURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SwiftSpinner.show(duration: 9.0, title: "Getting details...")
        
        let defaults = UserDefaults.standard
        var heartURL : URL?
        var favButton : UIBarButtonItem
        if var placeID = defaults.array(forKey: "placeID") {
            var placeID2 = defaults.array(forKey: "placeID") as! [String]
            if placeID2.contains(where:{$0 == self.placeID}){
                heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
                let data = try? Data(contentsOf: heartURL!)
                let heartImage: UIImage = UIImage(data: data!)!
                favButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(removeFav))
            }else{
                heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
                let data = try? Data(contentsOf: heartURL!)
                let heartImage: UIImage = UIImage(data: data!)!
                favButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(addToFav))
            }
        }
        else {
            heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-empty.png")
            let data = try? Data(contentsOf: heartURL!)
            let heartImage: UIImage = UIImage(data: data!)!
            favButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(addToFav))
        }

        let tweeturl = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/forward-arrow.png")
        let tweetdata = try? Data(contentsOf: tweeturl!)
        let tweetImage: UIImage = UIImage(data: tweetdata!)!
        let tweetButton = UIBarButtonItem(image: tweetImage, style: .plain, target : self, action :  #selector(tweet))
       
        self.navigationItem.rightBarButtonItems = [favButton,tweetButton]
        
        let allTabVC = self.viewControllers
        let url = "http://entertainmentsearch-env.us-east-2.elasticbeanstalk.com/index.php?placeID=\(placeID)"
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                let photoVC = allTabVC![1] as! PhotosViewController
                let _ = photoVC.view
                let mapVC = allTabVC![2] as! MapViewController
                let a = mapVC.view
                let reviewVC = allTabVC![3] as! ReviewContainerViewController
                
                let detailInfo = json!["result"];
                self.addressJSON = detailInfo["formatted_address"].stringValue
                self.phoneJSON =  detailInfo["international_phone_number"].stringValue
                if(detailInfo["rating"].exists()){
                    self.ratingJSON = detailInfo["rating"].doubleValue
                }
                self.websiteJSON = detailInfo["website"].stringValue
                self.googlePageJSON = detailInfo["url"].stringValue
                self.priceJSON = detailInfo["price_level"].intValue
                self.categoryURL = detailInfo["icon"].stringValue
                self.vicinity = detailInfo["vicinity"].stringValue
                
                self.placeLat = detailInfo["geometry"]["location"]["lat"].doubleValue
                self.placeLng = detailInfo["geometry"]["location"]["lng"].doubleValue
                
                reviewVC.reviewArray = detailInfo["reviews"].arrayValue
                
                var addrNum = "", streetName = "", city="", state = "", country = "";
                var addressParts = detailInfo["address_components"].arrayValue
                for part in addressParts{
                    var temp = part["types"][0].stringValue
                    if(temp == "street_number"){
                        addrNum = part["long_name"].stringValue
                    }
                    else if (temp == "route"){
                        streetName = part["long_name"].stringValue
                    }
                    else if(temp == "locality" || temp == "administrative_area_level_3"){
                        city = part["long_name"].stringValue
                    }
                    else if(temp == "administrative_area_level_1"){
                        state = part["short_name"].stringValue
                    }
                    else if(temp == "country"){
                        country = part["short_name"].stringValue
                    }
                }
                var fullAddress = addrNum + " " + streetName
                self.name = detailInfo["name"].stringValue

                var yelpQuery = "yelpapi=true&name=\(self.name)&address1=\(fullAddress)&city=\(city)&state=\(state)&country=\(country)"
                yelpQuery = yelpQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                var yelpURL = "http://entertainmentsearch-env.us-east-2.elasticbeanstalk.com/index.php?\(yelpQuery)"
                Alamofire.request(yelpURL).responseSwiftyJSON { response in
                    let json = response.result.value
                    let isSuccess = response.result.isSuccess
                    if (isSuccess && (json != nil)) {
                        reviewVC.yelpReviews = json!["reviews"].arrayValue
                        let b = reviewVC.view
                    }
                }

                var dollarSigns = ""
                if(self.priceJSON == 0){
                    dollarSigns =  "Free"
                }
                else{
                    for _ in 1...self.priceJSON {
                        dollarSigns += "$"
                    }
                }
                
                self.navigationItem.title = detailInfo["name"].stringValue

                let infoVC = allTabVC![0] as! InfoViewController
                
                if(self.addressJSON != ""){
                    infoVC.address.text = self.addressJSON
                }else{
                    infoVC.address.text = "No address"
                }
                if(self.googlePageJSON != ""){
                    infoVC.googlePage.text = self.googlePageJSON
                }else{
                    infoVC.googlePage.text = "No Google page"
                }
                if(self.phoneJSON != ""){
                    infoVC.phone.text = self.phoneJSON
                }else{
                    infoVC.phone.text = "No phone number"
                }
                if(self.websiteJSON != ""){
                    infoVC.website.text = self.websiteJSON
                }else{
                    infoVC.website.text = "No website"
                }
                if(self.ratingJSON != 10.0){
                    infoVC.ratings.rating = self.ratingJSON
                    infoVC.ratings.alpha = 1
                    infoVC.noRating.alpha = 0
                }
                else{
                    infoVC.ratings.alpha = 0
                    infoVC.noRating.alpha = 1
                }
                infoVC.price.text = dollarSigns
                
                var scrollView = photoVC.photoScroll
                GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.placeID) { (photos, error) -> Void in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        if let photoArray = photos?.results {
                            var yPosition:CGFloat = 0
                            var scrollViewContentSize:CGFloat=0
                            for image in photoArray{
                                GMSPlacesClient.shared().loadPlacePhoto(image, callback: {
                                    (photo, error) -> Void in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                    } else {
                                        var myImageView:UIImageView = UIImageView(image: photo)
                                        var height2width = (photo?.size.height)! / (photo?.size.width)!
                                        myImageView.frame = CGRect(x: 0, y: yPosition, width: 414, height: height2width * 414)
                                        scrollView?.addSubview(myImageView)
                                        let spacer:CGFloat = 10
                                        yPosition += ((height2width * 414) + spacer)
                                        scrollViewContentSize += ((height2width * 414) + spacer)
                                        scrollView?.contentSize = CGSize(width: 414, height: scrollViewContentSize)
                                    }
                                })
                            }
                            if( photoArray.count == 0){
                                let sampleTextField =  UITextField(frame: CGRect(x: 169, y: 254, width: 185, height: 53))
                                sampleTextField.text = "No photos"
                                sampleTextField.minimumFontSize = 23.0
                                scrollView?.addSubview(sampleTextField)
                            }
                        }
                    }
                }
                
                let camera = GMSCameraPosition.camera(withLatitude: self.placeLat, longitude: self.placeLng, zoom: 16.0)
                mapVC.mapBox.camera = camera
                
                let initialLocation = CLLocationCoordinate2D(latitude: self.placeLat, longitude: self.placeLng)
                let marker = GMSMarker(position: initialLocation)
                marker.map = mapVC.mapBox
            }
        }
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func tweet(sender: UIButton) {
        var twitterMsg = "Check out " + self.name + " located at " + self.addressJSON + ". Website:";
        var placeSite = ""
        if (self.websiteJSON != ""){
            placeSite = self.websiteJSON
        }
        else{
            placeSite = self.googlePageJSON
        }
        var twitterQuery = "text=" + twitterMsg + "&url=" + placeSite + "&hashtags=TravelAndEntertainmentSearch"
        twitterQuery = twitterQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        var twitterLink = "https://twitter.com/intent/tweet/?\(twitterQuery)"
        UIApplication.shared.openURL(NSURL(string: twitterLink)! as URL)
    }
    
    @objc func addToFav(sender: UIButton) {

        let defaults = UserDefaults.standard
        
        if var names = defaults.array(forKey: "placeNames") {
            names.append(self.name)
            defaults.set(names, forKey: "placeNames")
            
        } else {
            let namesArr = [self.name]
            defaults.set(namesArr, forKey: "placeNames")
        }
        
        if var address = defaults.array(forKey: "placeAddresses") {
            address.append(self.vicinity)
            defaults.set(address, forKey: "placeAddresses")
        } else {
            let addressArr = [self.vicinity]
            defaults.set(addressArr, forKey: "placeAddresses")
        }
        
        if var category = defaults.array(forKey: "placeCategory") {
            category.append(self.categoryURL)
            defaults.set(category, forKey: "placeCategory")
        } else {
            let categoryArr = [self.categoryURL]
            defaults.set(categoryArr, forKey: "placeCategory")
        }
        
        if var placeID = defaults.array(forKey: "placeID") {
            placeID.append(self.placeID)
            defaults.set(placeID, forKey: "placeID")
        } else {
            let idArr = [self.placeID]
            defaults.set(idArr, forKey: "placeID")
        }
        
        let heartURL = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/favorite-filled.png")
        let favoritesData = NSData(contentsOf:heartURL!)
        var favButton = UIBarButtonItem()
        if favoritesData != nil {
            favButton = UIBarButtonItem(image: UIImage(data:favoritesData! as Data), style: .plain, target: self, action: #selector(removeFav))
        }
        
        let tweeturl = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/forward-arrow.png")
        let tweetdata = try? Data(contentsOf: tweeturl!)
        let tweetImage: UIImage = UIImage(data: tweetdata!)!
        let tweetButton = UIBarButtonItem(image: tweetImage, style: .plain, target : self, action :  #selector(tweet))
        
        self.navigationItem.rightBarButtonItems = [favButton,tweetButton]
        
        self.view.showToast("\(self.name) was added to favorites", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
    }
    
    @objc func removeFav(sender: UIButton) {
        let defaults = UserDefaults.standard
        
        var placeID = defaults.array(forKey: "placeID") as! [String]
        let placeIDIndex = placeID.index(of: self.placeID)
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
        var favButton = UIBarButtonItem()
        if favoritesData != nil {
            favButton = UIBarButtonItem(image: UIImage(data:favoritesData! as Data), style: .plain, target: self, action: #selector(addToFav))
        }
        
        let tweeturl = URL(string:"http://cs-server.usc.edu:45678/hw/hw9/images/ios/forward-arrow.png")
        let tweetdata = try? Data(contentsOf: tweeturl!)
        let tweetImage: UIImage = UIImage(data: tweetdata!)!
        let tweetButton = UIBarButtonItem(image: tweetImage, style: .plain, target : self, action :  #selector(tweet))
        
        self.navigationItem.rightBarButtonItems = [favButton,tweetButton]
        
        self.view.showToast("\(self.name) was removed from favorites", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
    }
}
