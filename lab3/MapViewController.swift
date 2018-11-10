//
//  MapViewController.swift
//  lab3
//
//  Created by Amelia Lekston on 09/11/2018.
//  Copyright © 2018 Marcel Lekston. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    let uri = "https://dev.virtualearth.net/REST/v1/Locations?key=AnXCIDfyDmdeWhsmlUUIos9mDWM2bMqFFDw8r_9VZUeqXk11LuWOy7dE357jvjqx&locality="
    var cityName: String!
    var coordinates: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoordinates()
    }
    
    func fetchCoordinates() {
        let uriCityName = self.uri + self.cityName
        let url = URL(string: uriCityName)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                let bingResponse = (try decoder.decode(BingResponse.self, from: newData))
                self.coordinates = bingResponse.resourceSets[0].resources[0].point.coordinates
                DispatchQueue.main.async {
                    self.addAnnotation()
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func addAnnotation() {
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
        let coordinates2D = CLLocationCoordinate2D(latitude: self.coordinates[0], longitude: self.coordinates[1])
        annotation.coordinate = coordinates2D
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinates2D, animated: true)
    }
}
