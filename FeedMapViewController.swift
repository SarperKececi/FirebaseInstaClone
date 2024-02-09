//
//  FeedMapViewController.swift
//  FirebaseInstaClone
//
//  Created by Sarper Kececi on 7.10.2023.
//

import UIKit
import MapKit

class FeedMapViewController: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var FeedMapView: MKMapView!
    
    var selectedLocation: String?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        if let location = selectedLocation {
            // Eğer bir konum seçildiyse, bu konumu harita üzerinde gösterin.
            showLocationOnMap(location: location)
        }
    }
    
    func showLocationOnMap(location: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Konum çözümlenirken hata oluştu: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                let annotation = MKPointAnnotation()
                annotation.coordinate = placemark.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                annotation.title = location
                self?.FeedMapView.addAnnotation(annotation)
                
                // Konumu haritanın merkezine alın
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self?.FeedMapView.setRegion(region, animated: true)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // İzin verildi, konum işlemlerini devam ettirebilirsiniz.
            // Kullanıcı izinleri aldığınızdan emin olunca, konum servislerini başlatın veya konum işlemlerinizi burada gerçekleştirin.
            // Örneğin, konum servisini başlatma kodunu burada kullanabilirsiniz.
            break
        case .notDetermined:
            // Henüz izin verilmedi veya reddedilmedi, beklemeye devam edin.
            break
        case .restricted, .denied:
            // Kullanıcı izin vermedi, kullanıcıyı bilgilendirin veya ayarlara yönlendirin.
            break
        @unknown default:
            break
        }
    }

    @IBAction func goToPlace(_ sender: UIBarButtonItem) {
        // 1. Kullanıcının izinlerini kontrol etmek için CLLocationManager kullanın.
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    // 2. Kullanıcının izni varsa, mevcut konumu alabilirsiniz.
                    if let currentLocation = self.locationManager.location {
                        let currentCoordinate = currentLocation.coordinate

                        // 3. Gösterilen konumun koordinatlarını alın.
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(self.selectedLocation ?? "") { [weak self] (placemarks, error) in
                            if let error = error {
                                print("Konum çözümlenirken hata oluştu: \(error.localizedDescription)")
                                return
                            }

                            if let placemark = placemarks?.first, let placemarkCoordinate = placemark.location?.coordinate {
                                // 4. Mevcut konum ve hedef konum ile bir MKDirectionsRequest oluşturun.
                                let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
                                let destinationPlacemark = MKPlacemark(coordinate: placemarkCoordinate)

                                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                                let destinationItem = MKMapItem(placemark: destinationPlacemark)

                                let directionRequest = MKDirections.Request()
                                directionRequest.source = sourceItem
                                directionRequest.destination = destinationItem
                                directionRequest.transportType = .automobile

                                // 5. Yol tarifini hesaplayın ve haritada gösterin.
                                let directions = MKDirections(request: directionRequest)
                                directions.calculate { (response, error) in
                                    if let error = error {
                                        print("Yol tarifi hesaplanırken hata oluştu: \(error.localizedDescription)")
                                    } else {
                                        if let route = response?.routes.first {
                                            self?.FeedMapView.addOverlay(route.polyline, level: .aboveRoads)
                                            self?.FeedMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print("Kullanıcının konumu alınamıyor.")
                    }
                case .notDetermined, .restricted, .denied:
                    // 6. Eğer kullanıcının izni yoksa, izin isteği gösterin.
                    DispatchQueue.main.async {
                        self.locationManager.requestWhenInUseAuthorization()
                    }
                @unknown default:
                    break
                }
            } else {
                print("Konum servisleri etkinleştirilmemiş.")
            }
        }
    }
}

