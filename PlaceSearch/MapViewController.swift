//
//  ViewController.swift
//  PlaceSearch
//
//  Created by Tiffany Kyu on 4/11/18.
//  Copyright © 2018 Tiffany Kyu. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import AlamofireSwiftyJSON
import Alamofire

class MapViewController: UIViewController {
    
    @IBOutlet weak var fromLocation: UITextField!
    @IBOutlet weak var mapBox: GMSMapView!
    @IBOutlet weak var travelMode: UISegmentedControl!
    
    var currentPlace:CLLocationCoordinate2D?
    var orgMarker = GMSMarker()
    var destMarker: GMSMarker?
    
    var polyline = GMSPolyline()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func getDirections(_ sender: UISegmentedControl) {
        if(currentPlace != nil){
            let originLat = String(describing: currentPlace!.latitude)
            let originLng = String(describing: currentPlace!.longitude)
            let origin = originLat + "," + originLng
            let destLat = String(destMarker!.position.latitude)
            let destLng = String(destMarker!.position.longitude)
            let dest = destLat + "," + destLng
            
            var mode = travelMode.titleForSegment(at: travelMode.selectedSegmentIndex)
            mode = mode!.lowercased()
            
            let url = "http://entertainmentsearch-env.us-east-2.elasticbeanstalk.com/index.php?origin=\(origin)&destination=\(dest)&mode=\(mode!)"
            Alamofire.request(url).responseSwiftyJSON { response in
                let json = response.result.value
                let isSuccess = response.result.isSuccess
                if (isSuccess && (json != nil)) {
                    var route = json!["routes"][0]["legs"][0]["steps"].arrayValue
                    
                    let start = CLLocationCoordinate2D(latitude: route[0]["start_location"]["lat"].doubleValue, longitude: route[0]["start_location"]["lng"].doubleValue)
                    self.orgMarker.position = start
                    
                    let path = GMSMutablePath()
                    for step in route{
                        var polylinePoints = step["polyline"]["points"].stringValue
                        var polylinePath = GMSPath(fromEncodedPath: polylinePoints)
                        for index in UInt(1) ... (polylinePath?.count())!{
                            path.add((polylinePath?.coordinate(at: index-1))!)
                        }
                    }
                    
                    self.polyline.map = nil
                    self.polyline = GMSPolyline(path: path)
                    self.polyline.strokeColor = UIColor.blue
                    self.polyline.strokeWidth = 5
                    self.polyline.geodesic = true
                    self.polyline.map = self.mapBox
                    
                    let bounds = GMSCoordinateBounds(coordinate: self.currentPlace!, coordinate: self.destMarker!.position)
                    let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(15))
                    self.mapBox.moveCamera(GMSCameraUpdate.fit(bounds))
                }
            }
        }
        
    }

}

extension MapViewController: GMSAutocompleteViewControllerDelegate {

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromLocation.text = place.formattedAddress
        self.currentPlace = place.coordinate
        let originLat = String(place.coordinate.latitude)
        let originLng = String(place.coordinate.longitude)
        let origin = originLat + "," + originLng
        
        let end = CLLocationCoordinate2D(latitude: mapBox.camera.target.latitude, longitude: mapBox.camera.target.longitude)
        if(destMarker == nil){
            destMarker = GMSMarker(position: end)
        }
        
        let destLat = String(destMarker!.position.latitude)
        let destLng = String(destMarker!.position.longitude)
        let dest = destLat + "," + destLng
        
        var mode = travelMode.titleForSegment(at: travelMode.selectedSegmentIndex)
        mode = mode!.lowercased()
        let url = "http://entertainmentsearch-env.us-east-2.elasticbeanstalk.com/index.php?origin=\(origin)&destination=\(dest)&mode=\(mode!)"
        Alamofire.request(url).responseSwiftyJSON { response in
            let json = response.result.value
            let isSuccess = response.result.isSuccess
            if (isSuccess && (json != nil)) {
                var route = json!["routes"][0]["legs"][0]["steps"].arrayValue
                
                let start = CLLocationCoordinate2D(latitude: route[0]["start_location"]["lat"].doubleValue, longitude: route[0]["start_location"]["lng"].doubleValue)
                self.orgMarker.position = start
                
                if self.orgMarker.map == nil{
                    self.orgMarker.map = self.mapBox
                }
                
                let path = GMSMutablePath()
                for step in route{
                    var polylinePoints = step["polyline"]["points"].stringValue
                    var polylinePath = GMSPath(fromEncodedPath: polylinePoints)
                    for index in UInt(1) ... (polylinePath?.count())!{
                        path.add((polylinePath?.coordinate(at: index-1))!)
                    }
                }
                
                self.polyline.map = nil
                self.polyline = GMSPolyline(path: path)
                self.polyline.strokeColor = UIColor.blue
                self.polyline.strokeWidth = 5
                self.polyline.geodesic = true
                self.polyline.map = self.mapBox

                let bounds = GMSCoordinateBounds(coordinate: place.coordinate, coordinate: self.destMarker!.position)
                let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(15))
                self.mapBox.moveCamera(GMSCameraUpdate.fit(bounds))
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
