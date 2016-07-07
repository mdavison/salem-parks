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
    let parkData = ParkData()
    
    var coreDataStack: CoreDataStack!
    var parksAnnotations = [ParkAnnotation]()
    var park: Park?
    
    struct Storyboard {
        static let ShowParkDetailsSegueIdentifier = "ShowParkDetailsFromMap"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        // Set initial location in Salem
        let initialLocation = CLLocation(latitude: 44.9429, longitude: -123.0351)
        centerMapOnLocation(initialLocation)

        //parkData = ParkData()
        mapView.addAnnotations(parkData.getMapAnnotations())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowParkDetailsSegueIdentifier {
            if let detailViewController = segue.destinationViewController as? DetailViewController {
                detailViewController.coreDataStack = coreDataStack 
                detailViewController.park = park
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
                view.animatesDrop = true
                //view.calloutOffset = CGPoint(x: -5, y: 5)
                //let rightButton = UIButton(type: .DetailDisclosure)
                let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.bounds.size.height, height: view.bounds.size.height))
                rightButton.setImage(UIImage(named: "More Than"), forState: .Normal)
                rightButton.tintColor = UIColor.lightGrayColor()
                view.rightCalloutAccessoryView = rightButton
                
                let leftButton = AnnotationButton(frame: CGRect(x: 0, y: 0, width: view.bounds.size.height + 8, height: view.bounds.size.height + 12))
                leftButton.view = view
                leftButton.backgroundColor = leftButton.tintColor
                leftButton.setImage(UIImage(named: "Car"), forState: .Normal)
                leftButton.tintColor = UIColor.whiteColor()
                leftButton.addTarget(self, action: #selector(MapViewController.getDrivingDirections(_:)), forControlEvents: .TouchUpInside)
                view.leftCalloutAccessoryView = leftButton
            }
            
            //view.pinTintColor = annotation.pinColor()
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? ParkAnnotation {
            park = Park.getPark(forID: annotation.objectID, coreDataStack: coreDataStack)
            print("park: \(park?.id)")
            performSegueWithIdentifier(Storyboard.ShowParkDetailsSegueIdentifier, sender: self)
        }
    }
    
    func getDrivingDirections(button: AnnotationButton) {
        print("get driving directions")
        if let location = button.view?.annotation as? ParkAnnotation {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMapsWithLaunchOptions(launchOptions)
        }
    }
}

class AnnotationButton: UIButton {
    var view: MKPinAnnotationView?
}
