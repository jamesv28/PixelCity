//
//  ViewController.swift
//  PixelCity
//
//  Created by James Volmert on 6/24/19.
//  Copyright © 2019 James Volmert. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var pixelMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pixelMapView.delegate = self
        
    }

    @IBAction func mapButtonPressed(_ sender: Any) {
    }
    
}

extension MapVC: MKMapViewDelegate {
    
}
