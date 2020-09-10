//
//  MapViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/31.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var adopt: Adopt?
    var adoptMO: AdoptMO?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        
        let geoCoder = CLGeocoder()
        
        guard adopt != nil else {
            geoCoder.geocodeAddressString(adoptMO?.shelterAddress ?? "") { (placemarks, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    let annotation = MKPointAnnotation()
                    annotation.title = self.adoptMO?.shelterName
                    annotation.subtitle = self.adoptMO?.shelterAddress
                    
                    if let location = placemark.location {
                        annotation.coordinate = location.coordinate
                        
                        self.mapView.showAnnotations([annotation], animated: false)
                        self.mapView.selectAnnotation(annotation, animated: true)
                        
                    }
                }
            }
            
            return
        }
        
        geoCoder.geocodeAddressString(adopt?.shelterAddress ?? "") { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                let annotation = MKPointAnnotation()
                
                annotation.title = self.adopt?.shelterName
                annotation.subtitle = self.adopt?.shelterAddress
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    self.mapView.showAnnotations([annotation], animated: false)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
            
        }
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //
    //        switch status {
    //        case .denied, .restricted:
    //            let alertController = UIAlertController(title: "定位失敗", message: "請先開啟定位權限", preferredStyle: .alert)
    //            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
    //                self.dismiss(animated: true, completion: nil)
    //            }
    //            let okAction = UIAlertAction(title: "設定", style: .default) { (_) in
    //                let url = URL(string: UIApplication.openSettingsURLString)
    //                if let url = url, UIApplication.shared.canOpenURL(url) {
    //                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    //                }
    //
    //            }
    //            alertController.addAction(cancelAction)
    //            alertController.addAction(okAction)
    //            present(alertController, animated: true, completion: nil)
    //
    //            break
    //        case .authorizedWhenInUse, .authorizedAlways:
    //            if let userLocation = locationManager.location?.coordinate {
    //                let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 800, longitudinalMeters: 800)
    //                mapView.setRegion(region, animated: true)
    //                mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(MaskAnnotation.self)")
    //            }
    //        case .notDetermined:
    //            locationManager.requestWhenInUseAuthorization()
    //            break
    //        default:
    //            break
    //        }
    //    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    
    func direct(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let placemark_start = MKPlacemark(coordinate: start, addressDictionary: nil)
        let placemark_end = MKPlacemark(coordinate: end, addressDictionary: nil)
        //       導航需要轉成MapItem
        let mapItem_start = MKMapItem(placemark: placemark_start)
        let mapItem_end = MKMapItem(placemark: placemark_end)
        
        mapItem_start.name = "我的位置"
        let name = String(format: "(%.2f, %.2f)", end.latitude, end.longitude)
        mapItem_end.name = name
        
        let mapItems = [mapItem_start, mapItem_end]
        /* 設定導航模式：開車、走路、搭車 */
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        //        開啟內建的apple map
        MKMapItem.openMaps(with: mapItems, launchOptions: options)
    }
}
