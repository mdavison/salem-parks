//
//  ParkLocationManager.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/12/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import CoreLocation
import UIKit

class ParkLocationManager {
    
    let locationManager = CLLocationManager()
    var mapViewController: MapViewController
    var regions = [CLCircularRegion]() {
        didSet {
            clearMonitoredRegions()
        }
    }
    
    init(mapViewController: MapViewController) {
        self.mapViewController = mapViewController
    }
    
    func startMonitoringNearbyParks() {
        //print("monitorNearbyParks()")
        isMonitoringRegions = true
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            locationManager.delegate = mapViewController
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .authorizedWhenInUse:
                locationManager.requestAlwaysAuthorization()
            case .authorizedAlways:
                
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.distanceFilter = 500
                locationManager.startMonitoringSignificantLocationChanges()
                
                monitorRegions()
            case .denied, .restricted:
                showAlert(withTitle: "Error", message: "Location access has been disabled. Please enable it in settings and try again", viewController: mapViewController)
                break
            }
        } else {
            showAlert(withTitle: "Error", message: "This device does not support finding nearby parks.", viewController: mapViewController)
        }
    }
    
    func stopMonitoringNearbyParks() {
        //print("stop monitoring nearby parks")
        isMonitoringRegions = false 
        locationManager.stopMonitoringSignificantLocationChanges()
        clearMonitoredRegions()
    }
    
    func monitorRegions() {
        for region in regions {
            //print("region: \(region.description)")
            region.notifyOnEntry = true
            locationManager.startMonitoring(for: region)
            
            // Find out if already inside a region
            locationManager.requestState(for: region)
        }
    }
    
    func handleUpdateLocations(_ locations: [CLLocation], parkAnnotations: [ParkAnnotation]) {
        //print("didUpdateLocations")
        // If it's a relatively recent event, turn off updates to save power
        if let location = locations.last {
            let eventDate = location.timestamp
            let howRecent = eventDate.timeIntervalSinceNow
            if abs(howRecent) < 15.0 {
                // If the event is recent
                //print("significant change event")
                regions = Park.getRegions(forAnnotations: parkAnnotations, currentLocation: location)
                monitorRegions()
            }
        }
    }
    
    fileprivate func clearMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            //print("stopping: \(region.description)")
            locationManager.stopMonitoring(for: region)
        }
    }

    
}
