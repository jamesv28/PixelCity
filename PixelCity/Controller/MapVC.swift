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

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    @IBOutlet weak var pixelMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pixelMapView.delegate = self
        locationManager.delegate = self
        configureLocationService()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        pixelMapView.addGestureRecognizer(doubleTap)
        
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
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        
        let touchPoint = sender.location(in: pixelMapView)
        let touchCoordinate = pixelMapView.convert(touchPoint, toCoordinateFrom: pixelMapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppable pin")
        pixelMapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        pixelMapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func removePin() {
        for annotation in pixelMapView.annotations {
            pixelMapView.removeAnnotation(annotation)
        }
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
