//
//  MasterViewController.swift
//  lab3
//
//  Created by Amelia Lekston on 20/10/2018.
//  Copyright © 2018 Marcel Lekston. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var cityNames = ["Warsaw", "London", "Berlin"]
    var objects = [Any]()
    let cityBasicInfoUrl: String = "https://www.metaweather.com/api/location/search/?query="
    let cityExtendedInfoUrl: String = "https://www.metaweather.com/api/location/"
    var cities = [CityCell](){didSet{tableView.reloadData()}}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
//
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        for city in cityNames {
            
            self.fetchCityExtendedInfoByName(cityName: city)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

//    @objc
//    func insertNewObject(_ sender: Any) {
//        cities.insert(CityCell(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
                controller.cityName = cities[indexPath.row].name
                controller.cityId = cities[indexPath.row].id
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let city = cities[indexPath.row]
        let name = cell.viewWithTag(1) as! UILabel
        name.text = city.name
        let image = cell.viewWithTag(2) as! UIImageView
        image.image = city.imageView
        let temperature = cell.viewWithTag(3) as! UILabel
        temperature.text = city.temperature
        
//        let object = objects[indexPath.row] as! NSDate
//        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }

    func fetchCityExtendedInfoByName(cityName: String) {
        let url = URL(string: self.cityBasicInfoUrl + cityName)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                let cityBasicInfo = (try decoder.decode([CityBasicInfo].self, from: newData))[0]
                self.fetchCityExtendedInfoById(cityName: cityName, id: String(cityBasicInfo.woeid))
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func fetchCityExtendedInfoById(cityName: String, id: String) {
        let url = URL(string: self.cityExtendedInfoUrl + id)!
        URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, response, error) in
            guard let newData = data else { return }
            let decoder = JSONDecoder()
            do {
                let cityExtendedInfo = try decoder.decode(CityExtendedInfo.self, from: newData)
                let image = try! UIImage(data: Data(contentsOf: URL(string: "https://www.metaweather.com/static/img/weather/png/\(cityExtendedInfo.consolidatedWeather[0].weatherStateAbbr).png")!))
                let temperature = String(format: "%.3f", cityExtendedInfo.consolidatedWeather[0].theTemp) + " C"
                let city = CityCell(id: id, name: cityName, imageView: image!, temperature: temperature)
                
                DispatchQueue.main.async {
                    self.cities.append(city)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
}

