import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var screensize = UIScreen.main.bounds
    var imageUrls = [String]()
    
    // progromatically add collection view
    var flowLayout = UICollectionViewFlowLayout()
    var photoCollectionView: UICollectionView?
    
    
    // Outlets
    @IBOutlet weak var pixelMapView: MKMapView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var galleryViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pixelMapView.delegate = self
        locationManager.delegate = self
        configureLocationService()
        addDoubleTap()
        
        photoCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        photoCollectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self
        photoCollectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        galleryView.addSubview(photoCollectionView!)
        
    }
    
    func animateViewUp() {
        galleryViewHeightConstraint.constant = 240
        // animate the view
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func addSwipeDown() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipe.direction = .down
        galleryView.addGestureRecognizer(swipe)
    }
    
    @objc func swipeDown() {
        galleryViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screensize.width / 2) - ((spinner?.frame.width)! / 2), y: 130)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        photoCollectionView?.addSubview(spinner!)
        
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screensize.width / 2) - 200, y: 160, width: 300, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLabel?.textAlignment = .center
        photoCollectionView?.addSubview(progressLabel!)
    }
    
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
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
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> () ) {
        imageUrls = []
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, addNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!).jpg"
                self.imageUrls.append(postUrl)
            }
            handler(true)
        }
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.6039215686, green: 0.1960784314, blue: 0.8039215686, alpha: 1)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        pixelMapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        pixelMapView.showsUserLocation = false
        removePin()
        removeSpinner()
        removeProgressLabel()
        animateViewUp()
        addSwipeDown()
        addSpinner()
        addProgressLabel()
        
        
        let touchPoint = sender.location(in: pixelMapView)
        let touchCoordinate = pixelMapView.convert(touchPoint, toCoordinateFrom: pixelMapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppable pin")
        pixelMapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        pixelMapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (Bool) in
            print(self.imageUrls)
        }
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items in array
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView?.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
    
}
