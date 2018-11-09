//
//  InsertViewController.swift
//  lab3
//
//  Created by Amelia Lekston on 09/11/2018.
//  Copyright © 2018 Marcel Lekston. All rights reserved.
//

import UIKit

protocol InsertViewControllerDelegate: class {
    func insertNewCity(cityName: String)
}

class InsertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var insertCityName: UITextField!
    @IBOutlet weak var displayCityNames: UITableView!
    
    weak var delegate: InsertViewControllerDelegate!
    
    let cityBasicInfoUrl: String = "https://www.metaweather.com/api/location/search/?query="
    var cities: [CityBasicInfo] = []{didSet{displayCityNames.reloadData()}}
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
}
