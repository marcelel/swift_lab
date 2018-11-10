//
//  DetailViewController.swift
//  lab3
//
//  Created by Amelia Lekston on 20/10/2018.
//  Copyright © 2018 Marcel Lekston. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDIrection: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var cityName: String = ""
    var cityId: String = ""
    
    var dayCounter: Int = 0
    var city: CityExtendedInfo!
    let url: String = "https://www.metaweather.com/api/location/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = cityName
        fetchData()
        prevButton.isEnabled = false
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        dayCounter -= 1
        if (dayCounter == 0) {
            prevButton.isEnabled = false
        }
        nextButton.isEnabled = true
        updateView()
    }
    
    @IBAction func mapClicked(_ sender: Any) {
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        dayCounter += 1
        if (dayCounter == 5) {
            nextButton.isEnabled = false
        }
        prevButton.isEnabled = true
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapViewController = segue.destination as! MapViewController
        mapViewController.cityName = self.cityName
    }
    
    func fetchData() {
        let url = URL(string: self.url + cityId)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                self.city = try decoder.decode(CityExtendedInfo.self, from: newData)
                DispatchQueue.main.async {
                    self.updateView()
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func updateView() {
        let info = self.city.consolidatedWeather[dayCounter]
        date.text = info.applicableDate
        minTemperature.text = String(format: "%.3f", info.minTemp) + " C"
        maxTemperature.text = String(format: "%.3f", info.maxTemp) + " C"
        windSpeed.text = String(format: "%.3f", info.windSpeed) + " mph"
        windDirection.text = info.windDirectionCompass
        pressure.text = String(format: "%.3f", info.airPressure) + " hPa"
        imageView.image = try! UIImage(data: Data(contentsOf: URL(string: "https://www.metaweather.com/static/img/weather/png/\(info.weatherStateAbbr).png")!))
    }
}

