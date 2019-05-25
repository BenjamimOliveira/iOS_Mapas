//
//  ViewController.swift
//  iOS_Mapa
//
//  Created by Benjamim on 25/05/19.
//  Copyright © 2019 Benjamim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        let initialLocation = CLLocation(latitude: 41.701497, longitude: -8.834756)
        
        centerMapOnLocation(location: initialLocation)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
        mapView.addGestureRecognizer(tapGesture)
        mapView.addGestureRecognizer(longPressRecognizer)
    
    }
    
    @IBOutlet weak var textoGeo: UITextField!
    var geocoder = CLGeocoder()
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        print("tapped")
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state.rawValue == 1 { 
            //print("long")
            let touchLocation = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            print("long tap at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            
            let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            
            geocoder.reverseGeocodeLocation(location){ (placemarks, error) in
                self.processResponseRev(withPlacemarks: placemarks, error: error)
            }
            
        }
    }
    
    @IBAction func butGeocoding(_ sender: Any) {
        geocoder.geocodeAddressString(textoGeo.text!){ (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?){
        if let error = error{
            print("Nao foi possivel encontrar o endereço")
        }else{
            var location: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("\(coordinate.latitude), \(coordinate.longitude)")
                centerMapOnLocation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            }else{
                print("Nao foi possivel encontrar o endereço")
            }
        }
    }
    
    private func processResponseRev(withPlacemarks placemarks: [CLPlacemark]?, error: Error?){
        if let error = error {
            print("unable to reverse geocode location")
        }else{
            if let placemarks = placemarks, let placemark = placemarks.first{
                print("\(placemark.country!) - \(placemark.locality!) - \(placemark.postalCode!) - \(placemark.name!)")
            }else{
                print("nao foi encontrado match")
            }
        }
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: false)
        
        let point = MKPointAnnotation();
        point.coordinate = CLLocationCoordinate2D(latitude: 41.701497, longitude: -8.834756)
        point.title = "Santa Luzia"
        point.subtitle = "Viana do Castelo"
        mapView.addAnnotation(point);
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func clickSegControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
              mapView.mapType = .hybrid
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //assds
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print(view.annotation!.title!!)
            print(view.annotation!.subtitle!!)
            print(view.annotation!.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: .detailDisclosure) as UIButton
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
        
        
        
        
    }
    
    
    
    
    
}

