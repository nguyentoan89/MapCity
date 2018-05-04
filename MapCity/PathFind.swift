//
//  PathFind.swift
//  MapCity
//
//  Created by Nguyen Cong Toan on 4/29/18.
//  Copyright © 2018 mr.t. All rights reserved.
//

import UIKit
import MapKit
class PathFind: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    @IBOutlet weak  var mapview: MKMapView!
    var fromLocation: CLLocation!
    var locationManager = CLLocationManager()
    var overlay: MKOverlay?
    var direction: MKDirections?
    var foundPlace: CLPlacemark?
    var geoCoder: CLGeocoder?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        self.geoCoder = CLGeocoder()
       self.locationManager.delegate=self
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapview.showsUserLocation=true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(overlay != nil)
        {
            self.mapview.remove(overlay!)
        }
        lookForAddress(addressString: textField.text! as NSString)
        return true
    }
    func lookForAddress(addressString: NSString)
    {
        if(addressString == "")
        {
            return
        }
        self.geoCoder?.geocodeAddressString(addressString as String, completionHandler: { (placemarks, error) in
            if (error == nil)
            {
                self.foundPlace = placemarks!.first
                let toPlace: MKPlacemark = MKPlacemark(placemark: self.foundPlace!)
                self.routePath(fromPlace: MKPlacemark(coordinate: self.fromLocation!.coordinate, addressDictionary: nil),toLocation: toPlace)
            }
            })
    }
    func  routePath(fromPlace: MKPlacemark, toLocation toPlace: MKPlacemark)
    {
        let request: MKDirectionsRequest = MKDirectionsRequest()
        let fromMapItem: MKMapItem = MKMapItem(placemark: fromPlace)
        request.source = fromMapItem
        let toMapItem: MKMapItem = MKMapItem(placemark: toPlace)
        request.destination = toMapItem
        self.direction = MKDirections(request: request)
        self.direction!.calculate{
            (response, error) in
            if(error == nil)
            {
                self.showRoute(response: response!)
            }
        }
    }
    func showRoute(response: MKDirectionsResponse)
    {
        for route in response.routes
        {
            for step in route.steps
            {
                print(step.instructions)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location:[CLLocation]){
    self.locationManager.stopUpdatingLocation()
        self.fromLocation=location.last
        self.updateRegion(scale: 2.0)
    }
    func updateRegion(scale: CGFloat){
        let size: CGSize = self.mapview.bounds.size
        let region = MKCoordinateRegionMakeWithDistance(fromLocation!.coordinate, Double(size.height * scale), Double(size.width * scale))
        
    self.mapview.setRegion(region, animated: true)
    }
}
