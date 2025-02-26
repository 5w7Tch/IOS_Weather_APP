//
//  location.swift
//  WeatherApp
//
//  Created by Stra1 T on 11.02.25.
//

import Foundation

import UIKit
import CoreLocation
import CoreData




extension WeatherViewController: CLLocationManagerDelegate {

    func promptForLocationActivation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let status = CLLocationManager.authorizationStatus()
            
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            checkForLocationAuthorizationStatus()
        }
    }
    
    func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Access Denied",
            message: "To use this feature, please enable location access in Settings.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            self.openSettings()
        }))

        present(alert, animated: true, completion: nil)
    }

    
    func openSettings(){
        if let url = URL(string: UIApplication.openSettingsURLString){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func checkForLocationAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied.")
            
            showLocationDeniedAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("Location permission not determined.")
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
            print("Unknown location authorization status.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForLocationAuthorizationStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location
            locationManager.stopUpdatingLocation()
            getAndAddCity()
        }
    }

    func getAndAddCity() {
        guard let location = self.userLocation else {
            print("Location is nil")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error)")
                return
            }

            guard let placemark = placemarks?.first, let city = placemark.locality else {
                print("Could not determine city")
                return
            }

            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            if !self.doesCityExist(cityName: city, context: context) {
                print(city)
                self.addCity(city)
            }
        }
    }
}


extension WeatherViewController {
    
    
    
    
    func checkForLocationAutorizationStatus(){
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }


    
    
    func doesCityExist(cityName: String, context: NSManagedObjectContext) -> Bool {
        print(cityName)
        let fetchRequest: NSFetchRequest<Town> = Town.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", cityName)
        fetchRequest.fetchLimit = 1
        
        do {
           
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            
            return false
        }
        
    }
    
    func addCity(_ city: String){
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(key)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Bad status code")
                    return
                }
                
                if let data = data {
                    do {
                        
                        _ = try JSONDecoder().decode(WeatherResponse.self, from: data)
                        
                        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        let newTown = Town(context: context)
                        newTown.name = city
                        newTown.collor = self.randomBackgroundColor().toHex()
                        try context.save()
                        
                    } catch {
                        self.showErrorPage(retryAction: {self.addCity(  city)})
                    }
                }
            }
        }.resume()
        
    }
    
    
    
}

