//
//  ViewController.swift
//  PixelCity
//
//  Created by James Volmert on 6/24/19.
//  Copyright © 2019 James Volmert. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    @IBOutlet weak var pixelMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pixelMapView.delegate = self
        locationManager.delegate = self
        configureLocationService()
    }

    @IBAction func mapButtonPressed(_ sender: Any) {
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        pixelMapView.setRegion(coordinateRegion, animated: true)
        
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationService() {
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
    
}
