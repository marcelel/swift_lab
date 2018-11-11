//
//  InsertViewController.swift
//  lab3
//
//  Created by Amelia Lekston on 09/11/2018.
//  Copyright © 2018 Marcel Lekston. All rights reserved.
//

import UIKit
import MapKit

protocol InsertViewControllerDelegate: class {
    func insertNewCity(cityName: String)
}

class InsertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var insertCityName: UITextField!
    @IBOutlet weak var displayCityNames: UITableView!
    
    let locationManager = CLLocationManager()
    let bingUri = "https://dev.virtualearth.net/REST/v1/Locations/%5f,%5f?key=AnXCIDfyDmdeWhsmlUUIos9mDWM2bMqFFDw8r_9VZUeqXk11LuWOy7dE357jvjqx"
    let citiesByCordinatesUrl: String = "https://www.metaweather.com/api/location/search/?lattlong=%2f,%2f"
    let cityBasicInfoUrl: String = "https://www.metaweather.com/api/location/search/?query="
    
    weak var delegate: InsertViewControllerDelegate!
    
    var coordinates: CLLocationCoordinate2D!
    var cities: [CityBasicInfo] = []{didSet{displayCityNames.reloadData()}}
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func currentLocationTapped(_ sender: Any) {
        let uriWithCoordinates = String(format: self.citiesByCordinatesUrl, self.coordinates.latitude, self.coordinates.longitude)
        let url = URL(string: uriWithCoordinates)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                let fetchedCitiesWithDistance = (try decoder.decode([CityDistanceBasicInfo].self, from: newData))
                let fetchedCities = (try decoder.decode([CityBasicInfo].self, from: newData))
                if fetchedCitiesWithDistance[0].distance < 10000 {
                    self.cities = [fetchedCities[0]]
                } else {
                    self.cities = fetchedCities
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    @IBAction func apply(_ sender: Any) {
        let url = URL(string: self.cityBasicInfoUrl + insertCityName.text!)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                self.cities = (try decoder.decode([CityBasicInfo].self, from: newData))
            } catch {
                print(error)
            }
        }).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayCityNames.delegate = self
        displayCityNames.dataSource = self
        displayCityNames.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let city = self.cities[indexPath.row]
        cell.textLabel?.text = city.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.insertNewCity(cityName: self.cities[indexPath.row].title)
        navigationController?.popViewController(animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.coordinates = locations[0].coordinate
        findCurrentLocationName()
    }
    
    func findCurrentLocationName() {
        let bingUriWithCoordinates = String(format: self.bingUri, self.coordinates.latitude, self.coordinates.longitude)
        let url = URL(string: bingUriWithCoordinates)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                let bingResponse = try decoder.decode(BingResponse.self, from: newData)
                let currentLocation = bingResponse.resourceSets[0].resources[0].name
                DispatchQueue.main.async {
                    self.updateCurrentLocation(currentLocation: currentLocation)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func updateCurrentLocation(currentLocation: String) {
        self.currentLocation.text = "Current location: " + currentLocation
    }
}
