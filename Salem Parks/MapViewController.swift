//
//  MapViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 10_000 // This is meters
    var parksAnnotations = [ParkAnnotation]()
    
    var data: NSData?
    var jsonObject: AnyObject?
    var parksJSONDataArray: [JSONValue]?
    var parksStreetAddresses = [JSONValue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        // Set initial location in Salem
        let initialLocation = CLLocation(latitude: 44.9429, longitude: -123.0351)
        centerMapOnLocation(initialLocation)
        
        setJSONData()
        loadJSONData()
        
        mapView.addAnnotations(parksAnnotations)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func setJSONData() {
        let fileName = NSBundle.mainBundle().pathForResource("park_data", ofType: "json")
        do {
            data = try NSData(contentsOfFile: fileName!, options: NSDataReadingOptions(rawValue: 0))
        } catch {
            print("Error getting NSData")
        }
        
        var errorType: ErrorType?
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
        } catch {
            print("Error getting JSON Object")
            errorType = error
        }
        
        if let jsonObject = jsonObject as? [String: AnyObject] where errorType == nil,
            let featuresArray = JSONValue.fromObject(jsonObject)?["features"]?.array {
            parksJSONDataArray = featuresArray
            
            for feature in featuresArray {
                if let feature = feature.object {
                    //print(feature["attributes"])
                    if let parkJSON = feature["attributes"], address = parkJSON["ADDRESS"] {
                        //print(park["PARK_NAME"])
                        //print(park["ADDRESS"])
                        parksStreetAddresses.append(address)
                    }
                    
                }
            }
        }
    }
    
    func loadJSONData() {
        if let parksJSONDataArray = parksJSONDataArray {
            for feature in parksJSONDataArray {
                if let feature = feature.object {
                    if let parkJSON = feature["attributes"] {
                        var title: String?
                        var locationName: String?
                        var discipline: String?
                        
                        if let parkName = parkJSON["PARK_NAME"]?.string,
                            parkAddress = parkJSON["ADDRESS"]?.string,
                            parkStatus = parkJSON["STATUS"]?.string,
                            parkID = parkJSON["OBJECTID"]?.integer {
                            
                            title = parkName
                            locationName = parkAddress
                            discipline = parkStatus
                            
                            if let coordinate = ParkAnnotation.getCoordinate(forParkID: parkID) {
                                let park = ParkAnnotation(title: title!, locationName: locationName!, discipline: discipline!, coordinate: coordinate)
                                parksAnnotations.append(park)
                            }
                        }
                    }
                }
            }
        }
    }

}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
            
            //view.pinTintColor = annotation.pinColor()
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ParkAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
}
