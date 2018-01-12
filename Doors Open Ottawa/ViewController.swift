//
//  ViewController.swift
//  Doors Open Ottawa
//
//  Created by Eric Moolenbeek on 2018-01-02.
//  Copyright © 2018 Eric M. All rights reserved.
//
//  MapKit:
//  https://algonquin.instructure.com/courses/822915/pages/embedding-a-map-with-mapkit?module_item_id=14925634
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // Create UI Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
   
    // Dictionary
    var jsonObj: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting label outlet text as building name
        self.label.text = jsonObj!["nameEN"] as? String
        
        // Setting textview outlet as descriptionEN of building
        self.textView.text = jsonObj!["descriptionEN"] as? String
        
        // Call function to load building image
        loadBuildingImage()
        
        // mapView
        let geocodedAddresses = CLGeocoder()
        geocodedAddresses.geocodeAddressString((jsonObj!["addressEN"] as? String)! + " " + (jsonObj!["city"] as? String)!, completionHandler: placeMarkerHandler)

        
        
    }
    
    func placeMarkerHandler (placeMarkers: Optional<Array<CLPlacemark>>, error: Optional<Error>) -> Void{
        if let firstMarker = placeMarkers?[0] {
            let marker = MKPlacemark(placemark: firstMarker)
            self.mapView?.addAnnotation(marker)
            let myRegion = MKCoordinateRegionMakeWithDistance(marker.coordinate, 500, 500)
            self.mapView?.setRegion(myRegion, animated: false)
        }
    }
    
    
    func loadBuildingImage() {
        
        // Create the URLSession object that will be used to make the requests
        let mySession: URLSession = URLSession.shared
        
        // Get the current planetId value
        let currentID = jsonObj!["buildingId"] as? Int
        // Write a url using the currentID to request the image data
        let imageRequestUrl: URL = URL(string: "https://doors-open-ottawa.mybluemix.net/buildings/\(currentID!)/image")!
        
        // Create the request object and pass in your url
        let imageRequest: URLRequest = URLRequest(url: imageRequestUrl)
        // Make the specific task from the session by passing in your image request, and the function that will be use to handle the image request
        let imageTask = mySession.dataTask(with: imageRequest, completionHandler: imageRequestTask )
        
        // Tell the image task to run
        imageTask.resume()
        
    }
    
    // Define a function that will handle the image request which will need to recieve the data send back, the response status, and an error object to handle any errors returned
    func imageRequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // If the error object has been set then an error occured
        if serverError != nil {
            // Send en empty string as the data, and the error to the callback function
            print("IMAGE LOADING ERROR: " + serverError!.localizedDescription)
        }else{
            // Else take the image data recieved from the server and process it
            // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
            DispatchQueue.main.async {
                // Set the ImageView's image by converting the data object into a UIImage
                self.imageView.image = UIImage(data: serverData!)
            }
        }
    }


}

