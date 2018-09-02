//
//  SearchViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/7/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import McPicker
import GooglePlaces
import EasyToast
import CoreLocation

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var latLonStr = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data:[[String]] = [["Default","Airport","Amusement Park", "Aquarium","Art Gallery", "Bakery", "Bar", "Beauty Salon", "Bowling Alley", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie Theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Station", "Train Station", "Transit Station", "Travel Agency"]]
        let mcInputView = McPicker(data:data)
        mcTextField.inputViewMcPicker = mcInputView
        mcTextField.text = "Default"
        
        mcTextField.doneHandler = { [weak mcTextField] (selections) in mcTextField?.text = selections[0]!;}
        
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latLonStr = "\(locValue.latitude),\(locValue.longitude)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var keywordField: McTextField!
    @IBOutlet weak var mcTextField: McTextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var fromLocation: UITextField!
    
    
    @IBAction func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var trimmedKeyword = (keywordField.text)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKeyword == ""{
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerViewController = segue.destination as? ContainerViewController {
            containerViewController.keyword = keywordField.text!
            containerViewController.category = mcTextField.text!.replacingOccurrences(of: " ", with: "_")
            if(distanceField.text == ""){
                containerViewController.distance = "10"
            }
            else{
                containerViewController.distance = distanceField.text!
            }
            
            if(fromLocation.text == "Your location"){
                containerViewController.location = latLonStr
                containerViewController.inputLocation = "";
            }
            else{
                containerViewController.location = "otherLocation";
                containerViewController.inputLocation = fromLocation.text!
            }
        }
    }
    
    @IBAction func clearForm(_ sender: UIButton) {
        keywordField.text = "";
        mcTextField.text = "Default"
        let data:[[String]] = [["Default","Airport","Amusement Park", "Aquarium","Art Gallery", "Bakery", "Bar", "Beauty Salon", "Bowling Alley", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie Theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Station", "Train Station", "Transit Station", "Travel Agency"]]
        let mcInputView = McPicker(data:data)
        mcTextField.inputViewMcPicker = mcInputView
        distanceField.text = ""
        fromLocation.text = "Your location"
    }
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromLocation.text = place.formattedAddress;
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
