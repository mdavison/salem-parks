//
//  MapViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import MapKit

class AnnotationButton: UIButton {
    var view: MKPinAnnotationView?
}


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nearbyButton: UIBarButtonItem!
    
    let regionRadius: CLLocationDistance = 10_000 // Meters
    let parkData = ParkData()
    
    var coreDataStack: CoreDataStack!
    var parkAnnotations = [ParkAnnotation]()
    var park: Park?
    var parkLocationManager: ParkLocationManager!
    
    struct Storyboard {
        static let ShowParkDetailsSegueIdentifier = "ShowParkDetailsFromMap"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Theme
        navigationController?.navigationBar.tintColor = UIColor.white
        
        parkLocationManager = ParkLocationManager(mapViewController: self)
        parkAnnotations = parkData.getMapAnnotations()
        
        mapView.delegate = self

        // Set initial location in Salem
        let initialLocation = CLLocation(latitude: 44.9429, longitude: -123.0351)
        centerMapOnLocation(initialLocation)

        mapView.addAnnotations(parkAnnotations)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ShowParkDetailsSegueIdentifier {
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.coreDataStack = coreDataStack 
                detailViewController.park = park
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showNearbyParks(_ sender: AnyObject) {
        if isMonitoringRegions == true { // Turn it OFF
            parkLocationManager.stopMonitoringNearbyParks()
            //nearbyButton.title = "Nearby"
            nearbyButton.image = UIImage(named: "Near Me")
            mapView.showsUserLocation = false
        } else {                        // Turn it ON
            parkLocationManager.startMonitoringNearbyParks()
            mapView.showsUserLocation = true
            //nearbyButton.title = "Turn Off"
            nearbyButton.image = UIImage(named: "Near Me Filled")
        }
    }
    
    
    // MARK: - Helper Methods
    
    fileprivate func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.animatesDrop = true
                //view.calloutOffset = CGPoint(x: -5, y: 5)
                //let rightButton = UIButton(type: .DetailDisclosure)
                let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.bounds.size.height, height: view.bounds.size.height))
                rightButton.setImage(UIImage(named: "More Than"), for: UIControlState())
                rightButton.tintColor = UIColor.lightGray
                view.rightCalloutAccessoryView = rightButton
                
                let leftButton = AnnotationButton(frame: CGRect(x: 0, y: 0, width: view.bounds.size.height + 8, height: view.bounds.size.height + 12))
                leftButton.view = view
                leftButton.backgroundColor = leftButton.tintColor
                leftButton.setImage(UIImage(named: "Car"), for: UIControlState())
                leftButton.tintColor = UIColor.white
                leftButton.addTarget(self, action: #selector(MapViewController.getDrivingDirections(_:)), for: .touchUpInside)
                view.leftCalloutAccessoryView = leftButton
            }
            
            //view.pinTintColor = annotation.pinColor()
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? ParkAnnotation {
            park = Park.getPark(forID: annotation.objectID, coreDataStack: coreDataStack)
            performSegue(withIdentifier: Storyboard.ShowParkDetailsSegueIdentifier, sender: self)
        }
    }
    
    func getDrivingDirections(_ button: AnnotationButton) {
        if let location = button.view?.annotation as? ParkAnnotation {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        parkLocationManager.handleUpdateLocations(locations, parkAnnotations: parkAnnotations)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        NSLog("Monitering failed for region: \(String(describing: region?.identifier)). Error: \(error)")
        print("managed regions: \(manager.monitoredRegions.count)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        NSLog("User is already in region: \(region.identifier)")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.handleRegionEvent(region)
        }
    }
}
