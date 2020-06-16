
import UIKit
import MapKit

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    var destinationLocation: CLLocationCoordinate2D?
    var currentLocation: CLLocationCoordinate2D?
    var locations = UserDefaults.standard.value(forKey: "places") as! [[String: Any]]
    
    //MARK: - Variables
    fileprivate let locationManager: CLLocationManager = {
       let manager = CLLocationManager()
       manager.requestWhenInUseAuthorization()
       return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find My Way"
        setUpMapView()
    }
    
    //MARK: - Setup Methods
    func setUpMapView() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        gestureRecognizer.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.delegate = self
        currentLocationSetUp()
    }
    
    
    //MARK: - Helper Method
    func currentLocationSetUp() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          locationManager.showsBackgroundLocationIndicator = true
       }
       locationManager.startUpdatingLocation()
    }
    
    @objc func handleLongPress(gestureRecognizer: UITapGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        let touchPoint: CGPoint = gestureRecognizer.location(in: mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        lookUpCurrentLocation(with: newCoordinate) { placeMark in
            self.locations.append(["name": placeMark?.locality ?? "Favourite Place", "lat": newCoordinate.latitude, "long": newCoordinate.longitude])
            UserDefaults.standard.setValue(self.locations, forKey: "places")
            UserDefaults.standard.synchronize()
            self.navigationController?.popViewController(animated: true)
        }
        addAnnotationOnLocation(pointedCoordinate: newCoordinate)
    }
    
    func lookUpCurrentLocation(with location: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        let geocoder = CLGeocoder()
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude),
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                completionHandler(firstLocation)
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                completionHandler(nil)
                                            }
        })
    }
    
    func addAnnotationOnLocation(pointedCoordinate: CLLocationCoordinate2D) {
        destinationLocation = pointedCoordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = pointedCoordinate
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func navigateMeButtonTapped() {
        getDirections()
    }
    
    func getDirections() {
        guard let source = currentLocation , let destination = destinationLocation else { return }
        let sourceCoords: CLLocationCoordinate2D = source
        let placemark = MKPlacemark(coordinate: sourceCoords, addressDictionary: nil)
        let annotation = MKPointAnnotation()
        annotation.coordinate = sourceCoords
        annotation.title = "San Francisco"
        mapView.addAnnotation(annotation)
        var mapItem: MKMapItem? = nil
        mapItem = MKMapItem(placemark: placemark)
        let destCoords: CLLocationCoordinate2D = destination
        let placemark1 = MKPlacemark(coordinate: destCoords, addressDictionary: nil)
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = destCoords
        annotation1.title = "San Francisco University"
        mapView.addAnnotation(annotation1)
        var mapItem1: MKMapItem? = nil
            mapItem1 = MKMapItem(placemark: placemark1)
        let request = MKDirections.Request()
        request.source = mapItem1
        request.destination = mapItem
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        
        directions.calculate { (response: MKDirections.Response?,  _ error: Error?) in
            if error != nil {
                print("ERROR")
                print("\(error?.localizedDescription ?? "")")
            } else {
                self.showRoute(response)
            }
        }
    }
    
    func showRoute(_ response: MKDirections.Response?) {
        guard let res = response else { return }
        for route: MKRoute in res.routes {
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            for step: MKRoute.Step in route.steps {
                print("\(step.instructions)")
            }
        }
    }

}

//MARK: - CLLocationManagerDelegate Methods
extension HomeViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        self.currentLocation = currentLocation
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1500, longitudinalMeters: 1500)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
     }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer: MKPolylineRenderer? = nil
        if let anOverlay = overlay as? MKPolyline {
            renderer = MKPolylineRenderer(polyline: anOverlay)
        }
        renderer?.strokeColor = UIColor(red: 0.0 / 255.0, green: 171.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
        renderer?.lineWidth = 10.0
        if let aRenderer = renderer {
            return aRenderer
        }
        return MKOverlayRenderer()
    }
}



