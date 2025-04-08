//
//  ActivitiesController.swift
//  ImBored_App
//
//  Created by Ronin DeLeon on 5/5/23.
//

import Foundation
import UIKit
import MapKit

// Activities class inherits UITableViewController
class ActivitiesViewController : UITableViewController {
    
    var activityArray = [activityList]()
    
    func fetchJSON() {
        let endpointStr = "https://raw.githubusercontent.com/Kalmira-Two/IT315Project/main/ActivityList.json"
        let endpointURL = URL(string: endpointStr)
        // Pass through data function
        let dataBytes = try? Data(contentsOf: endpointURL!)
        // For debugging
        print(dataBytes)
        
        if (dataBytes != nil) {
            let dictionary:NSDictionary = (try! JSONSerialization.jsonObject(with: dataBytes!, options:JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            // For Debugging
            print("Dictionary --: \(dictionary) ---- \n")
            
            // Split resultant dictionary to two parts and keep the HikingTrails dictionary
            let activityDict = dictionary["Activities"]! as! [[String:AnyObject]]
            
            // Iterate through the dictionary and fetch data from each dictionary
            for index in 0...activityDict.count - 1 {
                // Dictionary for a single object
                let actLine = activityDict[index]
                // Create a hiking trail object
                let actData = activityList()
                actData.actName = actLine["ActivityName"] as! String
                // print("TrailName: - \(actLine.actName)")
                actData.actDesc = actLine["ActivityDesc"] as! String
                actData.actCat = actLine["ActivityCategory"] as! String
                actData.actImg = actLine["ActivityImage"] as! String
                actData.actWeb = actLine["ActivityWebsite"] as! String
                actData.actTime = actLine["ActivityLength"] as! String
                actData.actSqImg = actLine["ActivityTableImg"] as! String
                // Append each iterated item to the hiking trail object array
                activityArray.append(actData)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        
        // Initializes JSON file reading
        fetchJSON()
        // Initializes navigation bar items
        configureItems()
    }
    
    // Configure navigation items and the menu
    func configureItems() {
        let aboutIcon = UIImage(systemName: "info.circle")
        let sortIcon = UIImage(systemName: "line.3.horizontal.decrease")
        
        let aboutItem = UIBarButtonItem(title: "About", image: aboutIcon, target: self, action: #selector(aboutPage))
        let sortItem = UIBarButtonItem(title: "Sort & Filter", image: sortIcon, target: self, action: nil)
        // Create UI menu upon sortItem press
        let menu = UIMenu(title: "Sort by", children: [
            UIAction(title: "Category", image: UIImage(systemName: "square.grid.2x2"), handler: {_ in
                self.activityArray.sort(by: {$0.actCat < $1.actCat})
                self.tableView.reloadData()
            }),
            UIAction(title: "Name (Ascending)", image: UIImage(systemName: "arrow.up.arrow.down"), handler: {_ in
                self.activityArray.sort(by: {$0.actName < $1.actName})
                self.tableView.reloadData()
            }),
            UIAction(title: "Name (Descending)", image: UIImage(systemName: "arrow.up.arrow.down"), handler: {_ in
                self.activityArray.sort(by: {$0.actName > $1.actName})
                self.tableView.reloadData()
            })
        ])
        
        sortItem.menu = menu
        
        navigationItem.rightBarButtonItems = [aboutItem, sortItem]
    }
    
    
    // Function to open about page and load copyright statement and maps button
    @objc func aboutPage() {
        let aboutView = UIViewController()
        aboutView.title = "About"
        aboutView.view.backgroundColor = .systemYellow
        
        let aboutLabel = UILabel()
        aboutLabel.text = "©2023 Ronin De Leon\nThis app is developed as an educational project. Certain materials are included under the fair use exemption of the U.S. Copyright Law and have been prepared according to the multimedia fair use guidelines and are restricted from further use."
        aboutLabel.numberOfLines = 0
        aboutLabel.textAlignment = .left
        aboutLabel.frame = CGRect(x: 20, y: 200, width: view.bounds.width - 40, height: 200)
        aboutLabel.font = UIFont.systemFont(ofSize: 18)
        aboutView.view.addSubview(aboutLabel)
        
        let mapsButton = UIButton()
        mapsButton.setTitle("Open Address", for: .normal)
        mapsButton.backgroundColor = UIColor.black
        mapsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        mapsButton.addTarget(self, action: #selector(openGMUAddy), for: .touchUpInside)
        mapsButton.frame = CGRect(x: 20, y: 475, width: view.bounds.width - 40, height: 45)
        mapsButton.layer.cornerRadius = 15
        mapsButton.setImage(UIImage(systemName: "map.fill"), for: .normal)
        mapsButton.tintColor = UIColor.white

        aboutView.view.addSubview(mapsButton)
        
        navigationController?.pushViewController(aboutView, animated: true)

        }
    
    // Function launches maps with address and respective coordinate upon clicking the button in the aboutpage
    @objc func openGMUAddy() {
        let geocoder = CLGeocoder()
        let gmuAddy = "4511 Patriot Circle, Fairfax, VA, 22030"
        
        geocoder.geocodeAddressString(gmuAddy) { (placemarks, error) in
            guard let placemarks = placemarks?.first else {
                return
            }
            
            let location = placemarks.location?.coordinate
            
            if let lat = location?.latitude, let lon = location?.longitude {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)))
                destination.name = gmuAddy
                
                MKMapItem.openMaps(with: [destination])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationController = segue.destination as! ViewController
        // Finds selected row from TableView
        let indexAct = tableView.indexPathForSelectedRow
        // Finds matching row in the activityArray
        let selectedAct = activityArray[indexAct!.row]
        // Sets the destination controller activityArray object with the object from the selected row
        destinationController.SplitViewActivities = selectedAct
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Initializes number of rows per number of items in activityArray
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var activityCell = tableView.dequeueReusableCell(withIdentifier: "activityID")
        
        var cellIndex = indexPath.row
        
        var activity = activityArray[cellIndex]
        
        // Cell properties
        activityCell?.textLabel!.text = activity.actName
        activityCell?.detailTextLabel?.text = activity.actCat
        
        var img:UIImage = bytesToImg(urlString: activity.actSqImg)
        activityCell?.imageView?.image = img
        // Customize text properties
        activityCell?.textLabel!.font = UIFont.boldSystemFont(ofSize: 22)
        activityCell?.detailTextLabel!.font = UIFont.systemFont(ofSize: 18)
        activityCell?.backgroundColor = .systemYellow
        
        return activityCell!
    }
    
    func bytesToImg(urlString: String) -> UIImage {
        let imgURL = URL(string:urlString)!
        // Data function pulls bytes of data
        let imgData = try? Data(contentsOf: imgURL)
        print(imgData ?? "Error. Could not reach image endpoint \(imgURL)")
        let img = UIImage(data: imgData!)
        return img!
    }
}
