//
//  AdoptDetailMapCell.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/29.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import MapKit

class AdoptDetailMapCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    
    func configure(location: String) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
//    func goToAppleMap(location: String) {
//        let geoCoder = CLGeocoder()
//
//        geoCoder.geocodeAddressString(location) { (placemarks, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            if let placemarks = placemarks {
//                let placemark = placemarks[0]
//                let annotation = MKPointAnnotation()
//
//                if let location = placemark.location {
//                    annotation.coordinate = location.coordinate
//                    let start = self.mapView.userLocation.coordinate
//                    let end = annotation.coordinate
//                    self.direct(start: start, end: end)
//                }
//            }
//        }
//    }
    


}
